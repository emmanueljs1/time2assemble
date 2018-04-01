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
    @IBOutlet weak var eventCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        if (user.id != event.creator) {
            deleteButton.isHidden = true;
        } else {
            deleteButton.isHidden = false;
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameLabel.text = event.name
        if (user.id != event.creator) {
            deleteButton.isHidden = true;
        } else {
            deleteButton.isHidden = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    @IBAction func onClickArchive(_ sender: Any) {
        // add the archived event to the user object
        user.addArchivedEvent(event.id)
        
        let reference =  ref.child("users").child(String(user.id))
        
        // in the users db, add the event to the list of archivedEvents
        reference.child("archivedEvents").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // get the
            var dbArchivedEvents = snapshot.value as? [String] ?? [String]()
            dbArchivedEvents.append(self.event.id)
            
            // add the updated archived events to the database
            reference.child("archivedEvents").setValue(dbArchivedEvents)
            
            // now remove it from the right list
            if (self.event.creator == self.user.id) {
                reference.child("createdEvents").observeSingleEvent(of: .value, with: { (snapshot) in
                    var dbCreatedEvents = snapshot.value as? [String] ?? [String]()
                    
                    dbCreatedEvents = dbCreatedEvents.filter { $0 != self.event.id }
                    
                    reference.child("createdEvents").setValue(dbCreatedEvents)
                    
                    self.performSegue(withIdentifier: "toDashboard", sender: self)
                })
            } else {
                reference.child("invitedEvents").observeSingleEvent(of: .value, with: { (snapshot) in
                    var dbInvitedEvents = snapshot.value as? [String] ?? [String]()
                    
                    dbInvitedEvents = dbInvitedEvents.filter { $0 != self.event.id }
                    
                    reference.child("invitedEvents").setValue(dbInvitedEvents)
                    
                    self.performSegue(withIdentifier: "toDashboard", sender: self)
                })
            }
            
        })
    }
    
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
    }

}
