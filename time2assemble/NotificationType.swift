//
//  NotificationType.swift
//  time2assemble
//
//  Created by Jane Xu on 4/14/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import Foundation

//Notification enum types
class NotificationType {
    enum NotificationType : Int {
        case eventDeleted = 1
        case eventJoined = 2
        case eventFinalized = 3
        case allInviteesResponded = 4 //when all invitees either accept or reject a finalized time
    }
}

