//
//  NotificationsViewController.swift
//  time2assemble
//
//  Created by Jane Xu on 4/7/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import UIKit
//Show list of notifications to a user
class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user : User!
    var notifications : [EventNotification] = [];
    @IBOutlet weak var notificationsTableView: UITableView!
    var loaded = false
    
    //retrieve all notifications for a user
    func loadNotifications() {
        FirebaseController.getNotificationsForUser(user.id, callback: {
            (notificationsList) in
            self.notifications = notificationsList
            self.loaded = true
            self.notificationsTableView.reloadData() //display to user
            self.markAllNotificationsAsRead()          //then mark all as read
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath)
        
        if loaded {
            let notification = notifications[indexPath.row]
            
            //display different notification text depending on notification type
            switch notification.type {
            case NotificationType.NotificationType.allInviteesResponded:
                cell.textLabel!.text = "All invitees have responded to your finalized time. " + notification.eventName
                break
            case NotificationType.NotificationType.eventDeleted:
                cell.textLabel!.text = "The event " + notification.eventName + " has been deleted by " + notification.sender + "."
                break
            case NotificationType.NotificationType.eventJoined:
                cell.textLabel!.text = "" + notification.sender + " has joined your event " + notification.eventName + "."
                break
            case NotificationType.NotificationType.eventFinalized:
                cell.textLabel!.text = "\nThe event " + notification.eventName + " has been finalized by " + notification.sender + ".\n"
                break
            }
            
            if notification.read {
                cell.backgroundColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0) //if unread, display with darker color
            }
        }
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        notifications = []
        loaded = false
        loadNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //when notification is clicked, segue to details view for that event
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if loaded {
            let tapLocation = sender.location(in: notificationsTableView)
            
            for notificationCell in notificationsTableView.visibleCells {
                if notificationCell.frame.contains(tapLocation) {
                    let indexPath = notificationsTableView.indexPath(for: notificationCell)
                    
                    if (notifications[indexPath!.row].type != NotificationType.NotificationType.eventDeleted) {
                        print(notifications[indexPath!.row].eventID)
                        
                        FirebaseController.getEventFromID(notifications[indexPath!.row].eventID, {
                            (event) in
                            self.performSegue(withIdentifier: "toEventDetailsViewController", sender: event)
                        })
                        
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //about to leave notifications page, mark all notifications as read
        markAllNotificationsAsRead()
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = sender as! Event
            eventDetailsVC.source = self
            
        }
        if let eventDashboardVC = segue.destination as? EventDashboardController {
            eventDashboardVC.user = user
        }
    }
    
    func markAllNotificationsAsRead() {
        for notif in notifications {
            if (notif.read == true) {
                continue
            } else {
                FirebaseController.markNotificationAsRead(user.id, notif.id)
            }
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
