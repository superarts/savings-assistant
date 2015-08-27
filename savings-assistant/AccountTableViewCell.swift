//
//  AccountTableViewCell.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/30/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    static let estimatedRowHeight: CGFloat = 64
    
    func updateAmountLabelTextColorForAmount(amount: Double) {
        if amount < 0 {
            detailTextLabel?.textColor = Globals.Colors.negativeColor
        } else {
            detailTextLabel?.textColor = Globals.Colors.positiveColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
