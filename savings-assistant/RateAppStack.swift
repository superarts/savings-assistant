//
//  RateAppStack.swift
//  deadline-tracker
//
//  Created by Chris Amanse on 8/5/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//
//  This code is licensed under the MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class RateAppStack {
    private let _appLaunchesCountKey = "RateAppStack.AppLaunchesCount"
    var appLaunchesCount: Int {
        get {
            var number = NSUserDefaults.standardUserDefaults().objectForKey(_appLaunchesCountKey) as? NSNumber
            if number == nil {
                number = NSNumber(integer: 0)
                NSUserDefaults.standardUserDefaults().setObject(number, forKey: _appLaunchesCountKey)
            }
            return number!.integerValue
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(integer: newValue), forKey: _appLaunchesCountKey)
        }
    }
    private let _didRateAppKey = "RateAppStack.DidRateApp"
    var didRateApp: Bool {
        get {
            var number = NSUserDefaults.standardUserDefaults().objectForKey(_didRateAppKey) as? NSNumber
            if number == nil {
                number = NSNumber(bool: false)
                NSUserDefaults.standardUserDefaults().setObject(number, forKey: _didRateAppKey)
            }
            return number!.boolValue
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: newValue), forKey: _didRateAppKey)
        }
    }
    
    var targetCount: Int {
        #if DEBUG
            return 5
        #else
            return 10
        #endif
    }
    var resetTargetCount: Int {
        return 30
    }
    let rateLink = "itms-apps://itunes.apple.com/us/app/savings-assistant/id1022760996?ls=1&mt=8"
    
    private static let _sharedInstance = RateAppStack()
    static func sharedInstance() -> RateAppStack {
        return RateAppStack._sharedInstance
    }
    
    func incrementAppLaunches() {
        appLaunchesCount++
        
        println("> App launches: \(appLaunchesCount)")
        attemptShowRateAlert()
    }
    
    func attemptShowRateAlert() {
        // If did rate app
        if !didRateApp {
            if appLaunchesCount >= targetCount {
                println("! Should show rate alert")
                
                showRateAlert()
            }
        } else {
            if appLaunchesCount >= resetTargetCount {
                appLaunchesCount = 0
                didRateApp = false
            }
        }
    }
    func showRateAlert() {
        if let currentVC = getCurrentViewController() {
            let alertController = UIAlertController(title: "Rate Savings Assistant", message: "Like Savings Assistant? Please rate the app to help us improve it. Thank you! :)", preferredStyle: .Alert)
            
            let rateAction = UIAlertAction(title: "Rate", style: .Default, handler: { (alertAction) -> Void in
                self.openRateLink()
            })
            let laterAction = UIAlertAction(title: "Later", style: .Cancel, handler: { (alertAction) -> Void in
                self.appLaunchesCount = 0
            })
            
            alertController.addAction(rateAction)
            alertController.addAction(laterAction)
            
            currentVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func openRateLink() {
        if let rateURL = NSURL(string: rateLink) {
            didRateApp = UIApplication.sharedApplication().openURL(rateURL)
            println("DidOpenURL,DidRateApp: \(didRateApp)")
        }
    }
    
    private func getCurrentViewController() -> UIViewController? {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            // If navigation controller
            if let navigationController = rootVC as? UINavigationController {
                return navigationController.visibleViewController
            } else {
                var viewController = rootVC
                
                while let presentedVC = viewController.presentedViewController {
                    viewController = presentedVC
                }
                
                return viewController
            }
        }
        
        return nil
    }
}