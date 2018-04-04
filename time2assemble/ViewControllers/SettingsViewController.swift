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
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        signInButton.center.x = self.view.center.x
        signInButton.frame.origin.y = gcalInstructionsLabel.frame.origin.y + (gcalInstructionsLabel.frame.height)
        
        // Add the sign-in button.
        view.addSubview(signInButton)
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        performSegue(withIdentifier: "toLoginScreen", sender: self)
        //handle logout
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        //will never happen
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(storeResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    
    // Display the start dates and event summaries in the UITextView
    @objc func storeResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var eventsDict : Dictionary = [String: [Int : String]] ()
        if let events = response.items, !events.isEmpty {
            for event in events {
                //let event_id = event.identifier!
                let description = event.summary!
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = "\(start.date)" //eg, 2018-04-05 15:30:00
                
                let dateIndex = startString.index(startString.startIndex, offsetBy: 10)
                let date = startString.prefix(upTo: dateIndex)
                
                let hourStart = startString.index(startString.startIndex, offsetBy: 11)
                let hourEnd = startString.index(startString.endIndex, offsetBy: -12)
                let hourStartString = String(startString.prefix(upTo: hourEnd)) // eg, 2018-04-05 15
                let startInt = Int(String(hourStartString.suffix(from: hourStart)))    // eg, 15
                
                let end = event.end!.dateTime ?? event.end!.date!
                let endString = "\(end.date)"
                let hourEndString = String(endString.prefix(upTo: hourEnd))
                var endInt = Int(String(hourEndString.suffix(from: hourStart)))
                
                let endHourRunOver = endString.index(endString.endIndex, offsetBy: -10)
                let runOverInt = Int(String(endString[endHourRunOver]))
                if (runOverInt! == 0) {
                    endInt! = endInt! - 1;
                }
                
                //TODO: add support for multi-date events
                
                if let hourToEventNameMap = eventsDict[String(date)] {
                    if (endInt! >= startInt!) {
                        for index in startInt!...endInt! {
                            if let _ = hourToEventNameMap[index] {
                                //do nothing; there's already something in the map at that time
                            } else {
                                eventsDict[String(date)]![index] = description
                            }
                        }
                    }
                    
                } else {
                    var hourToEventNameMap : Dictionary = [Int: String] ()
                    for index in startInt!...endInt! {
                        hourToEventNameMap[index] = description
                    }
                    eventsDict[String(date)] = hourToEventNameMap
                }
            }
        }
        gcalInstructionsLabel.text = "Succesfully retrieved events from gCal!"
        Availabilities.setCalEventsForUser(String(user.id), eventsDict)
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

