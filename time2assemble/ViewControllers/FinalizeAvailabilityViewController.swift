//
//  FinalizeAvailabilityViewController.swift
//  time2assemble
//
//  Created by Julia Chun on 3/31/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import Foundation

import UIKit
import Firebase

class FinalizeAvailabilityViewController: UIViewController {

    @IBOutlet weak var selectableViewsStackView: UIStackView!
    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    
    var user: User!
    var event : Event!
    var eventId: String!
    var availabilities: [String: [Int: Int]] = [:]
    var ref: DatabaseReference!
    var selecting = true
    var lastDragLocation : CGPoint?
    
    var availabilities: [String: [Int: Int]] = [:]
    var userAvailabilities: [String: [(Int, Int)]] = [:]
    var eventBeingCreated = false

    var currentDate: Date!
    let formatter = DateFormatter()
    
    
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
        selectableViewsStackView.distribution = .fillEqually
        selectableViewsStackView.axis = .vertical
        
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
            selectableViewsStackView.addArrangedSubview(SelectableView(selectable))
        }
        
        availabilities = getAllEventAvailabilities(event.id)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = event
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func onFinalizeClick(_ sender: Any) {
        
    }
    
    // MARK: - Actions
    @IBAction func dragged(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: selectableViewsStackView)

        var setSelecting = false

        if sender.state == .began {
            setSelecting = true
        }

        for aView in selectableViewsStackView.arrangedSubviews {
            if let selectableView = aView as? SelectableView {
                let frame = selectableView.frame
                if frame.contains(location) && (lastDragLocation == nil || !frame.contains(lastDragLocation!)) {
                    if setSelecting {
                        selecting = !selectableView.selected
                        setSelecting = false
                    }

                    if selecting {
                        selectableView.selectView()
                    }
                    else {
                        selectableView.unselectView()
                    }
                }
            }
        }
        lastDragLocation = location
    }

    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: timesStackView)

        for aView in selectableViewsStackView.arrangedSubviews {
            if let selectableView = aView as? SelectableView {
                if selectableView.frame.contains(location) {
                    if !selectableView.selected {
                        selectableView.selectView()
                    }
                    else {
                        selectableView.unselectView()
                    }
                }
            }
        }
    }

    
    
    //    let oneDay = 24.0 * 60.0 * 60.0
    //
    //    @IBOutlet weak var nextAndDoneButton: UIButton!
    //    @IBOutlet weak var currentDateLabel: UILabel!
    //    var ref: DatabaseReference!
    //    var user: User!
    //    var event : Event!
    //    var eventId: String!

    //

    //    func getAllEventAvailabilities(_ eventID: String) -> [String: [Int: Int]] {
    //        let ref = Database.database().reference()
    //        var availsDict : Dictionary = [String: [Int: Int]] ()
    //        ref.child("availabilities").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
    //            let dict = snapshot.value as? NSDictionary ?? [:] // dict a mapping from user ID to availability
    //            for (_, value) in dict {
    //                print(value)
    //                if let user_avails = value as? [String: [Int]] { //availability of a single user
    //                    print("got here")
    //                    for (date, hourList) in user_avails {
    //                        print("got here 2")
    //                        print(date)
    //                        print(hourList)
    //                        for hour in hourList {
    //                            if let hourMap = availsDict[date] {
    //                                if let hourCount = hourMap[hour] {
    //                                    print("adding stuff")
    //                                    availsDict[date]![hour] = hourCount + 1
    //                                } else {
    //                                    print("THIS ONE")
    //                                    availsDict[date]![hour] = 1
    //                                }
    //                            } else {
    //                                print("actally yhus one")
    //                                availsDict[date] = [hour : 1]
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //            self.availabilities = availsDict
    //            self.loadAvailabilitiesView(self.event.startDate)
    //            print("HELLO? \(availsDict)")
    //        }) { (error) in
    //            print("error finding availabilities")
    //        }
    //
    //        return availsDict
    //    }
    
    
        func saveAvailability() {
            var startOpt : Int? = nil
            var ranges : [(Int, Int)] = []
            var i = 8
            for aView in selectableViewsStackView.arrangedSubviews {
                if let selectableView = aView as? SelectableView {
                    if selectableView.selected {
                        if startOpt == nil {
                            startOpt = i
                        }
                    }
                    else {
                        if let start = startOpt {
                            ranges += [(start, i - 1)]
                            startOpt = nil
                        }
                    }
                }
                i += 1
            }
            print(ranges)
            userAvailabilities[formatter.string(from: currentDate)] = ranges
//            currentDate = currentDate + TimeInterval(oneDay)
//            currentDateLabel.text = formatter.string(from: currentDate)
        }
    
    
    /* TODO: FIXME: - reformat events so that they have a Date object as their earliest and latest dates,
     * modify this method so that every time that the button is clicked, if the current date is not the
     * latest date of the event, use the saveAvailability function to save the availability of the _current
     * date_ and then increment the date object (using TimeInterval = 24.0 * 60.0 * 60.0 = 1 day)
     */
    //    @IBAction func onContinueButtonClick(_ sender: UIButton) {
    
    //        let endDate = formatter.date(from: event.endDate)
    //
    //        // save the filed availability for current date
    //        saveAvailability()
    //
    //        if currentDate == endDate {
    //            nextAndDoneButton.setTitle("Done", for: .normal)
    //        }
    //
    //        if eventBeingCreated && currentDate > endDate! {
    //            let refEvents = ref.child("events")
    //
    //            // adds the event to the database
    //            let refEvent = refEvents.childByAutoId()
    //            eventId = refEvent.key
    //
    //            event.id = eventId
    //
    //            Availabilities.setEventAvailabilitiesForUser(eventId, String(user.id), userAvailabilities)
    //
    //            refEvents.child(eventId).setValue([
    //                "name": event.name,
    //                "description": event.description,
    //                "creator": event.creator,
    //                "invitees": event.invitees,
    //                "noEarlierThan": event.noEarlierThan,
    //                "noLaterThan": event.noLaterThan,
    //                "earliestDate": event.startDate,
    //                "latestDate": event.endDate])
    //
    //            // updates the createdEvents in the user object
    //            user.addCreatedEvent(eventId)
    //
    //            // updates the createdEvents in the user database
    //            ref.child("users").child(String(user.id)).observeSingleEvent(of: .value, with: { (snapshot) in
    //                let dict = snapshot.value as? NSDictionary ?? [:]
    //
    //                var createdEvents = [String]()
    //
    //                if let created_events = dict["createdEvents"] as? [String] {
    //                    createdEvents = created_events
    //                }
    //
    //                createdEvents.append(self.eventId)
    //                self.ref.child("users").child(String(self.user.id)).updateChildValues(["createdEvents" : createdEvents])
    //
    //                self.performSegue(withIdentifier: "toInvite", sender: self)
    //
    //            }) { (error) in
    //                print("error finding user")
    //            }
    //        }
    //        else if !eventBeingCreated && currentDate > endDate! {
    //            Availabilities.setEventAvailabilitiesForUser(event.id, String(user.id), userAvailabilities)
    //            performSegue(withIdentifier: "toDashboard", sender: self)
    //        }
    //        else {
    //            for aView in selectableViewsStackView.arrangedSubviews {
    //                if let selectableView = aView as? SelectableView {
    //                    selectableView.unselectView()
    //                }
    //            }
    //        }
    //    }
    
    //    @IBAction func onCancelButtonClick(_ sender: Any) {
    //        self.performSegue(withIdentifier: "toDashboard", sender: self)
}

