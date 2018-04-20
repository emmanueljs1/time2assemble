//
//  InviteViewController.swift
//  time2assemble
//
//  Created by Hana Pearlman on 3/11/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
//After user has created an event and filled availability, allow user to send event code to invitees
class InviteViewController: UIViewController {
    var user: User!
    var event: Event!

    @IBOutlet weak var eventCodeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = event.id.index(event.id.startIndex, offsetBy: 1) //event id in form "-XXXXXX...", remove first "-"
        let eventSubstring = event.id.suffix(from: index)
        let eventIdString = String(eventSubstring)
        eventCodeTextView.text = eventIdString
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onDoneButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "toEvents", sender: event)
    }

    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboardView = segue.destination as? EventDashboardController {
            dashboardView.user = user
        }        
    }

}
