//
//  EventsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController {

    var user : User!
    @IBOutlet weak var eventsStackView: UIStackView!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ref.child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            for key in dict.allKeys {
                if let fields = dict[key] as? NSDictionary,
                    let invitees = fields["invitees"] as? String,
                    let name = fields["name"] as? String,
                    let description = fields["description"] as? String {
                    print(self.user)
                    if invitees.contains(self.user.firstName) {
                        let eventView = EventView(eventName: name, description: description)
                        self.eventsStackView.addArrangedSubview(eventView)
                    }
                }
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventCreationVC = segue.destination as? EventCreationViewController {
            eventCreationVC.user = user
        }
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    }
    
}
