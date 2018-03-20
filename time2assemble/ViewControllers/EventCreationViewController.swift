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
    var eventId: String!

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameTextField.text = ""
        descriptionTextField.text = ""
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onInviteButtonClick(_ sender: Any) {
        
  
        let event = Event(name: eventNameTextField.text!, creator: user.id, invitees: [], description: descriptionTextField.text!, id: "")
        self.performSegue(withIdentifier: "toInvite", sender: event)
        // WILL HAVE TO EDIT LATER TO CHANGE THE USER'S INVITED EVENTS
    }
    
    // MARK: - Navigation
    // got rid of override
   func prepare(for segue: UIStoryboardSegue, sender: Event) {
    
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
        
        if let inviteView = segue.destination as? InviteViewController {
            inviteView.user = user
            inviteView.eventId = eventId
            inviteView.event = sender
        }
    }
    
}
