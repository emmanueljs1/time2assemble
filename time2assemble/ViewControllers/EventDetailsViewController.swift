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

//Show details of event to user, and option to archive/delete, fill availability, add to calendar, and finalize time
class EventDetailsViewController:  UIViewController, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let oneHour = 60.0 * 60.0
    
    var user : User!
    var event: Event!
    var ref: DatabaseReference!
    var participants: [User]!
    var completed: Bool!
    var lookingAtFinalized: Bool = false
    var hasFinalizedTime: Bool = false
    
    var availabilities: [String: [Int: Int]] = [:]
    var availableUsers: [String :[Int:[User]]] = [:]
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    // Event Description
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = -1
    var dataArray: [[String: String]] = [["Type":           "Description", "Content":""],
                                         ["Type": "Event Code", "Content":"Send this code to invite your friends to this event!"],
                                         ["Type": "Invitees", "Content":""],
                                         ["Type": "Finalized Time", "Content":"Not Yet Finalized"]]
    
    // GCal
    var source : UIViewController!
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton()
    @IBOutlet weak var gcalInstructionLabel: UILabel!
    @IBOutlet weak var addToGCalButton: UIButton!
    
    // Actions
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var unarchiveButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = Database.database().reference();
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Configure Google Sign-in for silent sign in, so we can add the event to their calendar
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        //don't show instructions to add to calendar until after we verify event is finalized
        gcalInstructionLabel.isHidden = true
        completed = false
        acceptButton.isHidden = true;
        rejectButton.isHidden = true;
        
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
            
            Availabilities.getAllAvailUsers(self.event.id, callback: { (availableUsers) -> () in
                
                self.availableUsers = availableUsers
            })
        })
        
    }
    
    func showAcceptRejectButtons() {
        //don't show accept/reject option if user is owner
        if (self.event.creator == self.user.id) {
            self.acceptButton.isHidden = true;
            self.rejectButton.isHidden = true;
            return;
        }
        if (!hasFinalizedTime) {
            self.acceptButton.isHidden = true;
            self.rejectButton.isHidden = true;
            return;
        }
        //don't show accept/reject option if the user has not selected the finalize table component
        if !(lookingAtFinalized) {
            self.acceptButton.isHidden = true;
            self.rejectButton.isHidden = true;
            return;
        }
        
        FirebaseController.getFinalTimeResponses(event.id, { (accepted: [Int], rejected: [Int]) in
            //don't show accept/reject option if the user has already accepted or rejected this time
            if (accepted.contains(self.user.id) || rejected.contains(self.user.id)) {
                self.acceptButton.isHidden = true;
                self.rejectButton.isHidden = true;
            } else {
                //otherwise, show option
                self.acceptButton.isHidden = false;
                self.rejectButton.isHidden = false;
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        eventNameLabel.text = event.name
        
        var id = event.id
        id.remove(at: id.startIndex)
        self.dataArray[1]["Content"] = id
        
        //show delete button if user is creator, otherwise hide
        if (user.id != event.creator) {
            deleteButton.isHidden = true;
        } else {
            deleteButton.isHidden = false;
        }
        
        //show button to archive or unarchive event
        if (type(of: source!) == ArchivedEventsViewController.self) {
            archiveButton.isHidden = true
            unarchiveButton.isHidden = false
        } else {
            archiveButton.isHidden = false
            unarchiveButton.isHidden = true
        }
        
        acceptButton.isHidden = true;
        rejectButton.isHidden = true;
        
        FirebaseController.getFinalizedEventTimes(event, callback: { (finalizedTimes) in
            //attempt to get finalized event time from db, if it has been finalized
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
                
                var displayString = "You can add this event to your calendar by\nfirst signing in to Google in Settings\n"
                
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
                    self.hasFinalizedTime = true
                    //give user option to add to gcal
                    self.gcalInstructionLabel.isHidden = false
                    
                    //sign in silently to gcal if user has gcal enabled
                    GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]
                    if GIDSignIn.sharedInstance().hasAuthInKeychain() == true{
                        // TODO: FIX
                        displayString = ""
                        GIDSignIn.sharedInstance().signInSilently()
                    }
                }
                
                displayString += finalTimeString
                self.dataArray[3]["Content"] = displayString
            }
            
            //get all invitees from database to show in "Invitees" content box
            Availabilities.getAllParticipants(self.event.id, callback: { (participants, done) -> () in
                self.participants = participants
                self.completed = done
                
                if self.completed {
                    var invitees = ""
                    var count = 1
                    for user in participants {
                        if count != participants.count {
                            invitees += user.firstName + " "  + user.lastName + "\n"
                        }
                        count += 1
                    }
                    
                    self.dataArray[2]["Content"] = invitees
                }
            })
        })
        
        self.dataArray[0]["Content"] = event.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table Display
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(selectedIndex == indexPath.row) {
            return 140;
        } else {
            return 40;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! customTableViewCell
        cell.infoLabel.numberOfLines = 0
        let obj = dataArray[indexPath.row]
        cell.titleLabel.text = obj["Type"]
        cell.infoLabel.text = obj["Content"]
        UIPasteboard.general.string = dataArray[indexPath.row]["Content"]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            lookingAtFinalized = !lookingAtFinalized //toggle whether user is looking at row 3
            showAcceptRejectButtons() //helper function to determine whether or not to show accept/reject buttons
        } else {
            rejectButton.isHidden = true
            acceptButton.isHidden = true
        }
        
        if(selectedIndex == indexPath.row) {
            selectedIndex = -1
        } else {
            selectedIndex = indexPath.row
        }
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic )
        self.tableView.endUpdates()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: - Google Calendar Integration
    
    //handle google sign in, silent
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            showOptionToAddToCal()
        }
    }
    
    //show user option to add finalized event to their calendar if they have not done so already
    func showOptionToAddToCal() {
        FirebaseController.getUsersWhoAddedToGCal(event.id) { (userList) in
            if (!userList.contains(self.user.id)) {
                self.gcalInstructionLabel.text = "Add the finalized event to your gcal: "
                self.addToGCalButton.frame.origin.y = self.gcalInstructionLabel.frame.origin.y + (self.gcalInstructionLabel.frame.height)
                self.addToGCalButton.isHidden = false
                self.addToGCalButton.addTarget(self, action: #selector(self.addEventToCal), for: .touchUpInside)
            }
        }
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
                    newEvent.summary = self.event.name
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
        FirebaseController.setUserAddedToGCal(user.id, event.id)
    }
    
    //display error if there was an error
    func displayResult(_ callbackError: Error?) {
        showAlert(title: "Error", message: "An error occurred when getting your calendar from Google: " + callbackError.debugDescription)
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
    
    @IBAction func onClickDelete(_ sender: Any) {
        // removes the event from the root database after notifications are sent to all invitees
        FirebaseController.sendNotificationForDeletedEvent(self.event, callback: {
            self.ref.child("events").child(self.event.id).setValue(nil)
        })
        
        //remove event from creator's db info and invitees db info
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
        
        //also delete any availabilities recorded for the event from the db
        Availabilities.clearAvailabilitiesForEvent(event.id)
    }
    
    @IBAction func onClickAcceptTime(_ sender: Any) {
        FirebaseController.acceptFinalizedTime(user.id, self.event)
    }

    @IBAction func onClickRejectTime(_ sender: Any) {
        FirebaseController.denyFinalizedTime(user.id, self.event)
    }
    
    //archive an event by removing from user's list of invited events and adding to archived events list
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
            fillAvailVC.participants = participants
            fillAvailVC.availabilities = availabilities
            fillAvailVC.availableUsers = availableUsers
            
            fillAvailVC.source = source
        }
        if let eventAvailabilitiesVC = segue.destination as? EventAvailabilitiesViewController {
            eventAvailabilitiesVC.user = user
            eventAvailabilitiesVC.event = event
            eventAvailabilitiesVC.source = source
            eventAvailabilitiesVC.participants = participants
        }
        if let archivedEventsVC = segue.destination as? ArchivedEventsViewController {
            archivedEventsVC.user = user
        }
    }
    
}

