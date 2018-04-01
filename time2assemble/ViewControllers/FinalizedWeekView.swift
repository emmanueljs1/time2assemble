//
//  FinalizedWeekView.swift
//  time2assemble
//
//  Created by Julia Chun on 4/1/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class FinalizedWeekView: UIViewController {
    
    var finalizedTime: [String: [(Int, Int)]] = [:]
    var user: User!
    var event : Event!
    var eventId: String!
    
    @IBOutlet weak var temporaryButton: UIButton!
    // TODO : Fix so only the sepecific day's info gets passed over
    func onDayviewClick() {
        self.performSegue(withIdentifier: "toDayView", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let finalizeAvailVC = segue.destination as? FinalizeAvailabilityViewController {
            finalizeAvailVC.allFinalizedTime = finalizedTime
            finalizeAvailVC.event = event
            finalizeAvailVC.user = user
        }
    }
}
