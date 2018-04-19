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
    
    class func setFinalizedEventTimes(_ event: Event, _ finalizedTimes: [String: [(Int, Int)]]) {
        let ref = Database.database().reference()
        let refFinalizedTimes = ref.child("finalizedTimes")
        let refEvent = refFinalizedTimes.child(event.id)
        for (date, timeRanges) in finalizedTimes {
            let refDate = refEvent.child(date)
            var hourList : [Int] = []
            for (intStart, intEnd) in timeRanges {
                for indexHour in intStart...intEnd {
                    hourList.append(indexHour)
                }
            }
            refDate.setValue(hourList)
        }
    }
    
    class func getFinalizedEventTimes(_ event: Event, callback: @escaping ([String: [(Int, Int)]]) -> ()) {
        let ref = Database.database().reference()
        var finalizedTimes = [String: [(Int, Int)]]()
        ref.child("finalizedTimes").child(event.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            for (key, value) in dict {
                if let date = key as? String,
                    let hourList = value as? [Int] {
                    var timeRanges : [(Int, Int)] = []
                    var lastStartHourOpt : Int? = nil
                    var lastHourOpt : Int? = nil
                    for hour in hourList {
                        if let lastStartHour = lastStartHourOpt {
                            if let lastHour = lastHourOpt {
                                if hour != lastHour + 1 {
                                    timeRanges.append((lastStartHour, lastHour))
                                    lastStartHourOpt = hour
                                }
                            }
                        }
                        else {
                            lastStartHourOpt = hour
                        }
                        lastHourOpt = hour
                    }
                    if let startHour = lastStartHourOpt,
                        let endHour = lastHourOpt {
                        timeRanges += [(startHour, endHour)]
                    }
                    
                    finalizedTimes[date] = timeRanges
                }
            }
            callback(finalizedTimes)
        })
        { (error) in
            print("Error getting finalized times, trace: \(error)")
        }
    }
    
    class func getUserEvents(_ userID: Int, _ callback: @escaping ([Event], [Event], [Event]) -> ()) {
        let ref = Database.database().reference()
        ref.child("users").child(String(userID)).observeSingleEvent(of: .value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            var createdEventIds : [String] = []
            var invitedEventIds : [String] = []
            var archivedEventIds : [String] = []
            
            if let dbInvitedEvents = dict["invitedEvents"] as? [String] {
                invitedEventIds = dbInvitedEvents
            }
            if let dbCreatedEvents = dict["createdEvents"] as? [String] {
                createdEventIds = dbCreatedEvents
            }
            if let dbArchivedEvents = dict["archivedEvents"] as? [String] {
                archivedEventIds = dbArchivedEvents
            }
                
            let eventIds = invitedEventIds + createdEventIds + archivedEventIds
            let created = Set<String>(createdEventIds)
            let archived = Set<String>(archivedEventIds)
                
            var invitedEvents : [Event] = []
            var createdEvents : [Event] = []
            var archivedEvents : [Event] = []
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
                        let latestDate = dict["latestDate"] as? String {
                        
                            let finalizedTime = dict["finalizedTime"] as? [String: [(Int, Int)]] ?? [:]
                        
                            let newEvent = Event(name, creator, [], description, eventId, noEarlierThan, noLaterThan, earliestDate, latestDate, finalizedTime)
                        
                            if created.contains(eventId) {
                                createdEvents.append(newEvent)
                            } else if archived.contains(eventId) {
                                archivedEvents.append(newEvent)
                            } else {
                                invitedEvents.append(newEvent)
                            }
    
                            callback(invitedEvents, createdEvents, archivedEvents)
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
    
    class func archiveEvent(_ user: User, _ event: Event, callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        let reference =  ref.child("users").child(String(user.id))
        reference.child("archivedEvents").observeSingleEvent(of: .value, with: { (snapshot) in
            var dbArchivedEvents = snapshot.value as? [String] ?? [String]()
            dbArchivedEvents.append(event.id)
            reference.child("archivedEvents").setValue(dbArchivedEvents)
            
            if (event.creator == user.id) {
                reference.child("createdEvents").observeSingleEvent(of: .value, with: { (snapshot) in
                    var dbCreatedEvents = snapshot.value as? [String] ?? [String]()
                    dbCreatedEvents = dbCreatedEvents.filter { $0 != event.id }
                    reference.child("createdEvents").setValue(dbCreatedEvents)
                    callback()
                })
            } else {
                reference.child("invitedEvents").observeSingleEvent(of: .value, with: { (snapshot) in
                    var dbInvitedEvents = snapshot.value as? [String] ?? [String]()
                    dbInvitedEvents = dbInvitedEvents.filter { $0 != event.id }
                    reference.child("invitedEvents").setValue(dbInvitedEvents)
                    callback()
                })
            }
        })
    }
    
    class func inviteUserToEvent(_ user: User, _ eventId: String, callback: @escaping (DatabaseStatus.InviteStatus) -> ()) {
        let ref = Database.database().reference()
        ref.child("events").child(eventId).observeSingleEvent(of: .value, with: {(snapshot) in
            // Get event value
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            if dict.count == 0 {
                callback(.eventNotFound)
                return
            }
            
            if let creatorId = dict["creator"] as? Int {
                if creatorId == user.id {
                    callback(.userIsCreator)
                    return
                }
            }
            
            var invitees = [Int]()
            
            if let from_database = dict["invitees"] as? [Int] {
                invitees = from_database
            }
            
            if invitees.contains(user.id) {
                callback(.userAlreadyInvited)
                return
            }

            invitees.append(user.id)
            
            // adds user id to invitees list
            ref.child("events").child(eventId).updateChildValues(["invitees": invitees])
            
            // adds event id to the user's event list
            ref.child("users").child(String(user.id)).observeSingleEvent(of: .value, with: {(snapshot) in
                let udict = snapshot.value as? NSDictionary ?? [:]
                if var invitedTo = udict["invitedEvents"] as? [String]
                {
                    invitedTo.append(eventId)
                    ref.child("users").child(String(user.id)).updateChildValues(["invitedEvents" : invitedTo])
                } else { // if the user hasn't been invited to anything
                    var invitedTo = [String]()
                    invitedTo.append(eventId)
                    ref.child("users").child(String(user.id)).updateChildValues(["invitedEvents" : invitedTo])
                }
                
                callback(.noError)
            })
            { (error) in print("Error: user id somehow not found, Trace: \(error)") }
        })
        { (error) in print("Error: Event doesn't exist, Trace: \(error)") }
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
    
    class func writeArchivedEvents(_ userID: Int, _ archivedEventIds: [String], callback: @escaping () -> ()) {
        let ref  = Database.database().reference().child("users").child(String(userID)).child("archivedEvents")
        ref.setValue(archivedEventIds)
        callback()
    }
    
    class func writeCreatedEvents(_ userID: Int, _ createdEventIds: [String], callback: @escaping () -> ()) {
        let ref  = Database.database().reference().child("users").child(String(userID)).child("createdEvents")
        ref.setValue(createdEventIds)
        callback()
    }
    
    class func writeInvitedEvents(_ userID: Int, _ invitedEventIds: [String], callback: @escaping () -> ()) {
        let ref  = Database.database().reference().child("users").child(String(userID)).child("invitedEvents")
        ref.setValue(invitedEventIds)
        callback()
    }
    
    class func getNotificationsForUser(_ userID: Int, callback: @escaping ([EventNotification]) -> ()) {
        Database.database().reference().child("notifications").child(String(userID)).observeSingleEvent(of: .value, with: {(snapshot) in
            var notificationList = [EventNotification]()
            let dict = snapshot.value as? NSDictionary ?? [:]
            for (_, notification) in dict {
                if let notificationMap = notification as? NSDictionary {
                    let sender = notificationMap["sender"] as? String
                    let eventID = notificationMap["eventID"] as? String
                    let read = notificationMap["read"] as? Bool
                    let type = notificationMap["type"] as? Int
                    let eventName = notificationMap["eventName"] as? String
                    notificationList += [EventNotification(sender!, userID, NotificationType.NotificationType(rawValue: type!)!, eventID!, read!, eventName!)]
                }
            }
            callback(notificationList)
        }) { (error) in }
    }
    
    class func getEventFromID(_ eventID: String, _ callback: @escaping ((Event) -> ())) {
       
       print("eventid again " + eventID)
        Database.database().reference().child("events").child("-" + eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            print(dict)
            
            if  let name = dict["name"] as? String,
                let creator = dict["creator"] as? Int,
                let description = dict["description"] as? String,
                let noEarlierThan = dict["noEarlierThan"] as? Int,
                let noLaterThan = dict["noLaterThan"] as? Int,
                let earliestDate = dict["earliestDate"] as? String,
                let latestDate = dict["latestDate"] as? String {
                print("got hereeeee")
                let finalizedTime = dict["finalizedTime"] as? [String: [(Int, Int)]] ?? [:]
                
                let newEvent = Event(name, creator, [], description, eventID, noEarlierThan, noLaterThan, earliestDate, latestDate, finalizedTime)
            
                callback(newEvent)
            }
        })
    }
    
    class func addNotificationForUser(_ userID: Int, _ notification: EventNotification) {
        Database.database().reference().child("notifications").child(String(userID)).childByAutoId().setValue(
            ["sender" : notification.sender,
             "eventID": notification.eventID,
             "read": notification.read,
             "type": notification.type.rawValue,
             "eventName": notification.eventName])
    }
    
}
