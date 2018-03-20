//
//  Availabilities.swift
//  time2assemble
//
//  Created by Hana Pearlman on 3/20/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation
import Firebase

class Availabilities {
    class func getAllEventAvailabilities(_ eventID: String) -> Int {
        return 2
    }
    
    class func getEventAvailabilitiesForUser (_ eventID: String, _ userID: String) -> [(String, Int, Int)] {
        let ref = Database.database().reference()
        var avails = [(String, Int, Int)] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            if let user_avails = dict[userID] as? [(String, Int, Int)] {
                avails = user_avails
            }
        }) { (error) in
            print("error finding availabilities")
        }
        return avails
    }
    
    class func setEventAvailabilitiesForUSer (_ eventID: String, _ userID: String, _ availabilities: [(String, Int, Int)]) {
        let ref = Database.database().reference()
        let refAvails = ref.child("availabilities")
        let refEvent = refAvails.child(eventID)
        refEvent.updateChildValues([userID : availabilities])
    }
}
