//
//  UserDefaults.swift
//  tap-alliance
//
//  Created by Chris Amanse on 7/17/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import Foundation

struct UserDefaults {
    static func saveUserDefaultsWithObject(value: AnyObject?, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func getUserDefaultsObjectForKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    static var didRateApp: Bool {
        get {
            var number = getUserDefaultsObjectForKey(Keys.didRateApp) as? NSNumber
            if number == nil {
                number = NSNumber(bool: false)
                saveUserDefaultsWithObject(number, forKey: Keys.didRateApp)
            }
            return number!.boolValue
        }
        set {
            saveUserDefaultsWithObject(NSNumber(bool: newValue), forKey: Keys.didRateApp)
        }
    }
    
    static var numberOfAppLaunches: Int {
        get {
            var number = getUserDefaultsObjectForKey(Keys.numberOfAppLaunches) as? NSNumber
            if number == nil {
                number = NSNumber(integer: 0)
                saveUserDefaultsWithObject(number, forKey: Keys.numberOfAppLaunches)
            }
            return number!.integerValue
        }
        set {
            saveUserDefaultsWithObject(NSNumber(integer: newValue), forKey: Keys.numberOfAppLaunches)
        }
    }
    
    static var firstLaunch: Bool {
        get {
        var number = getUserDefaultsObjectForKey(Keys.firstLaunch) as? NSNumber
        if number == nil {
        number = NSNumber(bool: false)
        saveUserDefaultsWithObject(number, forKey: Keys.firstLaunch)
        }
        return number!.boolValue
        }
        set {
            saveUserDefaultsWithObject(NSNumber(bool: newValue), forKey: Keys.firstLaunch)
        }
    }
}

extension UserDefaults {
    struct Keys {
        private(set) static var didRateApp = "UserDefaults.DidRateApp"
        private(set) static var numberOfAppLaunches = "UserDefaults.numberOfAppLaunches"
        private(set) static var firstLaunch = "UserDefaults.FirstLaunch"
    }
    struct Defaults {
    }
}