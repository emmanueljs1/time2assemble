//
//  FillAvailViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class FillAvailViewController: UIViewController {

    @IBOutlet weak var timesStackView: UIStackView!
//    @IBOutlet weak var otherStackView: UIStackView!
    
    var selectableViews : [TimeView]!
    var lastDragLocation : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timesStackView.distribution = .fillEqually
        selectableViews = []
        for t in 0...23 {
            var time = String(t)
            time += ":00"
            let timeView = TimeView(time: time)
            selectableViews.append(timeView)
            timesStackView.addArrangedSubview(timeView)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func dragged(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: timesStackView)
        
        for timeView in selectableViews {
            let selectableView = timeView.selectableView
            let frame = selectableView.frame
            if frame.contains(location) && (lastDragLocation == nil || !frame.contains(lastDragLocation!)) {
                selectableView.selectTime()
            }
        }
        
        lastDragLocation = location
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: timesStackView)
        
        for timeView in selectableViews {
            let selectableView = timeView.selectableView
            if selectableView.frame.contains(location) {
                selectableView.selectTime()
            }
        }
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
