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
    
    init (_ firstName : String, _ lastName : String, _ email : String, _ id : Int) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.id = id
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return
            lhs.firstName == rhs.firstName &&
                lhs.lastName == rhs.lastName &&
                lhs.email == rhs.email &&
                lhs.id == rhs.id
    }

}


