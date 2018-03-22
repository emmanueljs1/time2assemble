//
//  EventCreationViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventCreationViewController: UIViewController {

    var user: User!
    var ref: DatabaseReference!
    var eventId: String!

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupPickers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        eventNameTextField.text = ""
        descriptionTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPickers() {
        
        startDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker.datePickerMode = UIDatePickerMode.date
        startTimePicker.datePickerMode = UIDatePickerMode.time
        endTimePicker.datePickerMode = UIDatePickerMode.time
        setMinDate()
        setMinMaxTime()
    }
    
    func setMinDate() {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: Date = Date()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = 0
        let minDate: Date = gregorian.date(byAdding: components as DateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        startDatePicker.minimumDate = minDate
        endDatePicker.minimumDate = minDate
    }
    
    // OPTIONAL TODO
    func setMinMaxTime() {
       
    }
    
    // OPTIONAL TODO
    func setMaxDate() {
        // let maxDate: Date = gregorian.date(byAdding: components as DateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        // endDatepicker.maximumDate = maxDate
    }
    
    @IBAction func onInviteButtonClick(_ sender: Any) {
        
        //** Get Date Information **//
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = startDateFormatter.string(from: startDatePicker.date)
        
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "yyyy-MM-dd"
        let endDate = endDateFormatter.string(from: endDatePicker.date)

        //** Get Time Information **//
        let startTimeFormatter = DateFormatter()
        startTimeFormatter.dateFormat = "HH"
        let start = startTimePicker.date
        let startTime = Int(startTimeFormatter.string(from: start))
        
        let endTimeFormatter = DateFormatter()
        endTimeFormatter.dateFormat = "HH"
        let end = endTimePicker.date
        let endTime = Int(endTimeFormatter.string(from: end))
    
        // Change defaualts
        let event = Event(eventNameTextField.text!, user.id, [], descriptionTextField.text!, "", startTime!, endTime!, startDate, endDate)
        self.performSegue(withIdentifier: "toFill", sender: event)
    }
    
    // MARK: - Navigation
    // got rid of override
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    
        if let fillAvailView = segue.destination as? FillAvailViewController {
            fillAvailView.ref = ref
            fillAvailView.event = sender as! Event!
            fillAvailView.eventBeingCreated = true
            //fillAvailView.event = Event(eventNameTextField.text!, user.id, [], descriptionTextField.text!, "-L84aBTenzy_xzBBduab", 10, 16, "2018-03-20", "2018-03-20")
            fillAvailView.user = user
        }
    }
    
}
