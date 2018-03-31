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
            "latestDate": event.endDate])
        
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
    
    
}
