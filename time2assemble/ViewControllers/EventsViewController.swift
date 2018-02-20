//
//  EventsViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var user : User!
    @IBOutlet weak var eventsTableView: UITableView!
    var ref: DatabaseReference!
    var events : [(String, String)] = []
    
    func loadEvents() {
        events = []
        ref.child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            for key in dict.allKeys {
                if let fields = dict[key] as? NSDictionary,
                    let invitees = fields["invitees"] as? String,
                    let name = fields["name"] as? String,
                    let description = fields["description"] as? String {
                    print(self.user)
                    if invitees.contains("Hana") {
                        self.events.append((name, description))
                    }
                }
            }
            
            self.eventsTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel!.text = events[indexPath.row].0
        cell.detailTextLabel!.text = events[indexPath.row].1
        return cell
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
