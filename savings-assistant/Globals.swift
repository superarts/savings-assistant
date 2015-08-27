//
//  Global.swift
//  savings-assistant
//
//  Created by Chris Amanse on 8/2/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

struct Globals {
    struct Colors {
        static var positiveColor: UIColor { return UIColor(red: 0, green: 40/255, blue: 1, alpha: 1) }
        static var negativeColor: UIColor { return UIColor(red: 1, green: 15/255, blue: 0, alpha: 1) }
        
        static var backgroundColor: UIColor { return UIColor(red: 0, green: 160/255, blue: 73/255, alpha: 1) }
        static var foregroundColor: UIColor { return UIColor.whiteColor() }
        
        static var selectedColor: UIColor { return UIColor(red: 228/255, green: 255/255, blue: 100/255, alpha: 1) }
    }
}