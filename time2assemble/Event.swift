//
//  Event.swift
//  time2assemble
//
//  Created by Jane Xu on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

//Custom class to represent events
class Event {
    var creator: Int        //id of creator
    var invitees: [Int]     //list of invited members (ie, those who filled availability)
    var description: String
    var id: String          //event id, randomly generated
    var name: String
    var noEarlierThan: Int  //hour of day at beginning of 12 hr slot
    var noLaterThan: Int    //hour of day at end of 12 hr slot
    var startDate: String   //eg, 2018-12-04
    var endDate: String     //eg, 2018-12-05
    var finalizedTime: [String: [(Int,Int)]] //mapping from String date to int tuple (startHour, endHour)
    

    init (_ name: String, _ creator: Int, _ invitees: [Int], _ description: String, _ id: String, _ noEarlierThan: Int,
          _ noLaterThan: Int, _ startDate: String, _ endDate: String, _ finalizedTime: [String: [(Int, Int)]]) {
        self.creator = creator
        self.invitees = invitees
        self.noEarlierThan = noEarlierThan
        self.noLaterThan = noLaterThan
        self.startDate = startDate
        self.endDate = endDate
        self.name = name
        self.description = description
        self.id = id
        self.finalizedTime = finalizedTime
    }
    
    //return the day of the start date (eg for "2018-12-04" return 04)
    func getStartDateDay() -> Int {
        let splitDate = startDate.split(separator: "-")
        return Int(splitDate[2])!
    }
    
    //return the day of the end date (eg for "2018-12-05" return 05)
    func getEndDateDay() -> Int {
        let splitDate = endDate.split(separator: "-")
        return Int(splitDate[2])!
    }
    
}
