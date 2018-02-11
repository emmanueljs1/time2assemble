//
//  ViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/7/18.
//  Copyright © 2018 Emmanuel Suarez. All rights reserved.
//

import UIKit

class EventDashboardViewController: UIViewController {
    
    var username : String!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Welcome " + username + "!"
        label.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
