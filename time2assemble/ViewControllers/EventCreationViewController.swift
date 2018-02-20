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
        let refEvent = refEvents.childByAutoId()
        let eventId = refEvent.key
        refEvents.child(eventId).setValue([
            "name": eventNameTextField.text!,
            "description": descriptionTextField.text!,
            "creator": user.id,
            "invitees": inviteesTextField.text!])
        
        parentTabBar.selectedIndex = 1
        
        self.performSegue(withIdentifier: "toEvents", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventsView = segue.destination as? EventsViewController {
            eventsView.user = user
        }
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    }
    
}
