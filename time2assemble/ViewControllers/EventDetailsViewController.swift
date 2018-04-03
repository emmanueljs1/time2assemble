//
//  EventDetailsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/18/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {

    var user : User!
    var event: Event!
    var ref: DatabaseReference!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var unarchiveButton: UIButton!
    @IBOutlet weak var finalTimeLabel: UILabel!
    @IBOutlet weak var eventCodeTextView: UITextView!
    var source : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        // Do any additional setup after loading the view.
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
        if (event.finalizedTime.values.joined().isEmpty) {
            finalTimeLabel.text = "Not yet finalized"
        } else {
            let finalizedTimes = "123" //TODO: fix
            finalTimeLabel.text = finalizedTimes
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    @IBAction func onClickArchive(_ sender: Any) {
        FirebaseController.archiveEvent(user, event, callback: {
            self.performSegue(withIdentifier: "toDashboard", sender: self)
        })
    }
    
    // TODO: delete from archivedEvents as well!
    @IBAction func onClickDelete(_ sender: Any) {
        // removes the event from the root database
        self.ref.child("events").child(self.event.id).setValue(nil)
        
        FirebaseController.getUserEvents(user.id, callback: {(invitedEvents, createdEvents, archivedEvents) in
                
            var createdEventIds = createdEvents.map { $0.id }
            createdEventIds = createdEventIds.filter { $0 != self.event.id }
            
            if (createdEventIds.count != createdEvents.count) {
                // removes event from the creator's list of created events
                FirebaseController.writeCreatedEvents(self.user.id, createdEventIds, callback: {() in
                    for i in self.event.invitees {
                        FirebaseController.getUserEvents(i, callback: { (invEvents, creEvents, archEvents) in
                            
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
                        FirebaseController.getUserEvents(i, callback: { (invEvents, creEvents, archEvents) in
                            
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
        FirebaseController.getUserEvents(user.id, callback: { (invitedEvents, createdEvents, archivedEvents) in
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
            eventDashboardVC.selectedIndex = 1
        }
        if let fillAvailVC = segue.destination as? FillAvailViewController {
            fillAvailVC.event = event
            fillAvailVC.user = user
            fillAvailVC.eventBeingCreated = false
        }
        if let eventAvailabilitiesVC = segue.destination as? EventAvailabilitiesViewController {
            eventAvailabilitiesVC.user = user
            eventAvailabilitiesVC.event = event
        }
        if let archivedEventsVC = segue.destination as? ArchivedEventsViewController {
            archivedEventsVC.user = user
        }
    }
}
