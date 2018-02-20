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
        super.init(frame: CGRect(x: 0, y: 0, width: 343, height: 50))
        axis = .vertical
        
        let descTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 343, height: 40))
        descTextView.isEditable = false
        descTextView.text = desc
        descTextView.textAlignment = .left
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 343, height: 10))
        label.textAlignment = .center
        label.text = name
        
        addArrangedSubview(label);
        addArrangedSubview(descTextView);
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
