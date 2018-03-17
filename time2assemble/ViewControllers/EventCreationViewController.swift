//
//  EventCreationViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventCreationViewController: UIViewController {

    var user: User!
    var ref: DatabaseReference!
    var parentTabBar: EventDashboardController!
    var eventId: String!

    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var inviteesTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameTextField.text = ""
        descriptionTextField.text = ""
        inviteesTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createButtonOnClick(_ sender: Any) {
        let refEvents = ref.child("events")
        
        // adds the event to the database
        let refEvent = refEvents.childByAutoId()
        eventId = refEvent.key
        refEvents.child(eventId).setValue([
            "name": eventNameTextField.text!,
            "description": descriptionTextField.text!,
            "creator": user.id,
            "invitees": inviteesTextField.text!])
        
        // updates the createdEvents in the user object
        user.addCreatedEvent(eventId)
        
        // updates the createdEvents in the user database
        ref.child("users").child(String(user.id)).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            var createdEvents = [String]()
            
            if let created_events = dict["createdEvents"] as? [String] {
                createdEvents = created_events
            }
            
            createdEvents.append(self.eventId)
            self.ref.child("users").child(String(self.user.id)).updateChildValues(["createdEvents" : createdEvents])
            
        }) { (error) in
            print("error finding user")
        }
        
        parentTabBar.selectedIndex = 1
        
        self.performSegue(withIdentifier: "toEvents", sender: self)
    }
    
    @IBAction func onInviteButtonClick(_ sender: Any) {
        let refEvents = ref.child("events")
        let refEvent = refEvents.childByAutoId()
        eventId = refEvent.key
        refEvents.child(eventId).setValue([
            "name": eventNameTextField.text!,
            "description": descriptionTextField.text!,
            "creator": user.id,
            "invitees": inviteesTextField.text!])
        
        // WILL HAVE TO EDIT LATER TO CHANGE THE USER'S INVITED EVENTS
        
        self.performSegue(withIdentifier: "toInvite", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventsView = segue.destination as? EventsViewController {
            eventsView.user = user
        }
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
        
        if let inviteView = segue.destination as? InviteViewController {
            inviteView.user = user
            inviteView.eventId = eventId
        }
    }
    
}
