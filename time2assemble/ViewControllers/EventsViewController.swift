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
    var createdEvents : [Event] = []
    
    // TODO: use https://stackoverflow.com/questions/46622859/how-to-know-which-cell-was-tapped-in-tableview-using-swift to change table view cell selecting
    
    @IBOutlet weak var eventCode: UITextField!
    @IBOutlet weak var createdEventsTableView: UITableView!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    func loadEvents() {
        FirebaseController.getUserEvents(user, callback: { (invitedEvents, createdEvents, _) in
            self.invitedEvents = invitedEvents
            self.createdEvents = createdEvents
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
        invitedEventsTableView.separatorColor = UIColor.clear;
        createdEventsTableView.separatorColor = UIColor.clear;
        errorMessage.textColor = UIColor.red
        loadEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        FirebaseController.inviteUserToEvent(user, eventId, callback: { (hadError) in
            if hadError {
                self.errorMessage.text = "Event not found."
            }
            else {
                self.errorMessage.text = ""
                self.loadEvents()
            }
        })
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
