//
//  User.swift
//  time2assemble
//
//  Created by Julia Chun on 2/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class User {
    
    var firstName : String
    var lastName : String
    var email : String
    var id : Int
    var archivedEvents : [String]
    var createdEvents : [String]
    var invitedEvents : [String]
    
    init (_ firstName : String, _ lastName : String, _ email : String, _ id : Int, _ archivedEvents : [String], _ invitedEvents : [String], _ createdEvents : [String]) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
        self.archivedEvents = archivedEvents
        self.createdEvents = createdEvents
        self.invitedEvents = invitedEvents
    }
    
    func addCreatedEvent (_ eventID : String) {
        createdEvents.append(eventID)
    }
    
    func addInvitedEvent (_ eventID: String) {
        invitedEvents.append(eventID)
    }
    
    func addArchivedEvent (_ eventID : String) {
        archivedEvents.append(eventID)
    }

    func removeArchivedEvent (_ eventID : String) {
        archivedEvents = archivedEvents.filter { $0 != eventID }
    }
}
