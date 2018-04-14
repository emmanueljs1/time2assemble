//
//  EventNotification.swift
//  time2assemble
//
//  Created by Jane Xu on 4/14/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import Foundation

class EventNotification {
    
    var sender : Int
    var receiver : Int
    var type : NotificationType
    var eventID : String
    
    init (_ sender : Int, _ receiver : Int, _ type : NotificationType, _ eventID : String) {
        
        self.sender = sender
        self.receiver = receiver
        self.type = type
        self.eventID = eventID
    }
}

