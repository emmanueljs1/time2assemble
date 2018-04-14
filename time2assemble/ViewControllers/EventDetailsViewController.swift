//
//  EventDetailsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/18/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase
import GoogleAPIClientForREST
import GoogleSignIn

class EventDetailsViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate  {

    let oneHour = 60.0 * 60.0
    
    var user : User!
    var event: Event!
    var ref: DatabaseReference!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var unarchiveButton: UIButton!
    @IBOutlet weak var finalTimeTextView: UITextView!
    @IBOutlet weak var eventCodeTextView: UITextView!
    var source : UIViewController!
    //@IBOutlet weak var addEventToGCalButton: UIButton!
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    //let signInButton = GIDSignInButton()
    @IBOutlet weak var gcalInstructionLabel: UILabel!
    @IBOutlet weak var addToGCalButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        // Do any additional setup after loading the view.
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        //signInButton.center.x = self.view.center.x
        //signInButton.frame.origin.y = gcalInstructionLabel.frame.origin.y + (gcalInstructionLabel.frame.height)
        
        // Add the sign-in button.
        //view.addSubview(signInButton)
        
        //signInButton.isHidden = true //do not show option to add to gcal until event is finalized
        gcalInstructionLabel.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameLabel.text = event.name
        var id = event.id
        id.remove(at: id.startIndex)
        eventCodeTextView.text = id
        
        if (user.id != event.creator) {
            deleteButton.isHidden = true;
        } else {
            deleteButton.isHidden = false;
        }

        if (user.id != event.creator) {
            deleteButton.isHidden = true;
        } else {
            deleteButton.isHidden = false;
        }
        if (type(of: source!) == ArchivedEventsViewController.self) {
            archiveButton.isHidden = true
            unarchiveButton.isHidden = false
        } else {
            archiveButton.isHidden = false
            unarchiveButton.isHidden = true
        }
        
