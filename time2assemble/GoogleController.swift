//
//  GoogleController.swift
//  time2assemble
//
//  Created by Hana Pearlman on 4/11/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import Foundation
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn

class GoogleController {
    //given a response from gcal, parse events and store in db
    class func setEventsForUser (_ response : GTLRCalendar_Events, _ userID : Int) {
        var eventsDict : Dictionary = [String: [Int : String]] ()
        if let events = response.items, !events.isEmpty {
            for event in events {
                //parse event
                let description = event.summary!
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = "\(start.date)" //eg, 2018-04-05 15:30:00
                
                let dateIndex = startString.index(startString.startIndex, offsetBy: 10)
                let date = startString.prefix(upTo: dateIndex)
                
                let hourStart = startString.index(startString.startIndex, offsetBy: 11)
                let hourEnd = startString.index(startString.endIndex, offsetBy: -12)
                let hourStartString = String(startString.prefix(upTo: hourEnd)) // eg, 2018-04-05 15
                var startInt = Int(String(hourStartString.suffix(from: hourStart)))    // eg, 15
                
                let end = event.end!.dateTime ?? event.end!.date!
                let endString = "\(end.date)"
                let hourEndString = String(endString.prefix(upTo: hourEnd))
                var endInt = Int(String(hourEndString.suffix(from: hourStart)))
                
                //determine if event runs over into next hour (eg does it end at 11 or 11:30?)
                let endHourRunOver = endString.index(endString.endIndex, offsetBy: -10)
                let runOverInt = Int(String(endString[endHourRunOver]))
                if (runOverInt! == 0) {
                    endInt! = endInt! - 1;
                }
                
                endInt = (endInt! - 4) % 24;
                startInt = (startInt! - 4) % 24
                
                //if there is a value for this date already in our map
                if let hourToEventNameMap = eventsDict[String(date)] {
                    if (endInt! >= startInt!) {
                        //for every hour in the interval
                        for index in startInt!...endInt! {
                            if let _ = hourToEventNameMap[index] {
                                //do nothing; there's already something in the map at that time
                            } else {
                                //add the busy hour to the map
                                eventsDict[String(date)]![index] = description
                            }
                        }
                    }
                    
                } else {
                    //add all busy hours to the map
                    var hourToEventNameMap : Dictionary = [Int: String] ()
                    if (endInt! <= startInt!) {
                        continue
                    }
                    for index in startInt!...endInt! {
                        hourToEventNameMap[index] = description
                    }
                    eventsDict[String(date)] = hourToEventNameMap
                }
            }
        }
        
        //store in db the parsed events
        Availabilities.setCalEventsForUser(String(userID), eventsDict)
    }
}
