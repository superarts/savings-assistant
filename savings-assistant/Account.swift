//
//  Account.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/31/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import RealmSwift

class Account: Object {
    dynamic var id: String = {
        // Generate UUID using random digit and UUID
        return "\(arc4random() % 10)-\(NSUUID().UUIDString)"
    }()
    
    dynamic var name: String = ""
    dynamic var notes: String = ""
    
    var transactions: [Transaction] {
        return linkingObjects(Transaction.self, forProperty: "account")
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var totalAmount: Double {
        return transactions.reduce(0, combine: { $0 + $1.amount })
    }
}
