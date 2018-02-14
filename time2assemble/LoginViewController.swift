//
//  ViewController.swift
//  time2assemble
//
//  Created by Julia Chun on 2/12/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let username = usernameTextField.text {
            if !username.isEmpty {
                performSegue(withIdentifier: "toEventDashboard", sender: sender)
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboard = segue.destination as? EventDashboardController {
            
        }
    }
    
}

