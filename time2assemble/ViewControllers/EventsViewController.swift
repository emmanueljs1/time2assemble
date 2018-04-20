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
    var invitedEvents : [Event] = []
    var invitedSelectedCell: Int?
    
    @IBOutlet weak var eventCode: UITextField!
    
    @IBOutlet weak var createdEventsTableView: UITableView!
    var createdEvents : [Event] = []
    var createdSelectedCell: Int?
    
    @IBOutlet weak var errorMessage: UILabel!
    
    var loaded = false
    
    func loadEvents() {
        FirebaseController.getUserEvents(user.id, { (invitedEvents, createdEvents, _) in
            self.invitedEvents = invitedEvents
            self.createdEvents = createdEvents
            self.loaded = true
            self.createdEventsTableView.reloadData()
            self.invitedEventsTableView.reloadData()
        } )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitedEventsTableView.dataSource = self
        invitedEventsTableView.delegate = self
        createdEventsTableView.dataSource = self
        createdEventsTableView.delegate = self
        //invitedEventsTableView.separatorColor = UIColor.white;
        //createdEventsTableView.separatorColor = UIColor.white;
        errorMessage.textColor = UIColor.red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loaded = false
        invitedEvents = []
        createdEvents = []
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickAddEvent(_ sender: Any) {
        let eventId = "-" + eventCode.text!
        FirebaseController.inviteUserToEvent(user, eventId, callback: { (dbError) in
            switch dbError {
            case .eventNotFound:
                self.errorMessage.text = "Event not found."
            case .userAlreadyInvited:
                self.errorMessage.text = "You have already joined this event."
            case .userIsCreator:
                self.errorMessage.text = "You are the creator for this event"
            case .noError:
                self.errorMessage.text = ""
                self.loadEvents()
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if loaded {
            let invitedLocation = sender.location(in: invitedEventsTableView)

            for eventTableViewCell in invitedEventsTableView.visibleCells {
                if eventTableViewCell.frame.contains(invitedLocation) {
                    let indexPath = invitedEventsTableView.indexPath(for: eventTableViewCell)
                    performSegue(withIdentifier: "toEventDetailsViewController", sender: invitedEvents[indexPath!.row])
                }
            }

            let createdLocation = sender.location(in: createdEventsTableView)

            for eventTableViewCell in createdEventsTableView.visibleCells {
                if eventTableViewCell.frame.contains(createdLocation) {
                    let indexPath = createdEventsTableView.indexPath(for: eventTableViewCell)
                    performSegue(withIdentifier: "toEventDetailsViewController", sender: createdEvents[indexPath!.row])
                }
            }
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
            if loaded {
                cell.textLabel!.text = invitedEvents[indexPath.row].name
                cell.detailTextLabel!.text = invitedEvents[indexPath.row].description
            }
        }
        
        if tableView === self.createdEventsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier1", for: indexPath)
            if loaded {
                cell.textLabel!.text = createdEvents[indexPath.row].name
                cell.detailTextLabel!.text = createdEvents[indexPath.row].description
            }
        }
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HELLO!")
        if tableView === createdEventsTableView {
            performSegue(withIdentifier: "toEventDetailsViewController", sender: invitedEvents[indexPath.row])
        }
        else if tableView === invitedEventsTableView {
            performSegue(withIdentifier: "toEventDetailsViewController", sender: createdEvents[indexPath.row])
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = sender as! Event
            eventDetailsVC.source = self
        }
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
            eventDashboardVC.selectedIndex = 1
        }
        if let archivedEventsVC = segue.destination as? ArchivedEventsViewController {
            archivedEventsVC.user = user
        }
    }
}
