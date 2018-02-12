//
//  ViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/7/18.
//  Copyright © 2018 Emmanuel Suarez. All rights reserved.
//

import UIKit

class EventDashboardViewController: UIViewController {
    
    @IBOutlet weak var sideBarLeft: NSLayoutConstraint!
    var menuShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        if (menuShowing) {
            sideBarLeft.constant = -140;
        } else {
            sideBarLeft.constant = 0;
        }
        
        menuShowing = !menuShowing
    }
    
}
