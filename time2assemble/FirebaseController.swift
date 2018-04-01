//
//  FirebaseController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/31/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    
    class func getUserEvents(_ user: User, callback: @escaping ([Event], [Event]) -> ()) {
        let ref = Database.database().reference()
        ref.child("users").child(String(user.id)).observeSingleEvent(of: .value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            var createdEventIds : [String] = []
            var invitedEventIds : [String] = []
            
            if let ie = dict["invitedEvents"] as? [String] {
                invitedEventIds = ie
            }
            if let ce = dict["createdEvents"] as? [String] {
                createdEventIds = ce
            }
                
            let eventIds = invitedEventIds + createdEventIds
            let created = Set<String>(createdEventIds)
                
            var invitedEvents : [Event] = []
            var createdEvents : [Event] = []
            for eventId in eventIds {
                ref.child("events").child(eventId).observeSingleEvent(of: .value, with: {(snapshot) in
                    // Get event value
                    let dict = snapshot.value as? NSDictionary ?? [:]
                    
                    if  let name = dict["name"] as? String,
                        let creator = dict["creator"] as? Int,
                        let description = dict["description"] as? String,
                        let noEarlierThan = dict["noEarlierThan"] as? Int,
                        let noLaterThan = dict["noLaterThan"] as? Int,
                        let earliestDate = dict["earliestDate"] as? String,
                        let latestDate = dict["latestDate"] as? String,
                        let finalizedTime = dict["finalizedTime"] as? [String: [(Int, Int)]] { //check finalizedtime type
                        
                            let new_event = Event(name, creator, [], description, eventId, noEarlierThan, noLaterThan, earliestDate, latestDate, finalizedTime)
                        
                            if created.contains(eventId) {
                                createdEvents.append(new_event)
                            } else {
                                invitedEvents.append(new_event)
                            }
    
                            callback(invitedEvents, createdEvents)
                    }
                })
                { (error) in }
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    class func createEvent(_ user: User, _ event: Event, callback: @escaping (String) -> ()) -> () {
        let ref = Database.database().reference()
        let refEvents = ref.child("events")
        let refEvent = refEvents.childByAutoId()
        event.id = refEvent.key
        
        // add created event to database
        refEvents.child(event.id).setValue([
            "name": event.name,
            "description": event.description,
            "creator": event.creator,
            "invitees": event.invitees,
            "noEarlierThan": event.noEarlierThan,
            "noLaterThan": event.noLaterThan,
            "earliestDate": event.startDate,
            "latestDate": event.endDate,
            "finalizedTime": event.finalizedTime])
        
        // updates the created events for the creator
        ref.child("users").child(String(user.id)).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            var createdEvents = [String]()
            
            if let created_events = dict["createdEvents"] as? [String] {
                createdEvents = created_events
            }
            
            createdEvents.append(event.id)
            ref.child("users").child(String(user.id)).updateChildValues(["createdEvents" : createdEvents])
            callback(event.id)
        }) { (error) in
            print("error finding user")
        }
    }
    
    class func registerUser(_ firstName: String, _ lastName: String, _ id: Int, _ email: String, callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        ref.child("users").child(String(id)).observeSingleEvent(of: .value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            if dict.count == 0 {
                ref.child("users").child(String(id)).updateChildValues(
                    ["firstName" : firstName,
                     "lastName" : lastName,
                     "email" : email,
                     "invitedEvents" : [String](),
                     "createdEvents" : [String]()
                    ])
            }
            callback()
        }) { (error) in }
    }
    
    
}
