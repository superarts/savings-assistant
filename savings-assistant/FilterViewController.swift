//
//  FilterViewController.swift
//  savings-assistant
//
//  Created by Chris Amanse on 8/2/15.
//  Copyright (c) 2015 Joe Christopher Paul Amanse. All rights reserved.
//

import UIKit
import RealmSwift

class FilterViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    var dateRange: DateRange = DateRange(startDate: NSDate().startOf(.Day), endDate: NSDate().endOf(.Day)) {
        didSet {
            updateFilter()
        }
    }
    
    weak var account: Account?
    
    private var _filteredTransactions: Results<Transaction>?
    var filteredTransactions: Results<Transaction> {
        if _filteredTransactions == nil {
            _filteredTransactions = Realm().objects(Transaction).filter("account = %@", account ?? nil as COpaquePointer).filter(transactionsPredicate).sorted("date", ascending: false)
        }
        return _filteredTransactions!
    }
    
    var transactionsPredicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE") {
        didSet {
            _filteredTransactions = nil
            
            configureView()
            tableView.reloadData()
        }
    }
    var realmNotificationToken: NotificationToken?
    
    var adjustedTableViewOffset = false
    
    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        // Load cell nib
        let expenseNib = UINib(nibName: "ExpenseTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(expenseNib, forCellReuseIdentifier: "ExpenseCell")
        
        // Self-sizing cell
        tableView.estimatedRowHeight = ExpenseTableViewCell.estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData() // Bug on some versions of iOS, cells don't size correctly the first time
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateInsetsAndOffsets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reconfigure view and reload data on appear
        configureView()
        tableView.reloadData()
        
        // Add realm notification
        print("Filter: Adding realm notification")
        realmNotificationToken = Realm().addNotificationBlock({ (notification, realm) -> Void in
            println("Filter: RealmNotification received")
            
            // Reset filtered transactions
            self._filteredTransactions = nil
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            
            // Reconfigure view
            self.configureView()
        })
        
        dateRange = DateRange(startDate: self.dateRange.startDate, endDate: self.dateRange.endDate)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear realm notification
        print("Filter: Removing realm notification")
        if let notificationToken = realmNotificationToken {
            Realm().removeNotification(notificationToken)
        }
        realmNotificationToken = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Convenience functions
    
    func configureView() {
        // Configure view for filtered transactions
        
        if isViewLoaded() {
            let totalAmount: Double = filteredTransactions.sum("amount")
            let totalEarnings: Double = filteredTransactions.filter("amount > 0").sum("amount")
            let totalExpenses: Double = filteredTransactions.filter("amount < 0").sum("amount")
            
            totalAmountLabel.text = numberFormatter.stringFromNumber(NSNumber(double: totalAmount))
            earningsLabel.text = numberFormatter.stringFromNumber(NSNumber(double: totalEarnings))
            expensesLabel.text = numberFormatter.stringFromNumber(NSNumber(double: totalExpenses))
            
            // Date range label
            updateDateRangeLabel()
        }
    }
    
    func updateInsetsAndOffsets() {
        let headerViewHeight = headerView.frame.height
        let insets = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = insets
        tableView.contentInset = insets
        
        // Adjust offset once only (initial load)
        if !adjustedTableViewOffset {
            tableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
            adjustedTableViewOffset = true
        }
    }
    
    func updateDateRangeLabel() {
        let startDateString = dateRange.startDate.toStringWithDateStyle(.MediumStyle, andTimeStyle: nil)
        let endDateString = dateRange.endDate.toStringWithDateStyle(.MediumStyle, andTimeStyle: nil)
        
        dateRangeLabel.text = "\(startDateString) - \(endDateString)"
    }
    
    func updateFilter() {
        // Set predicate
        transactionsPredicate = NSPredicate(format: "date => %@ && date <= %@", dateRange.startDate, dateRange.endDate)
        
        // Update label
        updateDateRangeLabel()
    }
    
    // MARK: Actions
    
    @IBAction func didPressRange(sender: AnyObject) {
        performSegueWithIdentifier("showRange", sender: sender)
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTransaction" {
            if let destinationVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? UpdateTransactionViewController {
                destinationVC.account = account
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.transaction = filteredTransactions[indexPath.row]
                }
            }
        } else if segue.identifier == "showRange" {
            if let destinationVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? RangeViewController {
                destinationVC.delegate = self
                destinationVC.dateRange = dateRange
            }
        }
    }
}

// MARK: - Table view data source
extension FilterViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExpenseCell") as! ExpenseTableViewCell
        
        let currentTransaction = filteredTransactions[indexPath.row]
        
        cell.expenseTitleLabel.text = currentTransaction.name
        cell.amountLabel.text = numberFormatter.stringFromNumber(NSNumber(double: currentTransaction.amount))
        cell.dateLabel.text = currentTransaction.date.toStringWithDateStyle(.MediumStyle, andTimeStyle: .ShortStyle)
        
        cell.updateAmountLabelTextColorForAmount(currentTransaction.amount)
        
        return cell
    }
    
    // Editing style
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let transaction = filteredTransactions[indexPath.row]
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
extension FilterViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showTransaction", sender: nil)
    }
}

// MARK: - Range view controller delegate
extension FilterViewController: RangeViewControllerDelegate {
    func rangeViewControllerDidFinish(controller: RangeViewController) {
        dateRange = DateRange(startDate: controller.dateRange.startDate.startOf(.Day), endDate: controller.dateRange.endDate.endOf(.Day))
        print("Filter: \(dateRange.endDate)")
    }
}