//
//  InviteViewController.swift
//  time2assemble
//
//  Created by Hana Pearlman on 3/11/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {
    var user: User!
    var eventId: String!
    var event: Event!
    @IBOutlet weak var eventCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = eventId.index(eventId.startIndex, offsetBy: 1)
        let eventSubstring = eventId.suffix(from: index)
        let eventIdString = String(eventSubstring)
        
        // TODO: add the "-" back in when a user is "adding" an event from dashboard
        eventCodeLabel.text = eventIdString

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Remove the first char of eventId (a "-") and display to user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDoneButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "toEvents", sender: event)
        // WILL HAVE TO EDIT LATER TO CHANGE THE USER'S INVITED EVENTS
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dashboardView = segue.destination as? EventDashboardController {
            dashboardView.user = user
        }
        
    }

}