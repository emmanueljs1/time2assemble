//
//  ArchivedEventsViewController.swift
//  time2assemble
//
//  Created by Jane Xu on 3/31/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class ArchivedEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user : User!
    var archivedEvents : [Event] = []
    @IBOutlet weak var archivedEventsTableView: UITableView!

    var loaded = false
    
    func loadEvents() {
        FirebaseController.getUserEvents(user.id, { (_, _, archivedEvents) in
            self.archivedEvents = archivedEvents
            self.loaded = true
            self.archivedEventsTableView.reloadData()
        } )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        archivedEventsTableView.dataSource = self
        archivedEventsTableView.delegate = self
        //archivedEventsTableView.separatorColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        archivedEvents = []
        loaded = false
        loadEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if loaded {
            let tapLocation = sender.location(in: archivedEventsTableView)
            
            for eventTableViewCell in archivedEventsTableView.visibleCells {
                if eventTableViewCell.frame.contains(tapLocation) {
                    let indexPath = archivedEventsTableView.indexPath(for: eventTableViewCell)
                    performSegue(withIdentifier: "toEventDetailsViewController", sender: archivedEvents[indexPath!.row])
                }
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedEvents", for: indexPath)
        
        if loaded {
            cell.textLabel!.text = archivedEvents[indexPath.row].name
            cell.detailTextLabel!.text = archivedEvents[indexPath.row].description
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
        }
    }

}
