//
//  TimeView.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

//for use in fill availability and finalize, color-coded to show conflicts, selected, and unselected
class SelectableView: UIView {
    
    var selected : Bool
    var isSelectable : Bool
    var hasConflict : Bool //eg, has a google calendar event scheduled at this time
    
    init(_ isSelectable: Bool) {
        selected = false
        hasConflict = false
        self.isSelectable = isSelectable
        super.init(frame: CGRect())
        if !isSelectable {
            backgroundColor = .lightGray
        }
        else {
            backgroundColor = .white
        }
        layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        selected = false
        isSelectable = true
        hasConflict = false
        super.init(coder: aDecoder)
        backgroundColor = .white
    }
    
    //display different colors depending on degree (where degree = num people free out of total)
    func selectViewWithDegree(_ degree: Int, _ maxDegree: Int, _ minDegree: Int) {
        let diff = (CGFloat(maxDegree) - CGFloat(minDegree)) / 5.0
        if degree <= 0 {
            let red = CGFloat(1.0)
            let blue = CGFloat(1.0)
            let green = CGFloat(1.0)
            let alpha = CGFloat(1.0)
            backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        else {
            let red = CGFloat(0.0)
            let blue = CGFloat(0.0)
            let green = CGFloat(1.0 - (CGFloat(degree) / CGFloat(diff)) * 0.07)
            let alpha = CGFloat(1.0)
            backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    //show red background to show to user there is a calendar conflict
    func selectViewWithWarning() {
        hasConflict = true;
        if isSelectable {
            let red = CGFloat(1.0)
            let blue = CGFloat(0.0)
            let green = CGFloat(0.0)
            let alpha = CGFloat(0.5)
            backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    //show to user there is no warning
    func selectViewWithoutWarning() {
        hasConflict = false;
        if isSelectable {
            if selected {
                backgroundColor = .green
            } else {
                backgroundColor = .white
            }
        }
    }
    
    //deselect view and show appropriate background color
    func unselectView() {
        if isSelectable {
            if selected {
                selected = !selected
                if hasConflict {
                    let red = CGFloat(1.0)
                    let blue = CGFloat(0.0)
                    let green = CGFloat(0.0)
                    let alpha = CGFloat(0.5)
                    backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                } else {
                    backgroundColor = .white
                }
            }
            
            
        }
    }
    
    func selectView() {
        if isSelectable {
            if !selected {
                backgroundColor = .green
                selected = !selected
            }
            
        }
    }
    
    func unclickView() {
        if isSelectable {
            if selected {
                selected = !selected
            }
        }
    }
    
    func clickView() {
        if isSelectable {
            if !selected {
                selected = !selected
            }
        }
    }
    
}