        FirebaseController.getFinalizedEventTimes(event, callback: { (finalizedTimes) in
            if let (date, times) = finalizedTimes.first {
                print(times)
                var finalTimeString = ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateObj = dateFormatter.date(from: date)
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "EEEE, MMMM d"
                finalTimeString += displayFormatter.string(from: dateObj!)
                finalTimeString += "\n"
                if let (start, end) = times.first {
                    let rawTimeFormatter = DateFormatter()
                    rawTimeFormatter.dateFormat = "H"
                    let startTimeObject = rawTimeFormatter.date(from: String(describing: start))
                    let endTimeObject = rawTimeFormatter.date(from: String(describing: end))
                    let displayTimeFormatter = DateFormatter()
                    displayTimeFormatter.dateFormat = "h a"
                    finalTimeString += displayTimeFormatter.string(from: startTimeObject!)
                    finalTimeString += " - "
                    finalTimeString += displayTimeFormatter.string(from: endTimeObject!)
                    //self.signInButton.isHidden = false          //give user option to add to gcal
                    self.gcalInstructionLabel.isHidden = false
                    
                    
                    GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]
                    if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
                        GIDSignIn.sharedInstance().signInSilently()
                    } else {
                        self.gcalInstructionLabel.text = "You can add this event to your calendar by first signing in to Google in Settings."
                    }
                }
                self.finalTimeTextView.text = finalTimeString
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //handle google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            self.gcalInstructionLabel.text = "You can add this event to your calendar by first signing in to Google in Settings."
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            showOptionToAddToCal()
        }
    }
    
    func showOptionToAddToCal() {
        self.gcalInstructionLabel.text = "Add the finalized event to your gcal: "
        addToGCalButton.frame.origin.y = gcalInstructionLabel.frame.origin.y + (gcalInstructionLabel.frame.height)
        addToGCalButton.isHidden = false
        addToGCalButton.addTarget(self, action: #selector(self.addEventToCal), for: .touchUpInside)
    }
    
    // adds the finalized event to the user's gcal
    @objc func addEventToCal() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        FirebaseController.getFinalizedEventTimes(event, callback: { (finalizedTimes) in
            if let (date, times) = finalizedTimes.first {
                var dateObj = dateFormatter.date(from: date)
                if let (start, end) = times.first {
                    //create the event to add
                    let newEvent: GTLRCalendar_Event = GTLRCalendar_Event()
                    
                    //set the event parameters
                    newEvent.summary = self.event.description
                    dateObj! += self.oneHour * Double(start)
                    let startDateTime: GTLRDateTime = GTLRDateTime(date: dateObj!)
                    dateObj! += self.oneHour * Double(end - start)
                    let endDateTime: GTLRDateTime = GTLRDateTime(date: dateObj!)
                    
                    let startEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
                    startEventDateTime.dateTime = startDateTime
                    newEvent.start = startEventDateTime
                    
                    let endEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
                    endEventDateTime.dateTime = endDateTime
                    newEvent.end = endEventDateTime
                    
                    //send request to api
                    let query =
                        GTLRCalendarQuery_EventsInsert.query(withObject: newEvent, calendarId:"primary")
                    self.service.executeQuery(
                        query,
                        completionHandler: {(_ callbackTicket:GTLRServiceTicket,
                            _  event:GTLRCalendar_Event,
                            _ callbackError: Error?) -> Void in
                            self.displayResult(callbackError)
                            }
                            as? GTLRServiceCompletionHandler
                    )
                    self.gcalInstructionLabel.text = "Event added to calendar"
                    self.addToGCalButton.isHidden = true
                }
            }
        })
    }
    
    func displayResult(_ callbackError: Error?) {
        //TODO: if error display error
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
    
    // MARK: - Actions

    @IBAction func onClickArchive(_ sender: Any) {
        FirebaseController.archiveEvent(user, event, callback: {
            self.performSegue(withIdentifier: "toDashboard", sender: self)
        })
    }
    
    // TODO: delete from availabilities as well
    @IBAction func onClickDelete(_ sender: Any) {
        // removes the event from the root database
        self.ref.child("events").child(self.event.id).setValue(nil)
        
        FirebaseController.getUserEvents(user.id, {(invitedEvents, createdEvents, archivedEvents) in
                
            var createdEventIds = createdEvents.map { $0.id }
            createdEventIds = createdEventIds.filter { $0 != self.event.id }
            
            if (createdEventIds.count != createdEvents.count) {
                // removes event from the creator's list of created events
                FirebaseController.writeCreatedEvents(self.user.id, createdEventIds, callback: {() in
                    for i in self.event.invitees {
                        FirebaseController.getUserEvents(i, { (invEvents, creEvents, archEvents) in
                            
                            var dbInvitedEvents = invEvents.map { $0.id }
                            dbInvitedEvents = dbInvitedEvents.filter { $0 != self.event.id }
                            
                            if (dbInvitedEvents.count != invEvents.count) {
                                // removes event from the invitees' list of invited events
                                FirebaseController.writeInvitedEvents(i, dbInvitedEvents, callback: {() in
                                })
                            } else {
                                var dbArchivedEvents = archEvents.map { $0.id }
                                dbArchivedEvents = dbArchivedEvents.filter { $0 != self.event.id }
                                
                                // removes event from the invitees' list of invited events
                                FirebaseController.writeArchivedEvents(i, dbArchivedEvents, callback: {() in
                                })
                            }
                        })
                    }
                })
            } else {
                var archivedEventIds = archivedEvents.map { $0.id }
                archivedEventIds = archivedEventIds.filter { $0 != self.event.id }
                
                FirebaseController.writeArchivedEvents(self.user.id, archivedEventIds, callback: {() in
                    for i in self.event.invitees {
                        FirebaseController.getUserEvents(i, { (invEvents, creEvents, archEvents) in
                            
                            var dbInvitedEvents = invEvents.map { $0.id }
                            dbInvitedEvents = dbInvitedEvents.filter { $0 != self.event.id }
                            
                            if (dbInvitedEvents.count == invEvents.count) {
                                // removes event from the invitees' list of invited events
                                FirebaseController.writeInvitedEvents(i, dbInvitedEvents, callback: {() in
                                })
                            } else {
                                var dbArchivedEvents = archEvents.map { $0.id }
                                dbArchivedEvents = dbArchivedEvents.filter { $0 != self.event.id }
                                
                                // removes event from the invitees' list of invited events
                                FirebaseController.writeArchivedEvents(i, dbArchivedEvents, callback: {() in
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    @IBAction func onClickUnarchive(_ sender: Any) {
        FirebaseController.getUserEvents(user.id, { (invitedEvents, createdEvents, archivedEvents) in
            let newArchivedEvents = archivedEvents.filter { $0.id != self.event.id }
            let newArchivedEventIds = newArchivedEvents.map { $0.id }
            FirebaseController.writeArchivedEvents(self.user.id, newArchivedEventIds, callback: {() in
                if (self.event.creator == self.user.id) {
                    var newCreatedEvents = createdEvents.map { $0.id }
                    newCreatedEvents = newCreatedEvents + [self.event.id]
                    FirebaseController.writeCreatedEvents(self.user.id, newCreatedEvents, callback: { () in
                        self.performSegue(withIdentifier: "toArchived", sender: self)
                    })
                } else {
                    var newInvitedEvents = invitedEvents.map { $0.id }
                    newInvitedEvents = newInvitedEvents + [self.event.id]
                    FirebaseController.writeInvitedEvents(self.user.id, newInvitedEvents, callback: { () in
                        self.performSegue(withIdentifier: "toArchived", sender: self)
                     })
                }
            })
        })
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        if (type(of: source!) == ArchivedEventsViewController.self) {
            performSegue(withIdentifier: "toArchived", sender: self)
        } else {
            performSegue(withIdentifier: "toDashboard", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
        }
        if let fillAvailVC = segue.destination as? FillAvailViewController {
            fillAvailVC.event = event
            fillAvailVC.user = user
            fillAvailVC.eventBeingCreated = false
        }
        if let eventAvailabilitiesVC = segue.destination as? EventAvailabilitiesViewController {
            eventAvailabilitiesVC.user = user
            eventAvailabilitiesVC.event = event
            eventAvailabilitiesVC.source = source
        }
        if let archivedEventsVC = segue.destination as? ArchivedEventsViewController {
            archivedEventsVC.user = user
        }
    }
}
