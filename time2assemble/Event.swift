//
//  Event.swift
//  time2assemble
//
//  Created by Jane Xu on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class Event {
    var creator : String
    var invitees : String
    var description : String
    var id : Int
    
    init (creator : String, invitees : String, description : String, id : Int) {
        
        self.creator = creator
        self.invitees = invitees
        self.description = description
        self.id = id
    }
}
