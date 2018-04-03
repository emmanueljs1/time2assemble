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
    
    @IBOutlet weak var allAvailabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var setFinalTimeButton: UIButton!
    
    var user: User!
    var event : Event!
    var availabilities: [String: [Int: Int]] = [:]
    var ref: DatabaseReference!
    var finalizedTime:  [String: [(Int, Int)]] = [:]
    var diff: Int!
    var startDate: Date!
    let dateFormatter = DateFormatter()
    
    @IBAction func onSetFinalTimeButtonClick() {
        setFinalTimeButton.titleLabel?.text = "Finalize"
        
        for d in 0...(diff - 1) {
            print("word")
            let availabiltiesStackView = allAvailabilitiesStackView.arrangedSubviews[d] as! AvailabilitiesView
            allAvailabilitiesStackView.removeArrangedSubview(availabiltiesStackView)
            availabiltiesStackView.isSelectable = true
            allAvailabilitiesStackView.insertArrangedSubview(availabiltiesStackView, at: d)
        }
    }
    
    @IBAction func daySelected(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: allAvailabilitiesStackView)
        var i = 0
        
        for availabilityView in allAvailabilitiesStackView.arrangedSubviews {
            if availabilityView.frame.contains(location) {
                performSegue(withIdentifier: "toFinalizeDayAvailController", sender: allAvailabilitiesStackView.arrangedSubviews[i])
            }
            i += 1
        }
    }
    
    func loadAvailabilitiesView() {
     
        for d in 0...(diff - 1) {
            let interval = TimeInterval(60 * 60 * 24 * d)
            let dateObj = startDate.addingTimeInterval(interval)
            let date: String = dateFormatter.string(from: dateObj)
        
            let dateAvailabilities = availabilities[date] ?? [:]
            
            var maxCount = 0
            var minCount = 0
            for i in 8...22 {
                let count = dateAvailabilities[i] ?? 0
                maxCount = max(count, maxCount)
                minCount = min(count, minCount)
            }

            let availabilitiesStackView = allAvailabilitiesStackView.arrangedSubviews[d] as! UIStackView
            for i in 8...22 {
                let count = dateAvailabilities[i] ?? 0
                if let availabilityView = availabilitiesStackView.arrangedSubviews[i - 8] as? SelectableView {
                    availabilityView.selectViewWithDegree(count, maxCount, minCount)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    
        for d in 1...diff {
            
            print("before attempting to create avail view")
            let availabilitiesStackView = AvailabilitiesView(false)
            print(availabilities)
            availabilitiesStackView.distribution = .fillEqually
            availabilitiesStackView.axis = .vertical
            print("Created new stack")
            for t in 8...22 {
                var time = String(t)
                if t < 10 {
                    time = "0" + time
                }
                time += ":00"
                let timeLabel = UILabel(frame: CGRect ())
                timeLabel.text = time

                if d == 1 {timesStackView.addArrangedSubview(timeLabel)}

                var selectable = true
                if t < event.noEarlierThan || t > event.noLaterThan  {
                    selectable = false
                }
                availabilitiesStackView.addArrangedSubview(SelectableView(selectable))
            }
            allAvailabilitiesStackView.addArrangedSubview(availabilitiesStackView)
        }
        
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
            self.loadAvailabilitiesView()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let finalizeVC = segue.destination as? FinalizeAvailabilityViewController {
            finalizeVC.user = user
            finalizeVC.event = event
            finalizeVC.timesStackView = timesStackView
            finalizeVC.availabilities = availabilities
            finalizeVC.tempStackView = sender
        }
        if let eventDetailsVC = segue.destination as? EventDetailsViewController {
            eventDetailsVC.user = user
            eventDetailsVC.event = event
        }
    }
}
