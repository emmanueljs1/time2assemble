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
    var integratedGCal : Bool
    
    init (_ firstName : String, _ lastName : String, _ email : String, _ id : Int, _ invitedEvents : [String], _ createdEvents : [String]) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
        self.createdEvents = createdEvents
        self.invitedEvents = invitedEvents
        self.integratedGCal = false;
        self.integratedGCal = hasGCalIntegration()
    }
    
    func hasGCalIntegration() -> Bool {
        //TODO: add request to DB to see if user has integrated gcal
        return true
    }
    
    func addCreatedEvent (_ eventID : String) {
        createdEvents.append(eventID);
    }
    
    func addInvitedEvent (_ eventID: String) {
        invitedEvents.append(eventID);
    }

    
}
