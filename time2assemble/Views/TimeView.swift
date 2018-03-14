//
//  TimeView.swift
//  time2assemble
//
//  Created by Emmanuel Suarez on 3/14/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class TimeView: UIView {
    
    var selected : Bool
    
    init() {
        selected = false
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        backgroundColor = .white
        layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        selected = false
        super.init(coder: aDecoder)
        backgroundColor = .white
    }
    
    func selectTime() {
        if selected {
            backgroundColor = .white
        }
        else {
            backgroundColor = .green
        }
        selected = !selected
    }
    
}
