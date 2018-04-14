//
//  NotificationsViewController.swift
//  time2assemble
//
//  Created by Jane Xu on 4/7/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user : User!
    var notifications : [EventNotification] = [];
    @IBOutlet weak var notificationsTableView: UITableView!
    var loaded = false
    
    func loadNotifications() {
        FirebaseController.getNotificationsForUser(user.id, {
            (notificationsList) in
            self.notifications = notificationsList
            self.loaded = true
            self.notificationsTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath)
        
        if loaded {
            let notification = notifications[indexPath.row]
            
            switch notification.type {
            case 1:
            case 2:
            case 3:
            }
            cell.textLabel!.text =
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
        notificationsTableView.separatorColor = UIColor.clear
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
