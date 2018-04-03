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

    @IBOutlet weak var availabilitiesStackView: UIStackView!
    @IBOutlet weak var timesStackView: UIStackView!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var selectableViewsStackView: UIStackView!
    
    var tempStackView: Any!
    var source: UIViewController!
    var user: User!
    var event : Event!
    var eventId: String!
    var availabilities: [String: [Int: Int]] = [:]
    var ref: DatabaseReference!
    var selecting = true
    var lastDragLocation : CGPoint?
    
    var allFinalizedTime: [String: [(Int, Int)]] = [:]
    var finalizedTime:  [String: [(Int, Int)]] = [:]
    var eventBeingCreated = false

    var currentDate: Date!
    let formatter = DateFormatter()
    let oneDay = 24.0 * 60.0 * 60.0
    @IBOutlet weak var currentDateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timesStackView.distribution = .fillEqually
        timesStackView.axis = .vertical
        
        availabilitiesStackView.distribution = .fillEqually
        availabilitiesStackView.axis = .vertical
        availabilitiesStackView.addArrangedSubview(tempStackView as! UIView)
        
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
            selectableViewsStackView.addArrangedSubview(SelectableView(selectable))
        }
        
        Availabilities.getAllEventAvailabilities(event.id, callback: { (availabilities) -> () in
            self.availabilities = availabilities
        })
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // Store selected time into finalizedTime
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
        finalizedTime[formatter.string(from: currentDate)] = ranges
        currentDate = currentDate + TimeInterval(oneDay)
        currentDateLabel.text = formatter.string(from: currentDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventAvailVC = segue.destination as? EventAvailabilitiesViewController {
            eventAvailVC.finalizedTime = allFinalizedTime
            eventAvailVC.event = event
            eventAvailVC.user = user
            eventAvailVC.source = source
        }
    }
    
    @IBAction func onAddClick(_ sender: UIButton) {
        // save the filed availability for current date
        saveAvailability()
        finalizedTime.forEach { (k,v) in allFinalizedTime[k] = v }
        self.performSegue(withIdentifier: "toViewController", sender: self)
    }
}

