//
//  AcknowledgementsViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 8/4/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import VTAcknowledgementsViewController

class AcknowledgementsViewController: VTAcknowledgementsViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "Avenir-Book", size: 17) ?? UIFont.preferredFontForTextStyle(UIApplication.sharedApplication().preferredContentSizeCategory)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let acknowledgement = acknowledgements?[indexPath.row] {
            let viewController = VTAcknowledgementViewController(title: acknowledgement.title, text: acknowledgement.text)
            viewController?.textView?.font = UIFont(name: "Avenir-Book", size: 13) ?? UIFont.preferredFontForTextStyle(UIApplication.sharedApplication().preferredContentSizeCategory)
            
            navigationController?.pushViewController(viewController!, animated: true)
        }
    }
}