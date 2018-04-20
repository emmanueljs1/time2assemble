//
//  EventCreationViewController.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 2/13/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit
import Firebase

class EventCreationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    static let oneDay = 24.0 * 60.0 * 60.0
    let oneWeek = oneDay * 7.0

    var timeRanges : [String] = []
    
    var user: User!

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var timeRangesPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimeRanges()
        setupPickers()
        timeRangesPicker.dataSource = self
        timeRangesPicker.delegate = self
        timeRangesPicker.reloadAllComponents()
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
        setMinDate()
        endDatePicker.maximumDate = startDatePicker.minimumDate! + oneWeek
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
    
    // MARK: - UIPickerViewDataSource methods
    
    func loadTimeRanges() {
        for i in 1...11 {
            timeRanges += ["\(i) am - \(i) pm"]
        }
        timeRanges = ["12 am - 12 pm"] + timeRanges + ["12 pm - 12 am"]
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeRanges.count
    }
    
    // MARK: - UIPickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeRanges[row]
    }
    
    // MARK: - Actions
    
    @IBAction func onInviteButtonClick(_ sender: Any) {
        //** Get Date Information **//
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = startDateFormatter.string(from: startDatePicker.date)
        
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "yyyy-MM-dd"
        let endDate = endDateFormatter.string(from: endDatePicker.date)

        //** Get Time Information **//
        let timeRangeStart = timeRangesPicker.selectedRow(inComponent: 0)
        let timeRangeEnd = timeRangeStart + 11
        
        let event = Event(eventNameTextField.text!, user.id, [], descriptionTextField.text!, "", timeRangeStart, timeRangeEnd, startDate, endDate, [:])
        self.performSegue(withIdentifier: "toFill", sender: event)
    }
    
    @IBAction func startDatePicked(_ sender: UIDatePicker) {
        endDatePicker.maximumDate = sender.date + oneWeek
        endDatePicker.minimumDate = sender.date
    }
    
    
    // MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsView = segue.destination as? SettingsViewController {
            settingsView.user = user
        }
    
        if let fillAvailView = segue.destination as? FillAvailViewController {
            fillAvailView.event = sender as! Event!
            fillAvailView.eventBeingCreated = true
            fillAvailView.user = user
        }
    }
    
}
