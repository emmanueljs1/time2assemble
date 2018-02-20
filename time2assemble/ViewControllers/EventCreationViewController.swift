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
    var eventID: Int!
    var ref: DatabaseReference!

    @IBOutlet var eventNameTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var inviteesTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        eventID = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createButtonOnClick(_ sender: Any) {
//        self.ref.child("events").child(String(eventID)).setValue([
//            "name": eventNameTextField.text!,
//            "description": descriptionTextField.text!,
//            "creator": username,
//            "invitees": inviteesTextField.text!])
//        eventID = eventID + 1
        let refEvents = self.ref.child("events")
        let refEvent = refEvents.childByAutoId()
        let eventId = refEvent.key
        refEvents.child(eventId).setValue([
            "name": eventNameTextField.text!,
            "description": descriptionTextField.text!,
            "creator": user.id,
            "invitees": inviteesTextField.text!])
        
        //performSegue(withIdentifier: "toEventDashboard", sender: sender)
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
