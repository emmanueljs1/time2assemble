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
//Welcome page; lets user log in with facebook
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var user: User!
    var fbLoginSuccess = false
    
    func loadUser() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, id"]).start() {
            (connection, result, error) in
            //if we have an error display it and abort
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            //parse the fields out of the result
            if
                let fields = result as? [String: Any],
                let firstName = fields["first_name"] as? String,
                let lastName = fields["last_name"] as? String,
                let id = fields["id"] as? String,
                let email = fields["email"] as? String {
                
                self.user = User(firstName, lastName, email, Int(id)!)
                
                FirebaseController.registerUser(firstName, lastName, Int(id)!, email, callback: {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            print("Error authenticating: \(error)")
                        }
                        self.performSegue(withIdentifier: "toEventDashboard", sender: self)
                    }
                })
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if a user has logged in before, do not need to grant permission again
        if (FBSDKAccessToken.current() != nil && !fbLoginSuccess) {
            fbLoginSuccess = true
        }
        
        // Facebook Login
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil) {
            // User is already logged in, do work such as go to next view controller.
            loadUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Facebook Delegate Methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                //login successful, now request the fields we like to have in this case first name and last name
                loadUser()
                fbLoginSuccess = true
            }
        }
    }
    

    //will never be called from the login page but needed for interface
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        fbLoginSuccess = false
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboard = segue.destination as? EventDashboardController {
            if fbLoginSuccess {
                let user = self.user
                eventDashboard.user = user
            }
        }
    }
    
}

