//
//  ExpenseTableViewCell.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/31/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var expenseTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let estimatedRowHeight: CGFloat = 60
    
    func updateAmountLabelTextColorForAmount(amount: Double) {
        if amount < 0 {
            amountLabel.textColor = Globals.Colors.negativeColor
        } else {
            amountLabel.textColor = Globals.Colors.positiveColor
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
