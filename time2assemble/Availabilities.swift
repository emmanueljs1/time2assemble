//
//  Availabilities.swift
//  time2assemble
//
//  Created by Hana Pearlman on 3/20/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation
import Firebase

class Availabilities {
    
    static var finishedProcessing = false
    
    /**
     Given an event Id, returns a mapping from string to [int : int] where the string represents a date,
     eg "2018-09-12" and the int key represents hour of that day (eg 7, aka 7am), and the int value represents
     the number of invited users who are available during the hour long time block
     */
    class func getAllEventAvailabilities(_ eventID: String, callback: @escaping (_ availabilities: [String: [Int:Int]])-> ()) -> [String: [Int: Int]] {
        let ref = Database.database().reference()
        Availabilities.finishedProcessing = false
        var availsDict : Dictionary = [String: [Int: Int]] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (_, value) in dict {
                if let user_avails = value as? [String: [Int]] { //availability of a single user
                    for (date, hourList) in user_avails {
                        print(date)
                        print(hourList)
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
        
        return availsDict
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
    
    class func getCalEventsForUser (_ userID: String, _ dates: [String], callback: @escaping (_ events: [String: [Int: String]])-> ()) -> [String: [Int: String]] {
        let ref = Database.database().reference()
        var availsDict : Dictionary = [String: [Int: String]] ()
        print("GETTING CAL EVENTS FROM DB for user " + userID)
        ref.child("user-cal-events").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("GOT SNAPSHOT")
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for date in dates {
                print("iterating through date " + date)
                //print(String(describing: dict))
                print(String(describing: dict[date]))
                if let userEventMap = dict[date] as? [String: String] {
                    print("in user map before userEventMap iterate")
                    for (hour, eventName) in userEventMap {
                        print("iterating through event map")
                        if let _ = availsDict[date] {
                            if let _ = availsDict[date]![Int(hour)!] {
                                //do nothing, mapping already exists
                                print("do nothing map already exists")
                            } else {
                                print("adding to " + date + " the hour " + String(hour) + " the event " + eventName)
                                availsDict[date]![Int(hour)!] = eventName
                            }
                        } else {
                            print("adding to " + date + " the hour " + String(hour) + " the event " + eventName)
                            availsDict[date] = [Int(hour)! : eventName]
                        }
                    }
                }
            }
        }) { (error) in
            print("error finding user's cal events")
        }
        
        return availsDict
    }
}
