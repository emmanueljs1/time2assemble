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

    var userID : Int!
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
            "creator": userID,
            "invitees": inviteesTextField.text!])
        
        //performSegue(withIdentifier: "toEventDashboard", sender: sender)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
