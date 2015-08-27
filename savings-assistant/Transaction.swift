//
//  Expense.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/31/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import RealmSwift

class Transaction: Object {
    dynamic var id: String = {
        // Generate UUID using random digit and UUID
        return "\(arc4random() % 10)-\(NSUUID().UUIDString)"
    }()
    dynamic var name: String = ""
    dynamic var amount: Double = 0
    dynamic var date: NSDate = NSDate()
    dynamic var notes: String = ""
    
    dynamic var account: Account?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
