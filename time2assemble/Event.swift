//
//  Event.swift
//  time2assemble
//
//  Created by Jane Xu on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class Event {
    var creator: Int
    var invitees: [Int]
    var description: String
    var id: String
    var name: String
    var noEarlierThan: Int
    var noLaterThan: Int
    var startDate: String
    var endDate: String
    
    init (_ name: String, _ creator: Int, _ invitees: [Int], _ description: String, _ id: String, _ noEarlierThan: Int,
          _ noLaterThan: Int, _ startDate: String, _ endDate: String) {
        self.creator = creator
        self.invitees = invitees
        self.noEarlierThan = noEarlierThan
        self.noLaterThan = noLaterThan
        self.startDate = startDate
        self.endDate = endDate
        self.name = name
        self.description = description
        self.id = id
    }
    
    func getStartDateDay() -> Int {
        let splitDate = startDate.split(separator: "-")
        return Int(splitDate[2])!
    }
    
    func getEndDateDay() -> Int {
        let splitDate = endDate.split(separator: "-")
        return Int(splitDate[2])!
    }
    
}
