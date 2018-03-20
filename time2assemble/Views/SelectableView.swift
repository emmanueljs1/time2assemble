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
