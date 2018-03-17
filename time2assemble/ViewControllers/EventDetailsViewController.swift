//
//  EventDetailsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
        }
    }

}
