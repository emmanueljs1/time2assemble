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
    
    let notificationsTabBarIndex = 3
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
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        FirebaseController.getNotificationsForUser(user.id, callback: { (notifications) in
            var unreadNotifsCount = 0
            for notification in notifications {
                if !notification.read {
                    unreadNotifsCount += 1
                }
            }
            if unreadNotifsCount > 0, let items = self.tabBar.items {
                items[self.notificationsTabBarIndex].badgeColor = .red
                items[self.notificationsTabBarIndex].badgeValue = String(unreadNotifsCount)
            }
            else if let items = self.tabBar.items {
                items[self.notificationsTabBarIndex].badgeValue = nil
            }
        })
    }

}
