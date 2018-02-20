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

        selectedIndex = 1
        
        if let vcs = viewControllers {
            for vc in vcs {
                if let eventCreationVC = vc as? EventCreationViewController {
                    eventCreationVC.parentTabBar = self
                    eventCreationVC.user = user
                }
                if let eventsView = vc as? EventsViewController {
                    eventsView.user = user
                }
                if let settingsView = vc as? SettingsViewController {
                    settingsView.user = user
                }
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventCreationVC = segue.destination as? EventCreationViewController {
            eventCreationVC.user = user
        }
        if let eventsView = segue.destination as? EventsViewController {
            eventsView.user = user
        }
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    }


}
