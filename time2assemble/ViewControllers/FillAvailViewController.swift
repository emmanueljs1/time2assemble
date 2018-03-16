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
    var timeViews : [TimeView]!
    var lastDragLocation : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeViews = [TimeView(), TimeView(), TimeView()]
        timesStackView.distribution = .fillEqually
        
        for timeView in timeViews {
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
        
        for timeView in timeViews {
            let frame = timeView.frame
            if frame.contains(location) && (lastDragLocation == nil || !frame.contains(lastDragLocation!)) {
                timeView.selectTime()
            }
        }
        
        lastDragLocation = location
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: timesStackView)
        
        for timeView in timeViews {
            if timeView.frame.contains(location) {
                timeView.selectTime()
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
