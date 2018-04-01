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
    var user: User!
    var fbLoginSuccess = false
    
    func loadUser(withSegue: Bool) {
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
                let email = fields["email"] as? String {
                
                self.ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
                    let dict = snapshot.value as? NSDictionary ?? [:]
                    
                    if dict.count == 0 {
                        
                        self.ref.child("users").child(String(id)).updateChildValues(
                            ["firstName" : firstName,
                             "lastName" : lastName,
                             "email" : email,
                             "archivedEvents" : [String](),
                             "invitedEvents" : [String](),
                             "createdEvents" : [String]()
                            ])
                        
                        self.user = User(firstName, lastName, email, Int(id)!, [], [], [])
                        
                    } else {
                        
                        var invitedEvents = [String]()
                        var createdEvents = [String]()
                        var archivedEvents = [String]()
                        
                        if let dbInvitedEvents = dict["invitedEvents"] as? [String] {
                            invitedEvents = dbInvitedEvents
                        }
                        if let dbCreatedEvents = dict["createdEvents"] as? [String] {
                            createdEvents = dbCreatedEvents
                        }
                        if let dbArchivedEvents = dict["archivedEvents"] as? [String] {
                            archivedEvents = dbArchivedEvents
                        }
                        
                        self.user = User(firstName, lastName, email, Int(id)!, archivedEvents, invitedEvents, createdEvents)
                    }
                    
                    if withSegue {
                        self.performSegue(withIdentifier: "toEventDashboard", sender: self)
                    }
                    
                }) { (error) in
                    print("I have no idea why this error would occur")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
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
            loadUser(withSegue: true)
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
                //TODO: save these permissions so they don't have to approve everytime they login
                //login successful, now request the fields we like to have in this case first name and last name
                loadUser(withSegue: true)
                fbLoginSuccess = true
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        fbLoginSuccess = false
        // TODO: handle logout
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboard = segue.destination as? EventDashboardController {
            if fbLoginSuccess {
                let user = self.user
                //self.show(eventDashboard, sender: self)
                eventDashboard.user = user
                eventDashboard.selectedIndex = 1
            }
        }
    }
    
}

