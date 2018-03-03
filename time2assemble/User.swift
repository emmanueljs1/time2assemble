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
    var createdEvents : [String]
    var invitedEvents : [String]
    
    init (_ firstName : String, _ lastName : String, _ email : String, _ id : Int) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
        self.createdEvents = []
        self.invitedEvents = []
    }
    
    func addCreatedEvent (_ eventID : String) {
        createdEvents.append(eventID);
    }
    
    func addInvitedEvent (_ eventID: String) {
        invitedEvents.append(eventID);
    }

    
}
