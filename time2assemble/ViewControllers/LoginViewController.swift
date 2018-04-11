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
import GoogleAPIClientForREST
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    var ref: DatabaseReference!
    var user: User!
    var fbLoginSuccess = false
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    
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
                
                FirebaseController.getGCalAccessToken(self.user.id) { (accessToken, refreshToken) in
                    if (accessToken != "" && refreshToken != "") {
                        //todo refresh access and then sign in
                        GIDSignIn.sharedInstance().signInSilently()
                    }
                }
                
                FirebaseController.registerUser(firstName, lastName, Int(id)!, email, callback: {
                    self.performSegue(withIdentifier: "toEventDashboard", sender: self)
                })
            }
        }
    }
    
    //respond to google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            print("here is the self.service.authorizer from logging in: ")
            print(self.service.authorizer ?? "")
            FirebaseController.writeGCalAccessToken(self.user.id, user.authentication.accessToken,user.authentication.refreshToken)
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
        
        if let _ = error {
            return
        }
        
        var eventsDict : Dictionary = [String: [Int : String]] ()
        if let events = response.items, !events.isEmpty {
            for event in events {
                //parse event
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
                
                //determine if event runs over into next hour (eg does it end at 11 or 11:30?
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
                    if (endInt! <= startInt!) {
                        continue
                    }
                    for index in startInt!...endInt! {
                        hourToEventNameMap[index] = description
                    }
                    eventsDict[String(date)] = hourToEventNameMap
                }
            }
        }
        Availabilities.setCalEventsForUser(String(user.id), eventsDict)
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
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
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

