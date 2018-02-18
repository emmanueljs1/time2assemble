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
    @IBOutlet weak var passwordTextField: UITextField!
    var fbLoginSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        if (FBSDKAccessToken.current() != nil)
        {
            //fbLoginSuccess = true
        }
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true)
        {
            // User is already logged in, do work such as go to next view controller.
            performSegue(withIdentifier: "toEventDashboard", sender: self)
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
                fbLoginSuccess = true
                print("here we are time to segue")
                performSegue(withIdentifier: "toEventDashboard", sender: self)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        FBSDKAccessToken.current()
        //handle logout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let username = usernameTextField.text {
            if !username.isEmpty {
                if let password = passwordTextField.text {
                    if !password.isEmpty {
                        self.ref.child("users").child(username).setValue(["password": password])
                        performSegue(withIdentifier: "toEventDashboard", sender: sender)
                    }
                }
                
            }
        }
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

