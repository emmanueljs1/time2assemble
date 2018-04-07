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
    
    let oneDay = 24.0 * 60.0 * 60.0
    
    @IBOutlet weak var allAvailabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var selectDateTextLabel: UILabel!
    
    var user: User!
    var event: Event!
    var source: UIViewController!
    var availabilities: [String: [Int: Int]] = [:]
    var availableUsers: [String: [Int:[String]]] = [:]

    var ref: DatabaseReference!
    var finalizedTime:  [String: [(Int, Int)]] = [:]
    var diff: Int!
    var startDate: Date!
    var selectedDate: Date!
    let dateFormatter = DateFormatter()
    
    func loadAvailabilitiesView(count: Int) {
        if count < 2 {
            return
        }

        for d in 0...(diff - 1) {
            let interval = TimeInterval(60 * 60 * 24 * d)
            let dateObj = startDate.addingTimeInterval(interval)
            let date: String = dateFormatter.string(from: dateObj)
            
            let dateAvailabilities = availabilities[date] ?? [:]
            
            var maxCount = 0
            var minCount = 0
            for i in event.noEarlierThan...event.noLaterThan {
                let count = dateAvailabilities[i] ?? 0
                maxCount = max(count, maxCount)
                minCount = min(count, minCount)
            }
            
            let availabilitiesStackView = allAvailabilitiesStackView.arrangedSubviews[d] as! UIStackView
            for i in event.noEarlierThan...event.noLaterThan {
                let count = dateAvailabilities[i] ?? 0
                if let availabilityView = availabilitiesStackView.arrangedSubviews[i - event.noEarlierThan] as? SelectableView {
                    availabilityView.selectViewWithDegree(count, maxCount, minCount)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event.creator == user.id {
            selectDateTextLabel.isHidden = false
        }
        
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
        
        for t in event.noEarlierThan...event.noLaterThan {
            var rawTime = String(t)
            if t < 10 {
                rawTime = "0" + rawTime
            }
            rawTime += ":00"
            
            let rawTimeFormatter = DateFormatter()
            rawTimeFormatter.dateFormat = "HH:mm"
            let timeObject = rawTimeFormatter.date(from: rawTime)
            let displayTimeFormatter = DateFormatter()
            displayTimeFormatter.dateFormat = "h a"
            let time = displayTimeFormatter.string(from: timeObject!)
            let timeLabel = UILabel(frame: CGRect ())
            timeLabel.text = time
            timesStackView.addArrangedSubview(timeLabel)
        }
        
        for _ in 1...diff {
            let availabilitiesStackView = AvailabilitiesView(false)
            print(availabilities)
            availabilitiesStackView.distribution = .fillEqually
            availabilitiesStackView.axis = .vertical
            for _ in event.noEarlierThan...event.noLaterThan {
                availabilitiesStackView.addArrangedSubview(SelectableView(true))
            }
            allAvailabilitiesStackView.addArrangedSubview(availabilitiesStackView)
        }
        var count = 0
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
            count += 1
            self.loadAvailabilitiesView(count: count)
        })
        
        Availabilities.getAllAvailUsers(event.id, callback: { (availableUsers) -> () in
            self.availableUsers = availableUsers
            count += 1
            self.loadAvailabilitiesView(count: count)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func daySelected(_ sender: UITapGestureRecognizer) {
        if event.creator == user.id {
            let location = sender.location(in: allAvailabilitiesStackView)
            var i = 0
            
            for availabilityView in allAvailabilitiesStackView.arrangedSubviews {
                if availabilityView.frame.contains(location) {
                    selectedDate = startDate + (Double(i) * oneDay)
                    performSegue(withIdentifier: "toFinalizeDayAvailController", sender: allAvailabilitiesStackView.arrangedSubviews[i])
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
            finalizeVC.availableUsers = availableUsers[date]!
        }
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.source = source
            eventDetailsVC.event = event
        }
    }
}
