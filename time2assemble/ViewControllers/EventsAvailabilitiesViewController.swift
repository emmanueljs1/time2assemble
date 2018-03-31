//
//  EventsAvailabilitiesViewController.swift
//  time2assemble
//
//  Created by Jane Xu on 3/22/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

import UIKit
import Firebase

class EventAvailabilitiesViewController: UIViewController {
    
    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    var user: User!
    var event : Event!
    var eventId: String!
    var availabilities: [String: [Int: Int]] = [:]
    var ref: DatabaseReference!

    func getAllEventAvailabilities(_ eventID: String) -> [String: [Int: Int]] {
        let ref = Database.database().reference()
        var availsDict : Dictionary = [String: [Int: Int]] ()
        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
            for (_, value) in dict {
                print(value)
                if let user_avails = value as? [String: [Int]] { //availability of a single user
                    print("got here")
                    for (date, hourList) in user_avails {
                        print("got here 2")
                        print(date)
                        print(hourList)
                        for hour in hourList {
                            if let hourMap = availsDict[date] {
                                if let hourCount = hourMap[hour] {
                                    print("adding stuff")
                                    availsDict[date]![hour] = hourCount + 1
                                } else {
                                    print("THIS ONE")
                                    availsDict[date]![hour] = 1
                                }
                            } else {
                                print("actally yhus one")
                                availsDict[date] = [hour : 1]
                            }
                        }
                    }
                }
            }
            self.availabilities = availsDict
            self.loadAvailabilitiesView(self.event.startDate)
            print("HELLO? \(availsDict)")
        }) { (error) in
            print("error finding availabilities")
        }
        
        return availsDict
    }
    
    func loadAvailabilitiesView(_ date: String) {
        let dateAvailabilities = availabilities[date] ?? [:]
        
        print("\(date): \(dateAvailabilities)")
        
        var maxCount = 0
        
        for i in 8...22 {
            let count = dateAvailabilities[i] ?? 0
            print("\(i): \(count)")
            maxCount = max(count, maxCount)
        }
        
        for i in 8...22 {
            let count = dateAvailabilities[i] ?? 0
            if let availabilityView = availabilitiesStackView.arrangedSubviews[i - 8] as? SelectableView {
                availabilityView.selectViewWithDegree(count, maxCount)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timesStackView.distribution = .fillEqually
        availabilitiesStackView.distribution = .fillEqually
        availabilitiesStackView.axis = .vertical
        timesStackView.axis = .vertical
        for t in 8...22 {
            var time = String(t)
            if t < 10 {
                time = "0" + time
            }
            time += ":00"
            let timeLabel = UILabel(frame: CGRect ())
            timeLabel.text = time
            timesStackView.addArrangedSubview(timeLabel)
            
            var selectable = true
            if t < event.noEarlierThan || t > event.noLaterThan  {
                selectable = false
            }
            availabilitiesStackView.addArrangedSubview(SelectableView(selectable))
        }
        
        availabilities = getAllEventAvailabilities(event.id)
            //availabilities = ["2018-03-20": [8: 1, 9: 2, 10: 3, 11: 4, 12: 5, 13: 6, 14: 7, 15: 8, 16: 9, 17: 10, 18: 11, 19: 12, 20: 13, 21: 14, 22: 15]]
            //loadAvailabilitiesView(event.startDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let finalizeView = segue.destination as? FinalizeAvailabilityViewController {
            finalizeView.user = user
            finalizeView.event = event
        }
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = event
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
}
