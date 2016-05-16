//
//  SettingsViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 8/4/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    var indexPathForAcknowledgements: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath {
        case indexPathForAcknowledgements:
            if let plistPath = NSBundle.mainBundle().pathForResource("Pods-savings-assistant-acknowledgements", ofType: "plist") {
                let viewController = AcknowledgementsViewController(acknowledgementsPlistPath: plistPath)
                let navController = UINavigationController(rootViewController: viewController!)
                splitViewController?.showDetailViewController(navController, sender: self)
            }
        default:
            break
        }
    }
}


