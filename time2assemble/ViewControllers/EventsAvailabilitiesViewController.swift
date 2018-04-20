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

//show all availabilities for an event for <= 7 dates of an event
class EventAvailabilitiesViewController: UIViewController {
    
    let oneDay = 24.0 * 60.0 * 60.0
    let oneHour = 60.0 * 60.0
    let daysInAWeek = 7
    
    @IBOutlet weak var allAvailabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var datesStackView: UIStackView!
    @IBOutlet weak var selectDateTextLabel: UILabel!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var prevWeekButton: UIButton!
    
    var user: User!
    var event: Event!
    var source: UIViewController!
    var availabilities: [String: [Int: Int]] = [:]
    var availableUsers: [String: [Int:[User]]] = [:]
    var participants: [User]!
    var addDateLabels = true
    var ref: DatabaseReference!
    var finalizedTime:  [String: [(Int, Int)]] = [:]
    var diff: Int!
    var currStartDate = 0
    var startDate: Date!
    var selectedDate: Date!
    let dateFormatter = DateFormatter()
    var maxCount = 0
    var minCount = 0
    
    //determine how many invitees are available for a given hour and display visually with color
    func loadAvailabilitiesView() {
        var index = 0
        
        for d in currStartDate..<(currStartDate + daysInAWeek) {
            let dateObj = startDate! + (oneDay * Double(d))
            let date: String = dateFormatter.string(from: dateObj)
            
            let dateAvailabilities = availabilities[date] ?? [:]
            
            let availabilitiesStackView = allAvailabilitiesStackView.arrangedSubviews[index] as! UIStackView
            
            if addDateLabels {
                let dateLabel = UILabel()
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "MM/dd"
                dateLabel.text = displayDateFormatter.string(from: dateObj)
                dateLabel.textAlignment = .center
                dateLabel.font = UIFont(name: dateLabel.font.fontName, size: 10)
                datesStackView.addArrangedSubview(dateLabel)
            }
            
            for i in event.noEarlierThan...event.noLaterThan {
                let count = dateAvailabilities[i] ?? 0
                if let availabilityView = availabilitiesStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                    availabilityView.selectViewWithDegree(count, maxCount, minCount)
                }
            }
            index += 1
        }
        addDateLabels = false
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
        if event.creator == user.id {
            selectDateTextLabel.isHidden = false
        }
        
        datesStackView.distribution = .fillEqually
        timesStackView.distribution = .fillEqually
        timesStackView.axis = .vertical
        
        allAvailabilitiesStackView.distribution = .fillEqually
        allAvailabilitiesStackView.axis = .horizontal
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: event.startDate)
        let endDate = dateFormatter.date(from: event.endDate)
        let components = Set<Calendar.Component>([.day])
        let numDates = Calendar.current.dateComponents(components, from: startDate!, to: endDate!)
        let diff = numDates.day! + 1
        
        self.diff = diff
        self.startDate = startDate
        
        prevWeekButton.isHidden = true
        
        if currStartDate + daysInAWeek >= diff {
            nextWeekButton.isHidden = true
        }
        
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
        }
        
        for _ in 1...daysInAWeek {
            let availabilitiesStackView = AvailabilitiesView(false)
            availabilitiesStackView.distribution = .fillEqually
            availabilitiesStackView.axis = .vertical
            for _ in event.noEarlierThan...event.noLaterThan {
                availabilitiesStackView.addArrangedSubview(SelectableView(true))
            }
            allAvailabilitiesStackView.addArrangedSubview(availabilitiesStackView)
        }
        
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
            
            Availabilities.getAllAvailUsers(self.event.id, callback: { (availableUsers) -> () in
                self.availableUsers = availableUsers
                
                for d in 0..<diff {
                    let dateObj = startDate! + (self.oneDay * Double(d))
                    let date: String = self.dateFormatter.string(from: dateObj)
                    let dateAvailabilities = availabilities[date] ?? [:]
                    for i in self.event.noEarlierThan...self.event.noLaterThan {
                        let count = dateAvailabilities[i] ?? 0
                        self.maxCount = max(count, self.maxCount)
                        self.minCount = min(count, self.minCount)
                    }
                }
                
                self.loadAvailabilitiesView()
            })
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func prevWeekButtonSelected(_ sender: UIButton) {
        currStartDate -= daysInAWeek
        addDateLabels = true
        
        for subview in datesStackView.arrangedSubviews {
            datesStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        if currStartDate <= 0 {
            prevWeekButton.isHidden = true
        }
        
        loadAvailabilitiesView()
        nextWeekButton.isHidden = false
    }
    
    @IBAction func nextWeekButtonSelected(_ sender: UIButton) {
        currStartDate += daysInAWeek
        addDateLabels = true
        
        for subview in datesStackView.arrangedSubviews {
            datesStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        if currStartDate + daysInAWeek >= diff {
            nextWeekButton.isHidden = true
        }
        
        loadAvailabilitiesView()
        prevWeekButton.isHidden = false
    }
    
    //when a day is selected, segue to finalize controller, to let the owner select a final time
    @IBAction func daySelected(_ sender: UITapGestureRecognizer) {
        if event.creator == user.id {
            let location = sender.location(in: allAvailabilitiesStackView)
            var i = 0
            
            for availabilityView in allAvailabilitiesStackView.arrangedSubviews {
                if availabilityView.frame.contains(location) {
                    selectedDate = startDate + (Double(i + currStartDate) * oneDay)
                    let endDateObj = dateFormatter.date(from: event.endDate)
                    if selectedDate <= endDateObj! {
                        performSegue(withIdentifier: "toFinalizeDayAvailController", sender: allAvailabilitiesStackView.arrangedSubviews[i])
                    }
                }
                i += 1
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let finalizeVC = segue.destination as? FinalizeAvailabilityViewController {
            finalizeVC.user = user
            finalizeVC.event = event
            finalizeVC.source = source
            finalizeVC.currentDate = selectedDate
            finalizeVC.timesStackView = timesStackView
            finalizeVC.availabilities = availabilities
            finalizeVC.tempStackView = sender
            
            let displayTimeFormatter = DateFormatter()
            displayTimeFormatter.dateFormat = "yyyy-MM-dd"
            let date = displayTimeFormatter.string(from: selectedDate)
            finalizeVC.availableUsers = availableUsers[date] ?? [:]
            finalizeVC.participants = participants
        }
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.source = source
            eventDetailsVC.event = event
        }
    }
}
