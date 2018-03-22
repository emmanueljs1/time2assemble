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
    var invitedEvents : [Event] = []
    var createdEvents : [Event] = []
    
    // TODO: use https://stackoverflow.com/questions/46622859/how-to-know-which-cell-was-tapped-in-tableview-using-swift to change table view cell selecting
    
    @IBOutlet weak var eventCode: UITextField!
    @IBOutlet weak var createdEventsTableView: UITableView!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    func addEventsDetails(_ events : [String], _ created : Bool) {
            for key in events {
                ref.child("events").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
                    // Get event value
                    let dict = snapshot.value as? NSDictionary ?? [:]
   
                    if  let name = dict["name"] as? String,
                        let creator = dict["creator"] as? Int,
                        let description = dict["description"] as? String,
                        let noEarlierThan = dict["noEarlierThan"] as? Int,
                        let noLaterThan = dict["noLaterThan"] as? Int,
                        let earliestDate = dict["earliestDate"] as? String,
                        let latestDate = dict["latestDate"] as? String {
                        
                        // CHange
                        let new_event = Event(name, creator, [], description, key, noEarlierThan, noLaterThan, earliestDate, latestDate)
                        
                        if created {
                            self.createdEvents.append(new_event)
                        } else {
                            self.invitedEvents.append(new_event)
                        }
                    }
                    
                    if created {
                        self.createdEventsTableView.reloadData()
                    } else {
                        self.invitedEventsTableView.reloadData()
                    }
                })
                { (error) in }
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
        errorMessage.textColor = UIColor.red
        loadEvents()
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
            
            if dict.count == 0 {
                self.errorMessage.text = "Event not found."
                return
            } else {
                self.errorMessage.text = ""
            }
            
            var invitees = [Int]()
            
            if let from_database = dict["invitees"] as? [Int]
            {
                invitees = from_database
            }
            
            invitees.append(self.user.id)
            
            // adds user id to invitees list
            
            self.ref.child("events").child("-" + self.eventCode.text!).updateChildValues(["invitees": invitees])
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
            { (error) in
                print("Error: user id somehow not found, Trace: \(error)")
            }
            
        })
        {(error) in
            // TODO: should probably display an error message on the screen
            print("Error: Event doesn't exist")
        }
    }
    
    // MARK: - Actions
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        var i = 0
        
        for eventTableViewCell in invitedEventsTableView.visibleCells {
            if eventTableViewCell.isSelected {
                performSegue(withIdentifier: "toEventDetailsViewController", sender: invitedEvents[i])
            }
            i += 1
        }
        
        // let cloc = sender.location(in: createdEventsTableView)
        i = 0
        
        for eventTableViewCell in createdEventsTableView.visibleCells {
            if eventTableViewCell.isSelected{
                performSegue(withIdentifier: "toEventDetailsViewController", sender: createdEvents[i])
            }
            i += 1
        }
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let iloc = sender.location(in: invitedEventsTableView)
        
        var i = 0
        
        for eventTableViewCell in invitedEventsTableView.visibleCells {
            if eventTableViewCell.frame.contains(iloc) {
                performSegue(withIdentifier: "toEventDetailsViewController", sender: invitedEvents[i])
            }
            i += 1
        }
        
        let cloc = sender.location(in: createdEventsTableView)
        i = 0
        
        for eventTableViewCell in createdEventsTableView.visibleCells {
            if eventTableViewCell.frame.contains(cloc) {
                performSegue(withIdentifier: "toEventDetailsViewController", sender: createdEvents[i])
            }
            i += 1
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView === self.invitedEventsTableView {
            count = invitedEvents.count
        }
        else if tableView === self.createdEventsTableView {
            count = createdEvents.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        if tableView === self.invitedEventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel!.text = invitedEvents[indexPath.row].name
            cell.detailTextLabel!.text = invitedEvents[indexPath.row].description
        }
        
        if tableView === self.createdEventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier1", for: indexPath)
            cell.textLabel!.text = createdEvents[indexPath.row].name
            cell.detailTextLabel!.text = createdEvents[indexPath.row].description
        }
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = sender as! Event
        }
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
            eventDashboardVC.selectedIndex = 1
        }
    }
    
}
