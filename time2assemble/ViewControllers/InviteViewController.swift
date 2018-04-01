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
    var event: Event!
    @IBOutlet weak var eventCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = event.id.index(event.id.startIndex, offsetBy: 1)
        let eventSubstring = event.id.suffix(from: index)
        let eventIdString = String(eventSubstring)
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
    }

    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboardView = segue.destination as? EventDashboardController {
            dashboardView.user = user
        }
        
    }

}
