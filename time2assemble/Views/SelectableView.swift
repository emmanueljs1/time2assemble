//
//  TimeView.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class SelectableView: UIView {
    
    var selected : Bool
    var isSelectable : Bool
    
    init(_ isSelectable: Bool) {
        selected = false
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
        super.init(coder: aDecoder)
        backgroundColor = .white
    }
    
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
    
    func unselectView() {
        if isSelectable {
            if selected {
                backgroundColor = .white
                selected = !selected
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
    
}
