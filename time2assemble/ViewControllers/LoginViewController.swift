//
//  ViewController.swift
//  time2assemble
//
//  Created by Julia Chun on 2/12/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    var ref: DatabaseReference!
    @IBOutlet weak var usernameTextField: UITextField!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
//        self.ref.child("users").child("0").setValue(["username": usernameTextField.text])
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: nil) {
            (result, error) -> Void in
            
            //if we have an error display it and abort
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            //make sure we have a result, otherwise abort
            guard let result = result else { return }
            //if cancelled nothing todo
            if result.isCancelled { return }
            else {
                //login successfull, now request the fields we like to have in this case first name and last name
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, id"]).start() {
                    (connection, result, error) in
                    //if we have an error display it and abort
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    //parse the fields out of the result
                    if
                        let fields = result as? [String:Any],
                        let firstName = fields["first_name"] as? String,
                        let lastName = fields["last_name"] as? String,
                        let id = fields["id"] as? String,
                        let email = fields["email"] as? String
                    {
                        self.user = User(firstName, lastName, email, Int(id)!)
                        print("firstName -> \(firstName)")
                        print("lastName -> \(lastName)")
                        print("id -> \(id)")
                        print("email ->\(email)")
                        
                    }
                }
            }
        }
        
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let username = usernameTextField.text {
            if !username.isEmpty {
                self.ref.child("users").child("0").setValue(["username": username])
                performSegue(withIdentifier: "toEventDashboard", sender: sender)
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboard = segue.destination as? EventDashboardController {
            eventDashboard.username = usernameTextField.text
            eventDashboard.user = user
            
        }
    }
    
}

