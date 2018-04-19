//
//  EventDashboardController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class EventDashboardController: UITabBarController {
    
    var user : User!
    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vcs = viewControllers {
            for vc in vcs {
                if let eventCreationVC = vc as? EventCreationViewController {
                    eventCreationVC.user = user
                }
                if let eventsView = vc as? EventsViewController {
                    eventsView.user = user
                }
                if let settingsView = vc as? SettingsViewController {
                    settingsView.user = user
                }
                if let notificationsView = vc as? NotificationsViewController {
                    notificationsView.user = user
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
