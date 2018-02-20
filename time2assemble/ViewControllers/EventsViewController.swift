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
    var events2 : [(String, String)] = []
    
    @IBOutlet weak var eventsTableView2: UITableView!
    
    func loadEvents() {
        events = []
        events2 = []
        ref.child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            for key in dict.allKeys {
                if let fields = dict[key] as? NSDictionary,
                    let invitees = fields["invitees"] as? String,
                    let name = fields["name"] as? String,
                    let creator = fields["creator"] as? Int,
                    let description = fields["description"] as? String {
                    if creator == self.user.id {
                        self.events2.append((name, description))
                    }
                    if invitees.contains(self.user.firstName) {
                        self.events.append((name, description))
                    }
                }
            }
            
            self.eventsTableView.reloadData()
            self.eventsTableView2.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        eventsTableView2.dataSource = self
        eventsTableView2.delegate = self
        eventsTableView.separatorColor = UIColor.clear;
        eventsTableView2.separatorColor = UIColor.clear;
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
        let count : Int!
        
        if tableView === self.eventsTableView {
            count = events.count
        } else { //if tableView == self.eventsTableView2
            count = events2.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        if tableView === self.eventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel!.text = events[indexPath.row].0
            cell.detailTextLabel!.text = events[indexPath.row].1
        }
        
        if tableView === self.eventsTableView2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier1", for: indexPath)
            cell.textLabel!.text = events2[indexPath.row].0
            cell.detailTextLabel!.text = events2[indexPath.row].1
        }
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
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
