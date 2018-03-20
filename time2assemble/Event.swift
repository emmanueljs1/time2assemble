//
//  Event.swift
//  time2assemble
//
//  Created by Jane Xu on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class Event {
    var creator: String
    var invitees: [Int]
    var description: String
    var id: String
    var name: String
    
    init (name: String, creator: String, invitees: [Int], description: String, id: String) {
        self.creator = creator
        self.invitees = invitees
        self.name = name
        self.description = description
        self.id = id
    }
}
