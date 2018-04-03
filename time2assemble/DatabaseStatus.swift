//
//  DatabaseError.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 4/2/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

class DatabaseStatus {
    enum InviteStatus {
        case eventNotFound
        case userIsCreator
        case noError
        case userAlreadyInvited
    }
}
