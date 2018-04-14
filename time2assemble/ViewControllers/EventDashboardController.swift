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
    
    let tabBarImages = [UIImage(named: "list.png"), UIImage(named: "plus.png"), UIImage(named: "settings.png"), UIImage(named: "bell.png")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        scheduleNotificationChecker()
        
        if let items = tabBar.items {
            var i = 0
            for item in items {
                item.image = tabBarImages[i]
                i += 1
            }
        }
        
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
                if let notificationsVC = vc as? NotificationsViewController {
                    // TODO: uncomment?
                    // notificationsVC.user = user
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
//        if let items = tabBar.items {
//            items[3].badgeValue = ""
//            items[3].badgeColor = .red
//        }
    }

}
