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
    
    init() {
        selected = false
        isSelectable = true // change this by taking in time
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        backgroundColor = .white
        layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        selected = false
        isSelectable = true // change this by taking in time
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
