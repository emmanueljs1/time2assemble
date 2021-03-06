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


// View of the single day availabilities where creator can mark final time to finalize a time
// for the event
class FinalizeAvailabilityViewController: UIViewController {

    let oneDay = 24.0 * 60.0 * 60.0
    let oneHour = 60.0 * 60.0
    
    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var selectableViewsStackView: UIStackView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var availParticipantsTextView: UITextView!
    @IBOutlet weak var legendStackView: UIStackView!
    
    var tempStackView: Any!
    var source: UIViewController!
    var user: User!
    var event : Event!
    var eventId: String!
    var availabilities: [String: [Int: Int]] = [:]
    var availableUsers: [Int:[User]] = [:]
    var participants: [User]!

    var diff: Int!

    var selecting = true
    var lastDragLocation : CGPoint?
    
    var finalizedTime:  [String: [(Int, Int)]] = [:]
    var eventBeingCreated = false

    var currentDate: Date!
    let formatter = DateFormatter()

    // Load view with stacks that show single day's availability of all people
    // As in EventAvailabilitesVC, display appripriate time labels and populate
    // stack with correctly colored views depending on # people available.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display Legend
        legendStackView.distribution = .fillEqually
        if (participants == nil) {
            participants = []
        }
        let numPeople = participants.count
        let leftLegendText = " 0/" + String(numPeople)
        let rightLegendText = " " + String(numPeople) + "/" + String(numPeople)
        
        let leftLabel = UILabel()
        leftLabel.font = UIFont(name: leftLabel.font.fontName, size: 10)
        leftLabel.text = leftLegendText
        let rightLabel = UILabel()
        rightLabel.font = UIFont(name: rightLabel.font.fontName, size: 10)
        rightLabel.text = rightLegendText
        
        legendStackView.addArrangedSubview(leftLabel)
        
        for i in 0...4 {
            let selectableView = SelectableView(true)
            selectableView.selectViewWithDegree(i, 5, 0)
            legendStackView.addArrangedSubview(selectableView)
        }
        
        legendStackView.addArrangedSubview(rightLabel)
        
        
        // Setup stack layouts
        formatter.dateFormat = "yyyy-MM-dd"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "EEEE, MMMM d"
        currentDateLabel.text = displayFormatter.string(from: currentDate)
        
        timesStackView.distribution = .fillEqually
        timesStackView.axis = .vertical
        
        availabilitiesStackView.distribution = .fillEqually
        availabilitiesStackView.axis = .vertical
        availabilitiesStackView.addArrangedSubview(tempStackView as! UIView)
        
        selectableViewsStackView.distribution = .fillEqually
        selectableViewsStackView.axis = .vertical
        
        
        // Display time labels and add selectable views to stack
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
            let timeLabel = UILabel(frame: CGRect ())
            timeLabel.text = startTime + " -\n" + endTime
            timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 12)
            timeLabel.numberOfLines = 2
            timesStackView.addArrangedSubview(timeLabel)
            selectableViewsStackView.addArrangedSubview(SelectableView(true))
        }
        
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
        })
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Store selected time into finalizedTime
    func saveFinalizedTime() {
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
        if let start = startOpt {
            ranges += [(start, event.noLaterThan)]
        }
        finalizedTime[formatter.string(from: currentDate)] = ranges
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
    
    
    // Function for displaying available/unavailable users at a certain time slot.
    // Double clocking gets rid of text and clicking displays users both available and unavailabe
    // at a certain time slot.
    @IBAction func availabilitesClicked(_ sender: UITapGestureRecognizer) {
    
        let location = sender.location(in: availabilitiesStackView)
        
        let tempStackView = availabilitiesStackView.arrangedSubviews[0] as! UIStackView
        var i = event.noEarlierThan
        
        for aView in tempStackView.arrangedSubviews {
            if let selectableView = aView as? SelectableView {
                if selectableView.frame.contains(location) {
                    if !selectableView.selected {
                        selectableView.clickView()
                        
                        let availUsers = availableUsers[i]
                        var unavailUsers = [] as [User]
                        
                        for user in participants {
                            if availUsers?.contains(user)  == false {
                                unavailUsers.append(user)
                            }
                        }
                    
                        var text = "Available:\n"
                        if availUsers == nil {
                            unavailUsers = participants
                        } else {
                            for user in availUsers! {
                                text += user.firstName + " "  + user.lastName + "\n"
                            }
                        }
                
                        text += "\nUnavailable:\n"
                        for user in unavailUsers {
                            text += user.firstName + " "  + user.lastName + "\n"
                        }
                        availParticipantsTextView.text = text
                        
                    } else {
                        selectableView.unclickView()
                        availParticipantsTextView.text = ""
                    }
                }
            }
            i += 1
        }
    }
    
    // Writes to firebase the finalized time for the event and performs appropriate segueway.
    @IBAction func onFinalizeTimeClick(_ sender: UIButton) {
        // save the filed availability for current date
        saveFinalizedTime()
        FirebaseController.setFinalizedEventTimes(event, finalizedTime)
        FirebaseController.clearUsersWhoAddedToGCal(event.id)
        self.performSegue(withIdentifier: "toEventDetails", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = event
            eventDetailsVC.source = source
        }
        if let eventAvailsVC = segue.destination as? EventAvailabilitiesViewController {
            eventAvailsVC.user = user
            eventAvailsVC.event = event
            eventAvailsVC.source = source
            eventAvailsVC.participants = participants
        }
    }
    
}

