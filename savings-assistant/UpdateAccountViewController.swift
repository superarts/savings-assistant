//
//  UpdateAccountViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/31/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import RealmSwift

// TODO: Update account

enum AccountInvalidState {
    case NameIsBlank
}

class UpdateAccountViewController: UITableViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesPlaceholder: UITextField!
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    var editingMode: Bool {
        return account != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  Convenience functions
    
    func configureView() {
        // Configure view for current Account
        
        if isViewLoaded() {
            titleTextField.text = account?.name ?? ""
            notesTextView.text = account?.notes ?? ""
            
            notesPlaceholder.hidden = notesTextView.text.characters.count > 0
            
            if editingMode {
                navigationItem.title = "Edit Account"
                
                // Change Done button to a Save button while retaining target and action - on edit
                if let rightBarButtonItem = navigationItem.rightBarButtonItem {
                    let oldTarget: AnyObject? = rightBarButtonItem.target
                    let oldAction = rightBarButtonItem.action
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: oldTarget, action: oldAction)
                }
            }
        }
    }
    
    func isValidAccountName(name: String) -> Bool {
        // TODO: Validate account name
        var invalidState: AccountInvalidState?
        if name.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil).characters.count == 0 {
            invalidState = .NameIsBlank
        }
        
        // If invalidState was set, then account is invalid
        if let state = invalidState {
            presentAlertForAccountInvalidState(state)
            return false
        }
        
        return true
    }
    
    func presentAlertForAccountInvalidState(state: AccountInvalidState) {
        // Set message depending on invalid state
        let message: String
        
        switch state {
        case .NameIsBlank:
            message = "Account name should not be blank."
        }
        
        let controller = UIAlertController(title: "Invalid Account", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        
        controller.addAction(okayAction)
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func didPressDone(sender: AnyObject) {
        let accountName = titleTextField.text
        let notes = notesTextView.text
        
        if isValidAccountName(accountName!) {
            // Account name should be valid at this point
            
            let updateAccount = Account()
            
            // Use old id when editing to update only account instead of adding a new one
            if editingMode {
                updateAccount.id = account!.id
            }
            
            updateAccount.name = accountName!
            
            // Validate notes (don't save if empty or all space)
            if notes.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil).characters.count > 0 {
                // Add notes
                updateAccount.notes = notes
            }
            
            // Save account
			do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(updateAccount, update: true)
                })
        	} catch let error as NSError {
        		print("WARNING \(error)")
        	}
            
            // After saving, dismiss
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UpdateAccountViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        notesPlaceholder.hidden = textView.text.characters.count > 0
    }
}
