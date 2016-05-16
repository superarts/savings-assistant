//
//  UpdateTransactionViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/31/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import RealmSwift

class UpdateTransactionViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesPlaceholder: UITextField!
    @IBOutlet weak var expenseEarningSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var account: Account?
    
    var transaction: Transaction? {
        didSet {
            configureView()
        }
    }
    var editingMode: Bool {
        return transaction != nil
    }
    
    // For date picker
    var editingDate = false
    var indexPathForDateLabel: NSIndexPath {
        return NSIndexPath(forRow: 3, inSection: 0)
    }
    var indexPathForDatePicker: NSIndexPath {
        return NSIndexPath(forRow: 4, inSection: 0)
    }
    
    // For input validation - stored in memory to prevent creating valid character set every check
    lazy var validCharacterSet: NSCharacterSet = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        let validCharacterSet = NSMutableCharacterSet.decimalDigitCharacterSet()
        validCharacterSet.formUnionWithCharacterSet(NSCharacterSet(charactersInString: "\(decimalSeparator)"))
        
        return validCharacterSet
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Convenience functions
    
    func configureView() {
        // Configure view for current transaction. If transaction is nil, resort to default values
        if isViewLoaded() {
            nameTextField.text = transaction?.name ?? ""
            notesTextView.text = transaction?.notes ?? ""
            expenseEarningSegmentedControl.selectedSegmentIndex = (transaction?.amount ?? 0) > 0 ? 1 : 0
            datePicker.date = transaction?.date ?? NSDate().startOf(.Minute)
            
            // Amount text field is blank when amount is 0
            let amount = transaction?.amount ?? 0
            if amount != 0 {
                amountTextField.text = "\(abs(amount))"
            }
            
            // Update date time labels
            updateDateTimeLabel()
            
            // Show notes placeholder when there are no notes
            notesPlaceholder.hidden = notesTextView.text.characters.count > 0
            
            if editingMode {
                navigationItem.title = "Edit Transaction"
                
                // Change Done button to a Save button while retaining target and action - on edit
                if let rightBarButtonItem = navigationItem.rightBarButtonItem {
                    let oldTarget: AnyObject? = rightBarButtonItem.target
                    let oldAction = rightBarButtonItem.action
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: oldTarget, action: oldAction)
                }
            }
        }
        
    }
    
    func updateDateTimeLabel() {
        let date = datePicker.date
        dateLabel.text = date.toStringWithDateStyle(.MediumStyle, andTimeStyle: nil)
        timeLabel.text = date.toStringWithDateStyle(nil, andTimeStyle: .ShortStyle)
    }
    
    // MARK: Actions
    
    @IBAction func didPressDone(sender: AnyObject) {
        // If expense or earning
        let expense = expenseEarningSegmentedControl.selectedSegmentIndex == 0
        
        // Get expense name
        var expenseName = nameTextField.text
        // If blank, replace with default name
        if expenseName?.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil).characters.count == 0 {
            if expense {
                expenseName = "Expense"
            } else {
                expenseName = "Earning"
            }
        }
        
        // Get amount
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        var amount = (formatter.numberFromString(amountTextField!.text!) ?? NSNumber(double: 0)).doubleValue
        
        // If not 0 and expense, set to negative
        if amount != 0 && expense {
            amount *= -1
        }
        
        // Get notes and clear notes if if all spaces
        var notes = notesTextView.text
        if notes.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil).characters.count == 0 {
            notes = ""
        }
        
        // Create/edit transaction
        let updateTransaction = Transaction()
        
        if editingMode {
            updateTransaction.id = transaction!.id
        }
        
        updateTransaction.account = self.account
        updateTransaction.name = expenseName!
        updateTransaction.amount = amount
        updateTransaction.notes = notes
        updateTransaction.date = self.datePicker.date
        
        // Save transaction
		do {
            let realm = try Realm()
            try realm.write { () -> Void in
                realm.add(updateTransaction, update: true)
            }
		} catch let error as NSError {
			print("WARNING \(error)")
		}
		
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didChangeValueDatePicker(sender: UIDatePicker) {
        updateDateTimeLabel()
    }
}

// MARK: - Table view data source
extension UpdateTransactionViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPathForDatePicker {
            if editingDate {
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
extension UpdateTransactionViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == indexPathForDateLabel {
            editingDate = !editingDate
            
            // For animation of reload data
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
}

// MARK: - Text field delegate
extension UpdateTransactionViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            if string.rangeOfCharacterFromSet(validCharacterSet.invertedSet, options: [], range: nil) != nil {
                return false
            }
            return true
        }
        
        return true
    }
}

// MARK: - Text view delegate
extension UpdateTransactionViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        notesPlaceholder.hidden = textView.text.characters.count > 0
    }
}
