//
//  EventDashboardController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class EventDashboardController: UITabBarController, UITabBarControllerDelegate {
    
    var timer : Timer!
    var user : User!
    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        scheduleNotificationChecker()
        
        if let vcs = viewControllers {
            for vc in vcs {
                if let eventCreationVC = vc as? EventCreationViewController {
                    eventCreationVC.user = user
                }
                if let eventsVC = vc as? EventsViewController {
                    eventsVC.user = user
                }
                if let settingsView = vc as? SettingsViewController {
                    settingsView.user = user
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    
    func scheduleNotificationChecker() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        //tabBar.items
    }

}
