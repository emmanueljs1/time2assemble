//
//  EventNotification.swift
//  time2assemble
//
//  Created by Jane Xu on 4/14/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import Foundation

class EventNotification {
    
    var sender : String // sender's name
    var receiver : Int  // receiver's ID
    var type : NotificationType.NotificationType
    var eventID : String
    var read : Bool
    var eventName : String
    var id : String = "-1" //dummy value, only populated when list is retrieved from db
    
    init (_ sender : String, _ receiver : Int, _ type : NotificationType.NotificationType, _ eventID : String, _ read : Bool, _ eventName : String) {
        
        self.sender = sender
        self.receiver = receiver
        self.type = type
        self.eventID = eventID
        self.read = read
        self.eventName = eventName
    }
}

