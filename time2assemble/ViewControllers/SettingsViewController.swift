//
//  SettingsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleAPIClientForREST
import GoogleSignIn
import Firebase

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var user: User!
    var ref: DatabaseReference!
    @IBOutlet weak var gcalInstructionsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = "Name: " + user.firstName + " " + user.lastName
        emailLabel.text = "Email: " + user.email
        // Facebook Login
        let logoutButton = FBSDKLoginButton()
        logoutButton.center = view.center
        logoutButton.readPermissions = ["public_profile", "email", "user_friends"]
        logoutButton.delegate = self
        view.addSubview(logoutButton)
        
        ref = Database.database().reference()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            self.gcalInstructionsLabel.isHidden = true //has already signed in once, does not need further options
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            self.signInButton.center.x = self.view.center.x
            self.signInButton.frame.origin.y = self.gcalInstructionsLabel.frame.origin.y + (self.gcalInstructionsLabel.frame.height)
            
            // Add the sign-in button.
            self.view.addSubview(self.signInButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            if result.grantedPermissions.contains("email")
            {
                performSegue(withIdentifier: "toEventDashboard", sender: self)
            }
        }
    }
    
    //handle logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        performSegue(withIdentifier: "toLoginScreen", sender: self)
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        //will never happen; user cannot log in from Settings
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    //respond to google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            self.gcalInstructionsLabel.isHidden = false
            self.service.authorizer = nil
            self.signInButton.center.x = self.view.center.x
            self.signInButton.frame.origin.y = self.gcalInstructionsLabel.frame.origin.y + (self.gcalInstructionsLabel.frame.height)
            // Add the sign-in button.
            self.view.addSubview(self.signInButton)
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            gcalInstructionsLabel.text = "You have authenticated with gCal"
            FirebaseController.writeGCalAccessToken(self.user.id, user.authentication.accessToken,user.authentication.refreshToken)
            fetchEvents()
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        service.shouldFetchNextPages = true
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(storeResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    
    //obtain response from gcal api, call helper to parse and store in db
    @objc func storeResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }

        GoogleController.setEventsForUser(response, user.id)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}

