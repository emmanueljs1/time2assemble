//
//  User.swift
//  time2assemble
//
//  Created by Julia Chun on 2/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class User : Equatable {
    
    var firstName : String
    var lastName : String
    var email : String
    var id : Int
    var integratedGCal : Bool
    
    init (_ firstName : String, _ lastName : String, _ email : String, _ id : Int) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
        self.integratedGCal = false;
        self.integratedGCal = hasGCalIntegration()
    }
    
    func hasGCalIntegration() -> Bool {
        //TODO: add request to DB to see if user has integrated gcal
        return true
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return
            lhs.firstName == rhs.firstName &&
                lhs.lastName == rhs.lastName &&
                lhs.email == rhs.email &&
                lhs.id == rhs.id
    }

}


