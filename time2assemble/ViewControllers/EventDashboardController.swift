//
//  EventDashboardController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class EventDashboardController: UITabBarController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var user : User!
    var username : String!
    private let service = GTLRCalendarService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vcs = viewControllers {
            for vc in vcs {
                if let eventCreationVC = vc as? EventCreationViewController {
                    eventCreationVC.user = user
                }
                if let eventsView = vc as? EventsViewController {
                    eventsView.user = user
                }
                if let settingsView = vc as? SettingsViewController {
                    settingsView.user = user
                }
            }
        }
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
            GIDSignIn.sharedInstance().signInSilently()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //respond to google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("error signing in with gcal from event dashboard")
            print(error)
            // Add the sign-in button.
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
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
    
    
    //obtain response from gcal api, call helper to parse and store in db
    @objc func storeResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            print("error getting events from gcal for user in event dashboard")
            print(error)
            return
        }
        
        GoogleController.setEventsForUser(response, user.id)
    }
}
