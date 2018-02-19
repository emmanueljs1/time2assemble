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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var ref: DatabaseReference!
    @IBOutlet weak var usernameTextField: UITextField!
    var user: User!
    var fbLoginSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        if (FBSDKAccessToken.current() != nil)
        {
          fbLoginSuccess = true
        }
//        self.ref.child("users").child("0").setValue(["username": usernameTextField.text])
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true)
        {
            // User is already logged in, do work such as go to next view controller.
            performSegue(withIdentifier: "toEventDashboard", sender: self)
        }
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
    
    // Facebook Delegate Methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("here we are at the callback")
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            print("here we are with no error")
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
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
                fbLoginSuccess = true
                print("here we are time to segue")
                performSegue(withIdentifier: "toEventDashboard", sender: self)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        fbLoginSuccess = false
        //handle logout
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("here we are preparing to segue")
        if let eventDashboard = segue.destination as? EventDashboardController {
            if fbLoginSuccess {
                self.show(eventDashboard, sender: self)
                print("here we are!!! seguing!!!")
                eventDashboard.username = usernameTextField.text
            }
        }
    }
    
}

