//
//  SignupViewController.swift
//  time2assemble
//
//  Created by Hana Pearlman on 2/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    var ref: DatabaseReference!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onSignupClick(_ sender: Any) {
        if let username = usernameTextField.text {
            if !username.isEmpty {
                let refUsers = self.ref.child("users")
                let refUser = refUsers.childByAutoId()
                let userId = refUser.key
                refUsers.child(userId).setValue([
                    "username": usernameTextField.text!,
                    "password": passwordTextField.text!])

                performSegue(withIdentifier: "toEventDashboard", sender: sender)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboard = segue.destination as? EventDashboardController {
            eventDashboard.username = usernameTextField.text
        }
    }

}
