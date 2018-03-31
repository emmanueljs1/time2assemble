//
//  FillAvailViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class FillAvailViewController: UIViewController {

    let oneDay = 24.0 * 60.0 * 60.0
    
    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var selectableViewsStackView: UIStackView!
    @IBOutlet weak var nextAndDoneButton: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    var ref: DatabaseReference!
    var user: User!
    var event : Event!
    var eventId: String!
    var availabilities: [String: [Int: Int]] = [:]
    var userAvailabilities: [String: [(Int, Int)]] = [:]
    var eventBeingCreated = false
    var selecting = true
    var currentDate: Date!
    let formatter = DateFormatter()
    
    var lastDragLocation : CGPoint?
    
    func loadAvailabilitiesView(_ date: String) {
        let dateAvailabilities = availabilities[date] ?? [:]
        var maxCount = 0
        
        for i in 8...22 {
            let count = dateAvailabilities[i] ?? 0
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
    
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.date(from: event.startDate)
        currentDateLabel.text = event.startDate
        
        let endDate = formatter.date(from: event.endDate)
        
        if currentDate == endDate {
            nextAndDoneButton.setTitle("Done", for: .normal)
        }
        
        timesStackView.distribution = .fillEqually
        selectableViewsStackView.distribution = .fillEqually
        availabilitiesStackView.distribution = .fillEqually
        availabilitiesStackView.axis = .vertical
        timesStackView.axis = .vertical
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
            
            selectableViewsStackView.addArrangedSubview(SelectableView(selectable))
            availabilitiesStackView.addArrangedSubview(SelectableView(selectable))
        }
        
        if !eventBeingCreated {
            availabilities = Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
                self.availabilities = availabilities
                self.loadAvailabilitiesView(self.event.startDate)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        currentDate = currentDate + TimeInterval(oneDay)
        currentDateLabel.text = formatter.string(from: currentDate)
    }
    
    
    /* TODO: FIXME: - reformat events so that they have a Date object as their earliest and latest dates,
     * modify this method so that every time that the button is clicked, if the current date is not the
     * latest date of the event, use the saveAvailability function to save the availability of the _current
     * date_ and then increment the date object (using TimeInterval = 24.0 * 60.0 * 60.0 = 1 day)
     */
    @IBAction func onContinueButtonClick(_ sender: UIButton) {
        
        let endDate = formatter.date(from: event.endDate)
        
        // save the filed availability for current date
        saveAvailability()
        
        if currentDate == endDate {
            nextAndDoneButton.setTitle("Done", for: .normal)
        }
        
        if eventBeingCreated && currentDate > endDate! {
            FirebaseController.createEvent(user, event, callback: { (eventId) -> () in
                self.event.id = eventId
                self.user.addCreatedEvent(eventId)
                Availabilities.setEventAvailabilitiesForUser(eventId, String(self.user.id), self.userAvailabilities)
                self.performSegue(withIdentifier: "toInvite", sender: self)
            })
        }
        else if !eventBeingCreated && currentDate > endDate! {
            Availabilities.setEventAvailabilitiesForUser(event.id, String(user.id), userAvailabilities)
            performSegue(withIdentifier: "toDashboard", sender: self)
        }
        else {
            for aView in selectableViewsStackView.arrangedSubviews {
                if let selectableView = aView as? SelectableView {
                    selectableView.unselectView()
                }
            }
        }
    }
 
    @IBAction func onCancelButtonClick(_ sender: Any) {
         self.performSegue(withIdentifier: "toDashboard", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboardView = segue.destination as? EventDashboardController {
            dashboardView.user = user
        }
        
        if let inviteView = segue.destination as? InviteViewController {
            inviteView.user = user
            inviteView.eventId = event.id
            inviteView.event = event
        }

    }



}
