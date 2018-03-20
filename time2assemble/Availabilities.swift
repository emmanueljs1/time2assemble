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
    /**
     Given an event Id, returns a mapping from string to int where the string represents a time block,
     eg "2018-09-1209001000" and the int represents the number of invited users who are available during
     the time block
     */
    class func getAllEventAvailabilities(_ eventID: String) -> [String: Int] {
        let ref = Database.database().reference()
        var availsDict : Dictionary = [String: Int] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (_, value) in dict {
                if let user_avails = value as? [(String, Int, Int)] { //availability of a single user
                    for (date, startTime, endTime) in user_avails {
                        // iterate in hour blocks, from startTime (incl.) to endTime (not incl.)
                        for index in startTime..<endTime {
                            let endHour = startTime + 100 // eg, 0700 to 0800 or 0900 to 1000
                            let mapString = date + String(index) + String(endHour) // eg, "2018-09-1209001000"
                            if let count = availsDict[mapString] {
                                availsDict.updateValue(count + 1, forKey: mapString)
                            } else {
                                availsDict[mapString] = 1
                            }
                        }
                    }
                }
            }
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
    class func getEventAvailabilitiesForUser (_ eventID: String, _ userID: String) -> [(String, Int, Int)] {
        let ref = Database.database().reference()
        var avails = [(String, Int, Int)] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            if let user_avails = dict[userID] as? [(String, Int, Int)] {
                avails = user_avails
            }
        }) { (error) in
            print("error finding availabilities")
        }
        return avails
    }
    
    /* Takes in an event ID, a user ID, and that user's availability for the event in the following format:
     a list of (string, int, int) tuples representing:
        1) the date of the availability (eg, "2018-09-12"),
        2) the start time of a available range (eg "0900"), and
        3) the end time of the range (eg "1200"),
     denoting that the user is free from 9am to 12pm on Sept 12th, 2018
     */
    class func setEventAvailabilitiesForUSer (_ eventID: String, _ userID: String, _ availabilities: [(String, Int, Int)]) {
        let ref = Database.database().reference()
        let refAvails = ref.child("availabilities")
        let refEvent = refAvails.child(eventID)
        
        // adds a mapping from the userId to the availabilities list
        refEvent.updateChildValues([userID : availabilities])
    }
}
