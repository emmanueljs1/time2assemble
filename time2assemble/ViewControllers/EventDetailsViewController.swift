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
    @IBOutlet weak var eventCodeLabel: UITextField!
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
        eventCodeLabel.text = id
        
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
        // removes event from the creator's list of created events
        print(String(event.creator))
        print(event.id)
        ref.child("users").child(String(event.creator)).child("createdEvents").observeSingleEvent(of: .value, with: {(snapshot) in
            
            var createdEvents = snapshot.value as? [String] ?? []
            
            createdEvents = createdEvents.filter { $0 != self.event.id }
            
            print(createdEvents)
            self.ref.child("users").child(String(self.event.creator)).child("createdEvents").setValue(createdEvents)
        })
        
        print(event.invitees)
        
        // removes event from the invitees' list of invited events
        for i in event.invitees {
            ref.child("users").child(String(event.creator)).child("invitedEvents").observeSingleEvent(of: .value, with: {(snapshot) in
                
                var invitedEvents = snapshot.value as? [String] ?? []
                
                invitedEvents = invitedEvents.filter { $0 != self.event.id }
                self.ref.child("users").child(String(self.event.creator)).child("invitedEvents").setValue(invitedEvents)
            })
            
            print("deleted for \(i)")
        }
        
        // removes the event from the root database
        ref.child("events").child(event.id).setValue(nil)
    }
    
    @IBAction func onClickUnarchive(_ sender: Any) {
        FirebaseController.getUserEvents(user, callback: { (invitedEvents, createdEvents, archivedEvents) in
            let newArchivedEvents = archivedEvents.filter { $0.id != self.event.id }
            let newArchivedEventIds = newArchivedEvents.map { $0.id }
            FirebaseController.writeArchivedEvents(self.user, newArchivedEventIds, callback: {() in
                if (self.event.creator == self.user.id) {
                    var newCreatedEvents = createdEvents.map { $0.id }
                    newCreatedEvents = newCreatedEvents + [self.event.id]
                    FirebaseController.writeCreatedEvents(self.user, newCreatedEvents, callback: { () in
                        self.performSegue(withIdentifier: "toArchived", sender: self)
                    })
                } else {
                    var newInvitedEvents = invitedEvents.map { $0.id }
                    newInvitedEvents = newInvitedEvents + [self.event.id]
                    FirebaseController.writeInvitedEvents(self.user, newInvitedEvents, callback: { () in
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
