//
//  AvailabilitiesView.swift
//  time2assemble
//
//  Created by Julia Chun on 4/1/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

//used for clicking the cells to display names of people available during the time
class AvailabilitiesView: UIStackView {
    
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

    required init(coder aDecoder: NSCoder) {
        selected = false
        isSelectable = true
        super.init(coder: aDecoder)
        backgroundColor = .white
    }
    
    func makeSelectable() {
        
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
