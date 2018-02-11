//
//  ViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/7/18.
//  Copyright © 2018 Emmanuel Suarez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func logInButtonClicked(_ sender: Any) {
        if let usernameString = username.text {
            if !usernameString.isEmpty {
                performSegue(withIdentifier: "toEventDashboardView", sender: sender)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboardVC = segue.destination as? EventDashboardViewController {
            eventDashboardVC.username = username.text
        }
    }
    
    
}

