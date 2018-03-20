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
    
        // CHange defaualts
        let event = Event(eventNameTextField.text!, user.id, [], descriptionTextField.text!, "", 0, 12, "2018", "2018")
        self.performSegue(withIdentifier: "toFill", sender: event)
        // WILL HAVE TO EDIT LATER TO CHANGE THE USER'S INVITED EVENTS
    }
    
    // MARK: - Navigation
    // got rid of override
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    
        if let fillAvailView = segue.destination as? FillAvailViewController {
            fillAvailView.ref = ref
            fillAvailView.event = sender as! Event!
            fillAvailView.user = user
        }
    }
    
}
