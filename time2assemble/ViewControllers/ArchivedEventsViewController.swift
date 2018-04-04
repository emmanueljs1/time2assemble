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
    
    // TODO: use https://stackoverflow.com/questions/46622859/how-to-know-which-cell-was-tapped-in-tableview-using-swift to change table view cell selecting
    
    func loadEvents() {
        FirebaseController.getUserEvents(user.id, { (_, _, archivedEvents) in
            self.archivedEvents = archivedEvents
            self.archivedEventsTableView.reloadData()
        } )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        archivedEventsTableView.dataSource = self
        archivedEventsTableView.delegate = self
        archivedEventsTableView.separatorColor = UIColor.clear;
        loadEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        archivedEvents = []
        loadEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: archivedEventsTableView)
        
        var i = 0
        
        for eventTableViewCell in archivedEventsTableView.visibleCells {
            if eventTableViewCell.frame.contains(tapLocation) {
                performSegue(withIdentifier: "toEventDetailsViewController", sender: archivedEvents[i])
            }
            i += 1
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
        cell.textLabel!.text = archivedEvents[indexPath.row].name
        cell.detailTextLabel!.text = archivedEvents[indexPath.row].description
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
