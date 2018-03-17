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
    @IBOutlet weak var invitedEventsTableView: UITableView!
    var ref: DatabaseReference!
    var invitedEvents : [(String, String)] = []
    var createdEvents : [(String, String)] = []
    
    @IBOutlet weak var eventCode: UITextField!
    @IBOutlet weak var createdEventsTableView: UITableView!
    
    func addEventsDetails(_ events : [String], _ created : Bool) {
            for key in events {
                ref.child("events").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    // Get event value
                    let dict = snapshot.value as? NSDictionary ?? [:]
   
                    if //let invitees = fields["invitees"] as? String,
                        let name = dict["name"] as? String,
                        //let creator = fields["creator"] as? Int,
                        let description = dict["description"] as? String {
                        
                        if created {
                            self.createdEvents.append((name, description))
                        } else {
                            print("probably not here")
                            self.invitedEvents.append((name, description))
                        }
                    }
                    
                    if created {
                        self.createdEventsTableView.reloadData()
                    } else {
                        self.invitedEventsTableView.reloadData()
                    }
                })
                {(error) in
                    print("could not find event :c")
                }
        }
    }
    
    func loadEvents() {
        ref.child("users").child(String(self.user.id)).observeSingleEvent(of: .value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            self.invitedEvents = []

            if let ie = dict["invitedEvents"] as? [String]  {
                self.addEventsDetails(ie, false)
            } else {
                self.invitedEventsTableView.reloadData()
            }
            
            self.createdEvents = []
            
            if let ce = dict["createdEvents"] as? [String] {
                self.addEventsDetails(ce, true)
            } else {
                self.createdEventsTableView.reloadData()

            }
        
        })
        {(error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        invitedEventsTableView.dataSource = self
        invitedEventsTableView.delegate = self
        createdEventsTableView.dataSource = self
        createdEventsTableView.delegate = self
        invitedEventsTableView.separatorColor = UIColor.clear;
        createdEventsTableView.separatorColor = UIColor.clear;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickAddEvent(_ sender: Any) {
        // need to get the event from the database
        ref.child("events").child("-" + eventCode.text!).observeSingleEvent(of: .value, with: {(snapshot) in
            
            // Get event value
            let dict = snapshot.value as? NSDictionary ?? [:]
            
            if let invitees = dict["invitees"] as? String
            {
                let newInvitees = invitees + ", " + String(self.user.id)
            
                // adds user id to invitees list

                self.ref.child("events").child("-" + self.eventCode.text!).updateChildValues(["invitees": newInvitees])
                self.ref.child("users").child(String(self.user.id)).observeSingleEvent(of: .value, with: {(snapshot) in
                    let udict = snapshot.value as? NSDictionary ?? [:]
    
                    // adds event id to the user's event list
                    if var invitedTo = udict["invitedEvents"] as? [String]
                    {
                        invitedTo.append("-" + self.eventCode.text!)
                        self.ref.child("users").child(String(self.user.id)).updateChildValues(["invitedEvents" : invitedTo])
                    } else { // if the user hasn't been invited to anything
                        var invitedTo = [String]()
                        invitedTo.append("-" + self.eventCode.text!)
                        self.ref.child("users").child(String(self.user.id)).updateChildValues(["invitedEvents" : invitedTo])
                    }
                    
                    // adds event to invitedEvents for user
                    // TODO: maybe delete this ONLY if you've handled it in loadEvents already
                    self.user.addInvitedEvent("-" + self.eventCode.text!)
                    
                    // adds event
                    self.loadEvents()
                })
                {(error) in
                    print("SHOULD NOT HAPPEN: user id somehow not found")
                }
            }
        })
        {(error) in
            // should probably display an error message on the screen
            print("Error: Event doesn't exist")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: invitedEventsTableView)
        
        for eventTableViewCell in invitedEventsTableView.visibleCells {
            if eventTableViewCell.frame.contains(location) {
                performSegue(withIdentifier: "toEventDetailsViewController", sender: eventTableViewCell)
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count : Int!
        
        if tableView === self.invitedEventsTableView {
            count = invitedEvents.count
        } else { //if tableView == self.createdEventsTableView
            count = createdEvents.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        if tableView === self.invitedEventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel!.text = invitedEvents[indexPath.row].0
            cell.detailTextLabel!.text = invitedEvents[indexPath.row].1
        }
        
        if tableView === self.createdEventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier1", for: indexPath)
            cell.textLabel!.text = createdEvents[indexPath.row].0
            cell.detailTextLabel!.text = createdEvents[indexPath.row].1
        }
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
        }
        if let eventCreationVC = segue.destination as? EventCreationViewController {
            eventCreationVC.user = user
        }
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    }
    
}
