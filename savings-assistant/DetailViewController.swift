//
//  DetailViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 7/27/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var adjustedTableViewOffset = false
    
    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        
        return formatter
    }()
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    // Used auto-updating Results
    // Stored propert as lazy loaded - since Results is auto-updating
    private var _transactions: Results<Transaction>?
    var transactions: Results<Transaction> {
        if _transactions == nil {
            _transactions = Realm().objects(Transaction).filter("account = %@", account ?? nil as COpaquePointer).sorted("date", ascending: false)
        }
        return _transactions!
    }
    
    // Reserve this block for a later feature - add headers for each day
    // Also find a faster alternative
    /*
    var datesOfDaysOfTransactions: [NSDate] {
        if let sortedTransactions = transactions {
            // Get start of the day of each date of transactions, then filter out duplicates
            var previousDate: NSDate?
            return map(sortedTransactions, { (transaction) -> NSDate in
                return transaction.date.startOf(.Day)
            }).filter { current in
                if let date = previousDate {
                    return date != current
                }
                previousDate = current
                return true
            }
        }
        return []
    }
    */
    
    private var realmNotificationToken: NotificationToken?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reconfigure view and reload data on appear
        configureView()
        tableView.reloadData()
        
        // Add realm notification
        println("Detail: Adding realm notification")
        realmNotificationToken = Realm().addNotificationBlock({ (notification, realm) -> Void in
            println("Detail: RealmNotification received")
            
            // Set account to nil if invalid
            if self.account?.invalidated ?? false {
                self.account = nil
            }
            
            self.tableView.reloadData()
//            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            
            // Reconfigure view
            self.configureView()
        })
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear realm notification
        println("Detail: Removing realm notification")
        if let notificationToken = realmNotificationToken {
            Realm().removeNotification(notificationToken)
        }
        realmNotificationToken = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("didLoad")
        
        configureView()
        
        // Load cell nib
        let expenseNib = UINib(nibName: "ExpenseTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(expenseNib, forCellReuseIdentifier: "ExpenseCell")
        
        // Self-sizing cell
        tableView.estimatedRowHeight = ExpenseTableViewCell.estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData() // Bug on some versions of iOS, cells don't size correctly the first time
        
        // Add Border to filter button
        filterButton.tintColor = Globals.Colors.selectedColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("didLayout")
        
        updateInsetsAndOffsets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Convenience functions
    
    func configureView() {
        // Configure the view. If account is nil, resort to default values
        // Check if view was loaded
        if isViewLoaded() {
            let enabled = account != nil
            addBarButton.enabled = enabled
            detailButton.enabled = enabled
            filterButton.enabled = enabled
            
            // Account name
            titleLabel.text = account?.name ?? "No Account Selected"
            
            // Update amount labels
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            
            // Total
            let totalAmount: Double = transactions.sum("amount")
            let totalEarnings: Double = transactions.filter("amount > 0").sum("amount")
            let totalExpenses: Double = transactions.filter("amount < 0").sum("amount")
            
            totalAmountLabel.text = formatter.stringFromNumber(NSNumber(double: totalAmount))
            // Earnings
            earningsLabel.text = formatter.stringFromNumber(NSNumber(double: totalEarnings))
            // Expenses
            expensesLabel.text = formatter.stringFromNumber(NSNumber(double: totalExpenses))
        }
    }
    
    func updateInsetsAndOffsets() {
        let headerViewHeight = headerView.frame.height
        let insets = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: toolbar.frame.height, right: 0)
        tableView.scrollIndicatorInsets = insets
        tableView.contentInset = insets
        
        // Adjust offset once only (initial load)
        if !adjustedTableViewOffset {
            tableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
            adjustedTableViewOffset = true
        }
    }
    
    // MARK: Actions
    
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTransaction" {
            if let destinationVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? UpdateTransactionViewController {
                destinationVC.account = account
                
                if let indexPath = tableView.indexPathForSelectedRow() {
                    destinationVC.transaction = transactions[indexPath.row]
                }
            }
        } else if segue.identifier == "showAccount" {
            if let destinationVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? UpdateAccountViewController {
                destinationVC.account = account
            }
        } else if segue.identifier == "showFilter" {
            if let destinationVC = segue.destinationViewController as? FilterViewController {
                destinationVC.account = account
            }
        }
    }
}

// MARK: - Table view data source
extension DetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExpenseCell") as! ExpenseTableViewCell
        
        let currentTransaction = transactions[indexPath.row]
        
        cell.expenseTitleLabel.text = currentTransaction.name
        cell.amountLabel.text = numberFormatter.stringFromNumber(NSNumber(double: currentTransaction.amount))
        cell.dateLabel.text = currentTransaction.date.toStringWithDateStyle(.MediumStyle, andTimeStyle: .ShortStyle)
        
        cell.updateAmountLabelTextColorForAmount(currentTransaction.amount)
        
        return cell
    }
    
    // Editing style
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let transaction = transactions[indexPath.row]
            let realm = Realm()
            realm.write({ () -> Void in
                realm.delete(transaction)
            })
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

// MARK: - Table view delegate
extension DetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showTransaction", sender: nil)
    }
}