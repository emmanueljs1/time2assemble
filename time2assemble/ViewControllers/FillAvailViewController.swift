//
//  FillAvailViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleAPIClientForREST

class FillAvailViewController: UIViewController {
    
    let oneDay = 24.0 * 60.0 * 60.0
    let oneHour = 60.0 * 60.0
    
    @IBOutlet weak var autofillFromGcalButton: UIButton!
    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var selectableViewsStackView: UIStackView!
    @IBOutlet weak var nextAndDoneButton: UIButton!
    @IBOutlet weak var currentDateLabel: UILabel!
    var user: User!
    var source: UIViewController!
    var event : Event!
    var availabilities: [String: [Int: Int]] = [:]
    var conflicts: [String: [Int:String]] = [:]
    var userAvailabilities: [String: [(Int, Int)]] = [:]
    var eventBeingCreated = false
    var selecting = true
    var currentDate: Date!
    let formatter = DateFormatter()
    let displayFormatter = DateFormatter()
    
    var lastDragLocation : CGPoint?
    
    func loadAvailabilitiesView(_ date: String) {
        let dateAvailabilities = availabilities[date] ?? [:]
        var maxCount = 0
        var minCount = 0
        
        for i in event.noEarlierThan...event.noLaterThan {
            let count = dateAvailabilities[i] ?? 0
            maxCount = max(count, maxCount)
            minCount = min(count, minCount)
        }
        
        for i in event.noEarlierThan...event.noLaterThan {
            let count = dateAvailabilities[i] ?? 0
            if let availabilityView = availabilitiesStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                availabilityView.selectViewWithDegree(count, maxCount, minCount)
            }
        }
    }
    
    //given a date, display all conflicts in hour range as conflicting to user
    func loadConflicts(_ date: String) {
        let dateConflicts = conflicts[date] ?? [:]
        for i in event.noEarlierThan...event.noLaterThan {
            if let _ = dateConflicts[i] { //if there is an event at scheduled at the hour
                if let selectableView = selectableViewsStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                    selectableView.selectViewWithWarning() //show warning of conflict
                }
            } else {
                if let selectableView = selectableViewsStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                    selectableView.selectViewWithoutWarning() //show no warning
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.date(from: event.startDate)
        
        displayFormatter.dateFormat = "EEEE, MMMM d"
        currentDateLabel.text = displayFormatter.string(from: currentDate)
        
        let endDate = formatter.date(from: event.endDate)
        
        if currentDate == endDate {
            nextAndDoneButton.setTitle("Done", for: .normal)
        }
        
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            autofillFromGcalButton.isHidden = false;
        } else {
            autofillFromGcalButton.isHidden = true;
        }
        
        timesStackView.distribution = .fillEqually
        selectableViewsStackView.distribution = .fillEqually
        availabilitiesStackView.distribution = .fillEqually
        availabilitiesStackView.axis = .vertical
        timesStackView.axis = .vertical
        selectableViewsStackView.axis = .vertical
        for t in event.noEarlierThan...event.noLaterThan {
            var rawTime = String(t)
            if t < 10 {
                rawTime = "0" + rawTime
            }
            rawTime += ":00"

            let rawTimeFormatter = DateFormatter()
            rawTimeFormatter.dateFormat = "HH:mm"
            let startTimeObject = rawTimeFormatter.date(from: rawTime)
            let endTimeObject = startTimeObject! + oneHour
            let displayTimeFormatter = DateFormatter()
            displayTimeFormatter.dateFormat = "h a"
            let startTime = displayTimeFormatter.string(from: startTimeObject!)
            let endTime = displayTimeFormatter.string(from: endTimeObject)
            let timeLabel = UILabel()
            timeLabel.text = startTime + " -\n" + endTime
            timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 12)
            timeLabel.numberOfLines = 2
            timesStackView.addArrangedSubview(timeLabel)
            
            selectableViewsStackView.addArrangedSubview(SelectableView(true))
            availabilitiesStackView.addArrangedSubview(SelectableView(true))
        }
        
        if !eventBeingCreated {
            Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
                self.availabilities = availabilities
                self.loadAvailabilitiesView(self.event.startDate)
            })
        }
        
        let dateStart = formatter.date(from: event.startDate)
        let dateEnd = formatter.date(from: event.endDate)
        
        //retrieve gcal events for user, then display conflicts for the first date of the event
        conflicts = Availabilities.getCalEventsForUser(String(user.id), dateStart!, dateEnd!, callback: {(events)-> () in
            events.forEach { (k,v) in self.conflicts[k] = v }
            self.loadConflicts(self.event.startDate)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveAvailability() {
        var startOpt : Int? = nil
        var ranges : [(Int, Int)] = []
        var i = event.noEarlierThan
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
        userAvailabilities[formatter.string(from: currentDate)] = ranges
        currentDate = currentDate + TimeInterval(oneDay)
        currentDateLabel.text = displayFormatter.string(from: currentDate)
    }
    
    
    @IBAction func onAutofillButtonClick(_ sender: Any) {
        for i in event.noEarlierThan...event.noLaterThan {
            if let selectableView = selectableViewsStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                if !selectableView.hasConflict {
                    selectableView.selectView();
                }
            }
        }
    }
    
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
            loadConflicts(formatter.string(from: currentDate))
            loadAvailabilitiesView(formatter.string(from: currentDate))
        }
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        if eventBeingCreated {
            self.performSegue(withIdentifier: "toDashboard", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "toEventDetails", sender: self)
        }
    }
    
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
        let location = sender.location(in: selectableViewsStackView)
        
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboardView = segue.destination as? EventDashboardController {
            dashboardView.user = user
        }
        if let eventCreationVC = segue.destination as? EventCreationViewController {
            eventCreationVC.user = user
        }
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = event
            eventDetailsVC.source = source
        }
        if let inviteView = segue.destination as? InviteViewController {
            inviteView.user = user
            inviteView.event = event
        }
    }
}
