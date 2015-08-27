//
//  AppDelegate.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/27/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.preferredDisplayMode = .AllVisible
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        // Change appearances
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let font = UIFont(name: "Avenir-Medium", size: 17) ?? UIFont.preferredFontForTextStyle(UIApplication.sharedApplication().preferredContentSizeCategory)
        let captionFont = font.fontWithSize(11)
        let foregroundColor = Globals.Colors.foregroundColor
        let backgroundColor = Globals.Colors.backgroundColor
        let selectedColor = Globals.Colors.selectedColor
        
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.tintColor = foregroundColor
        navBarAppearance.barTintColor = backgroundColor
        navBarAppearance.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: foregroundColor]
        
        let toolBarAppearance = UIToolbar.appearance()
        toolBarAppearance.tintColor = foregroundColor
        toolBarAppearance.barTintColor = backgroundColor
        
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.tintColor = foregroundColor
        barButtonAppearance.setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = selectedColor
        tabBarAppearance.barTintColor = backgroundColor
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        tabBarItemAppearance.setTitleTextAttributes([NSForegroundColorAttributeName : foregroundColor, NSFontAttributeName : captionFont], forState: .Normal)
        tabBarItemAppearance.setTitleTextAttributes([NSForegroundColorAttributeName : selectedColor, NSFontAttributeName : captionFont], forState: .Selected)
        
        // Initial data on first launch
        if UserDefaults.firstLaunch {
            let account1 = Account()
            account1.name = "Allowance"
            
            let account2 = Account()
            account2.name = "Savings"
            
            // Save account
            let realm = Realm()
            realm.write({ () -> Void in
                realm.add(account1, update: true)
                realm.add(account2, update: true)
            })
            
            let transaction1 = Transaction()
            transaction1.account = account1
            transaction1.name = "Transportation"
            transaction1.amount = -20
            transaction1.date = NSDate.yesterday().previous(.Hour)
            
            let transaction2 = Transaction()
            transaction2.account = account1
            transaction2.name = "Gift"
            transaction2.amount = 100
            transaction2.date = NSDate()
            
            // Save transaction
            realm.write { () -> Void in
                realm.add(transaction1, update: true)
                realm.add(transaction2, update: true)
            }
            
            UserDefaults.firstLaunch = false
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        RateAppStack.sharedInstance().incrementAppLaunches()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Convenience functions
    
    func getCurrentViewController() -> UIViewController? {
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

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.account == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        if splitViewController.collapsed {
            let tabBarController = splitViewController.viewControllers.first as! UITabBarController
            let selectedNavigationViewController = tabBarController.selectedViewController as! UINavigationController
            
            // Push view controller
            var viewControllerToPush = vc
            if let navController = vc as? UINavigationController {
                viewControllerToPush = navController.topViewController
            }
            selectedNavigationViewController.pushViewController(viewControllerToPush, animated: true)
            
            return true
        }
        
        return false
    }
}

