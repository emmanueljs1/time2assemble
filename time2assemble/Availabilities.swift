//
//  Availabilities.swift
//  time2assemble
//
//  Created by Hana Pearlman on 3/20/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//
// Purpose: to handle the getting/setting of Availability- related information in the db,
// such as filled out availabilities and conflicts (from the gcal api)

import Foundation
import Firebase

class Availabilities {
    
    static var finishedProcessing = false
    
    /**
     Given an event Id, returns a mapping from string to [int : int] where the string represents a date,
     eg "2018-09-12" and the int key represents hour of that day (eg 7, aka 7am), and the int value represents
     the number of invited users who are available during the hour long time block
     */
    class func getAllEventAvailabilities(_ eventID: String, callback: @escaping (_ availabilities: [String: [Int:Int]])-> ()) {
        let ref = Database.database().reference()
        var availsDict = [String: [Int: Int]] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (_, value) in dict {
                if let user_avails = value as? [String: [Int]] { //availability of a single user
                    for (date, hourList) in user_avails {
                        for hour in hourList {
                            if let hourMap = availsDict[date] {
                                if let hourCount = hourMap[hour] {
                                    availsDict[date]![hour] = hourCount + 1
                                } else {
                                    availsDict[date]![hour] = 1
                                }
                            } else {
                                availsDict[date] = [hour : 1]
                            }
                        }
                    }
                }
            }
            Availabilities.finishedProcessing = true
            callback(availsDict)
        }) { (error) in
            print("error finding availabilities")
        }
    }
    
    // Helper function for displaying available users at a certain time
    class func getAllAvailUsers(_ eventID: String, callback: @escaping (_ availabilities: [String: [Int:[User]]])-> ()) {
        let ref = Database.database().reference()
        var availsDict = [String: [Int: [User]]] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (key, value) in dict {
                if let user_avails = value as? [String: [Int]] { //availability of a single user
                    for (date, hourList) in user_avails {
                        for hour in hourList {
                            ref.child("users").child(key as! String).observeSingleEvent(of: .value, with: {(snapshot) in
                                let dict = snapshot.value as? NSDictionary ?? [:]
                                if let firstName = dict["firstName"] as? String,
                                    let lastName = dict["lastName"] as? String,
                                    let email = dict["email"] as? String {
                                        let user = User(firstName, lastName, email, Int(key as! String)!)
                                        if let hourMap = availsDict[date] {
                                            if hourMap[hour] != nil {
                                                var list = availsDict[date]![hour]
                                                list?.append(user)
                                                availsDict[date]![hour] = list
                                            } else {
                                                availsDict[date]![hour] = [user]
                                            }
                                        } else {
                                            availsDict[date] = [hour: [user]]
                                        }
                                }
                                callback(availsDict)
                            })
                        }
                    }
                }
            }
        }) { (error) in
            print("error finding availabilities")
        }
    }

    class func getAllParticipants(_ eventID: String, callback: @escaping (_ participants: [User], Bool)-> ()) {
        let ref = Database.database().reference()
        var participants = [User] ()
        ref.child("events").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            var participantIds = dict["invitees"] as? [Int] ?? []
            if let creator = dict["creator"] as? Int {
                participantIds.append(creator)
            }
            var done = false
            var count = participantIds.count
            for id in participantIds {
                ref.child("users").child(String(id)).observeSingleEvent(of: .value, with: {(snapshot) in
                    let dict = snapshot.value as? NSDictionary ?? [:]
                    if let firstName = dict["firstName"] as? String,
                        let lastName = dict["lastName"] as? String,
                        let email = dict["email"] as? String {
                        let user = User(firstName, lastName, email, id)
                        participants.append(user)
                    }
                    count -= 1
                    done = (count == 0)
                    callback(participants, done)
                })
            }
        }) { (error) in
            print("error finding availabilities")
        }
    }
    
    /**
     Given an event ID and user ID, returns a mapping from representing the user's availiability for the event,
     in the following format:
     1) the date of the availability (eg, "2018-09-12"),
     2) the start time of a available range (eg "0900"), and
     3) the end time of the range (eg "1200"),
     */
    class func getEventAvailabilitiesForUser (_ eventID: String, _ userID: String) -> [String: [Int]] {
        let ref = Database.database().reference()
        var avails : Dictionary = [String: [Int]] ()
        ref.child("availabilities").child(eventID).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? Dictionary<String, [Int]> ?? [:]
            for (date, hourList) in dict {
                avails[date] = hourList
            }
        }) { (error) in
            print("error finding availabilities")
        }
        return avails
    }
    
    class func clearAvailabilitiesForEvent(_ eventID: String) {
        let ref = Database.database().reference()
        ref.child("availabilities").child(eventID).removeValue()
    }
    
    /* Takes in an event ID, a user ID, and that user's availability for the event in the following format:
     a map of String -> list of (int, int) tuples representing:
     1) key: the String date of the availability (eg, "2018-09-12"),
     2) value: a list of (x, y) where x is the start time of a available range (eg 9 for 9am), and y is
     the end time of the range (eg 12 for 12 pm),
     denoting that the user is free from 9am to 12pm on Sept 12th, 2018
     and stores this in the database
     */
    class func setEventAvailabilitiesForUser (_ eventID: String, _ userID: String, _ availabilities: [String: [(Int, Int)]]) {
        let ref = Database.database().reference()
        let refAvails = ref.child("availabilities")
        let refEvent = refAvails.child(eventID)
        let refUser = refEvent.child(userID)
        for (date, intRanges) in availabilities {
            let refDate = refUser.child(date)
            var hourList : [Int] = []
            for (intStart, intEnd) in intRanges {
                for indexHour in intStart...intEnd {
                    hourList.append(indexHour)
                }
            }
            refDate.setValue(hourList)
        }
    }
    
    /* Takes in a user ID, and that user's events from their calendar in the following format:
     a map of String -> (map of int -> string) representing:
     1) key: the String date of the cal event (eg, "2018-09-12"),
     2) value: dictionary mapping from
     a) key: an hour of the day to
     b) value: the name of the event from the calendar at that time
     and stores the user's calendar in the database, to be displayed when a user is filling out their availabilities
     */
    class func setCalEventsForUser (_ userID: String, _ availabilities: [String: [Int : String]]) {
        let ref = Database.database().reference()
        let refCalEvents = ref.child("user-cal-events")
        let refUser = refCalEvents.child(userID)
        for (date, hourToEventMap) in availabilities {
            let refDate = refUser.child(date)
            for (hour, eventName) in hourToEventMap {
                print("setting child of " + String(hour) + " to be " + eventName)
                refDate.child(String(hour)).setValue(eventName)
            }
        }
    }
    
    /**
    Given userID, start date, and end date, find all events in the users calendar which occur between those times
     and pass them to the callback function
     */
    class func getCalEventsForUser (_ userID: String, _ startDate: Date, _ endDate: Date, callback: @escaping (_ events: [String: [Int: String]])-> ()) -> [String: [Int: String]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let ref = Database.database().reference()
        var availsDict : Dictionary = [String: [Int: String]] ()
        print("BEFORE REF.CHILD in Availabilities")
        ref.child("user-cal-events").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? Dictionary<String, NSObject> ?? [:] // dict a mapping from string date to map of hour -> eventName
            for (stringDate, eventMapping) in dict {
                let mappingDate = formatter.date(from: String(describing: stringDate))
                if (mappingDate! >= startDate && mappingDate! <= endDate) {
                    print("a mapping date in the right range")
                    if let hourToEvent = eventMapping as? Dictionary<String, String> {
                        print("hourToEvent is: " + String(describing: hourToEvent))
                        for (hour, eventName) in hourToEvent {
                            if let _ = availsDict[stringDate] {
                                if let _ = availsDict[stringDate]![Int(hour)!] {
                                    //do nothing, mapping already exists
                                } else {
                                    availsDict[stringDate]![Int(hour)!] = eventName
                                }
                            } else {
                                availsDict[stringDate] = [Int(hour)! : eventName]
                            }
                        }
                        
                        callback(availsDict)
                    }
                    //TODO: get rid of this stuff
                    /*ref.child("user-cal-events").child(userID).child(stringDate).observeSingleEvent(of: .value, with: { (snapshot) in
                        let hourToEvent = snapshot.value as? Dictionary<String, String> ?? [:] // dict a mapping from int hour -> eventName
                        print("hourToEvent is: " + String(describing: hourToEvent))
                        for (hour, eventName) in hourToEvent {
                            if let _ = availsDict[stringDate] {
                                if let _ = availsDict[stringDate]![Int(hour)!] {
                                    //do nothing, mapping already exists
                                } else {
                                    availsDict[stringDate]![Int(hour)!] = eventName
                                }
                            } else {
                                availsDict[stringDate] = [Int(hour)! : eventName]
                            }
                        }

                        callback(availsDict)
                    })*/
                }
            }
            callback(availsDict)
            
        }) { (error) in
            print("error finding user's cal events")
        }
        
        return availsDict
    }
}

