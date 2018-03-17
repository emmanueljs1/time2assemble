//
//  TimeView.swift
//  time2assemble
//
//  Created by Julia Chun on 3/17/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class TimeView: UIStackView {
    
    var selectableView : SelectableView

    init(time: String) {
        selectableView = SelectableView()
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        axis = .horizontal
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        addArrangedSubview(label)
        label.text = time
        addArrangedSubview(selectableView)
    }
    
    required init(coder aDecoder: NSCoder) {
        selectableView = SelectableView()
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
