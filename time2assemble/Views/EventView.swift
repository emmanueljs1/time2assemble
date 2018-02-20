//
//  EventView.swift
//  time2assemble
//
//  Created by Jane Xu on 2/19/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

class EventView: UIStackView {
    init(eventName name: String, description desc: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        axis = .vertical
        
        let descTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 50), textContainer: nil)
        descTextView.isEditable = false
        descTextView.isSelectable = false
        descTextView.text = name
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.textAlignment = .left
        label.text = desc
        
        addArrangedSubview(label);
        addArrangedSubview(descTextView);
    }
    
    required init(coder aDecoder: NSCoder) {
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
