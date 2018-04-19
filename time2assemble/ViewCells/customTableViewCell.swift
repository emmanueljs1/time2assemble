//
//  customTableViewCell.swift
//  time2assemble
//
//  Created by Julia Chun on 4/15/18.
//  Copyright © 2018 Julia, Emma, Hana, Jane. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell {
    

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    
        // Configure the view for the selected state
    }
    
    var showDetails = false {
        didSet {
            infoHeightConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(showDetails ? 250 : 999))
        }
    }
    
}

