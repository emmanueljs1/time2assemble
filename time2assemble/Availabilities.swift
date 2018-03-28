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
    class func getAllEventAvailabilities(_ eventID: String) -> [String: [Int: Int]] {
        let ref = Database.database().reference()
        Availabilities.finishedProcessing = false
        var availsDict : Dictionary = [String: [Int: Int]] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (_, value) in dict {
                print(value)
                if let user_avails = value as? [String: [Int]] { //availability of a single user
                    print("got here")
                    for (date, hourList) in user_avails {
                        print("got here 2")
                        print(date)
                        print(hourList)
                        for hour in hourList {
                            if let hourMap = availsDict[date] {
                                if let hourCount = hourMap[hour] {
                                    print("adding stuff")
                                    availsDict[date]![hour] = hourCount + 1
                                } else {
                                    print("THIS ONE")
                                    availsDict[date]![hour] = 1
                                }
                            } else {
                                print("actally yhus one")
                                availsDict[date] = [hour : 1]
                            }
                        }
                    }
                }
            }
            Availabilities.finishedProcessing = true
            print("HELLO? \(availsDict)")
        }) { (error) in
            print("error finding availabilities")
        }
        
        return availsDict
    }
    
    /**
     Given an event ID and user ID, returns a list of tuples representing the user's availiability for the event,
     in the following format:
     1) the date of the availability (eg, "2018-09-12"),
     2) the start time of a available range (eg "0900"), and
     3) the end time of the range (eg "1200"),
     */
    //    class func getEventAvailabilitiesForUser (_ eventID: String, _ userID: String) -> [(String, Int, Int)] {
    //        let ref = Database.database().reference()
    //        var avails = [(String, Int, Int)] ()
    //        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
    //            let dict = snapshot.value as? NSDictionary ?? [:]
    //            if let user_avails = dict[userID] as? [(String, Int, Int)] {
    //                avails = user_avails
    //            }
    //        }) { (error) in
    //            print("error finding availabilities")
    //        }
    //        return avails
    //    }
    
    /* Takes in an event ID, a user ID, and that user's availability for the event in the following format:
     a list of (string, int, int) tuples representing:
     1) the date of the availability (eg, "2018-09-12"),
     2) the start time of a available range (eg "0900"), and
     3) the end time of the range (eg "1200"),
     denoting that the user is free from 9am to 12pm on Sept 12th, 2018
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
}
