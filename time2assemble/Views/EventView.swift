//
//  EventView.swift
//  time2assemble
//
//  Created by Jane Xu on 2/19/18.
//  Copyright © 2018 Julia Chun. All rights reserved.
//

import UIKit

//for events view controller; used to show list of events
class EventView: UIStackView {
    init(eventName name: String, description desc: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 343, height: 50))
        axis = .vertical
        
        //show event description in text view
        let descTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 343, height: 40))
        descTextView.isEditable = false
        descTextView.text = desc
        descTextView.textAlignment = .left
        
        //show event name in text view
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
