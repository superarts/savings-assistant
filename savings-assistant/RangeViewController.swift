//
//  RangeViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 8/3/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit

class RangeViewController: UITableViewController {

    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var dateRange: DateRange = DateRange(startDate: NSDate().startOf(.Day), endDate: NSDate().endOf(.Day))
    
    weak var delegate: RangeViewControllerDelegate?
    
    var editingStartDate = false
    var editingEndDate = false
    var indexPathForStartDateLabel: NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    var indexPathForStartDatePicker: NSIndexPath {
        return NSIndexPath(forRow: 1, inSection: 0)
    }
    var indexPathForEndDateLabel: NSIndexPath {
        return NSIndexPath(forRow: 2, inSection: 0)
    }
    var indexPathForEndDatePicker: NSIndexPath {
        return NSIndexPath(forRow: 3, inSection: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set datePicker dates
        startDatePicker.date = dateRange.startDate
        endDatePicker.date = dateRange.endDate
        
        // Update labels
        updateDateLabelFromDatePicker(startDatePicker)
        updateDateLabelFromDatePicker(endDatePicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Convenience functions
    
    func updateDateLabelFromDatePicker(datePicker: UIDatePicker) {
        let targetLabel: UILabel
        switch datePicker {
        case startDatePicker:
            targetLabel = startDateLabel
            
            // Check if endDatePicker will change its date based on minimum date
            let shouldUpdateEndDateLabel = endDatePicker.date < startDatePicker.date
            endDatePicker.minimumDate = startDatePicker.date // Set minimum date to start date
            
            if shouldUpdateEndDateLabel {
                updateDateLabelFromDatePicker(endDatePicker)
                endDatePicker.date = startDatePicker.date.endOf(.Day) // Make sure that date is end of day
            }
        case endDatePicker, _: // Case endDatePicker or any
            targetLabel = endDateLabel
        }
        
        targetLabel.text = datePicker.date.toStringWithDateStyle(.MediumStyle, andTimeStyle: nil)
    }
    
    // MARK: Actions
    
    @IBAction func didPressCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        dateRange.startDate = startDatePicker.date
        dateRange.endDate = endDatePicker.date
        
        delegate?.rangeViewControllerDidFinish(self)
        print("Range: \(dateRange.endDate)")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didChangeValueDatePicker(sender: UIDatePicker) {
        updateDateLabelFromDatePicker(sender)
    }
}

// MARK: - Table view data source
extension RangeViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPathForStartDatePicker || indexPath == indexPathForEndDatePicker {
            let editing = indexPath == indexPathForStartDatePicker ? editingStartDate : editingEndDate
            if editing {
                var height: CGFloat = 217
                if traitCollection.verticalSizeClass == .Compact {
                    height -= 54
                }
                return height
            } else {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}

// MARK: - Table view delegate
extension RangeViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == indexPathForStartDateLabel {
            editingStartDate = !editingStartDate
            if editingStartDate {
                editingEndDate = false
            }
            
            // For animation of reload data
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        } else if indexPath == indexPathForEndDateLabel {
            editingEndDate = !editingEndDate
            if editingEndDate {
                editingStartDate = false
            }
            
            // For animation of reload data
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
}

protocol RangeViewControllerDelegate: class {
    func rangeViewControllerDidFinish(controller: RangeViewController)
}