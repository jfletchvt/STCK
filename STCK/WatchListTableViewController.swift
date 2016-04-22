//
//  WatchListTableViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 12/5/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class WatchListTableViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var singleton = Singleton.sharedInstance
    
    var list = [String]()
    
    var symbolToSend = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        symbolToSend = ""

        list = singleton.keys
        
        list.sortInPlace() {$0 < $1}
        
    }

    override func viewWillAppear(animated: Bool) {
        
        list = singleton.keys
        
        list.sortInPlace() {$0 < $1}
        
        table.reloadData()
    }
    
    /*
    --------------------------------------------------------
    MARK: - Shake Motion to Clear WatchList
    --------------------------------------------------------
    */
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if event!.subtype == UIEventSubtype.MotionShake {
            
            let prompt = UIAlertController(title: "Clear Watchlist?", message: "Are you sure you want to clear all stocks?", preferredStyle: UIAlertControllerStyle.Alert)
            prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            prompt.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                    self.singleton.keys.removeAll()
                    self.applicationDelegate.watchListSymbols.removeAllObjects()
                    self.list.removeAll()
                    self.table.reloadData()
                
                }))
            presentViewController(prompt, animated: true, completion: nil)
        }
    }
    
    /*
    --------------------------------------------------------
    MARK: - Add Stock to WatchList
    --------------------------------------------------------
    */
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Add Stock", message: "You have selected to add a new stock ticker to your watchlist. i.e: AAPL", preferredStyle: UIAlertControllerStyle.Alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            
            var stockNameCaps = (inputTextField?.text)!.uppercaseString
            stockNameCaps = stockNameCaps.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            let trimmedString = stockNameCaps.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            let stockName = "(\"" + trimmedString + "\")"
            
            let results = YQL.query(stockName)
            
            let queryResults = results?.valueForKeyPath("query.results")
            
            
            if queryResults != nil {
            
                let stockInfo = queryResults!["quote"] as! NSDictionary
                
                if let name = stockInfo["Name"] as? String {
                
                    self.applicationDelegate.watchListSymbols.setObject(name, forKey: trimmedString)
                    
                    self.singleton.symbols = self.applicationDelegate.watchListSymbols
                    
                    self.singleton.keys = self.singleton.symbols.allKeys as! [String]
                    
                    self.list = self.singleton.keys
                    
                    self.list.sortInPlace() {$0 < $1}
                    
                    self.table.reloadData()
                }
                
                else {
                    
                    let badInput = UIAlertController(title: "Add Stock Failed", message: "$\(trimmedString) is an invalid stock symbol so it was not added.", preferredStyle: UIAlertControllerStyle.Alert)
                    badInput.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(badInput, animated: true, completion: nil)
                
                }

            }
            else {
                
                let badInput = UIAlertController(title: "Add Stock Failed", message: "$\(trimmedString) is an invalid stock symbol so it was not added.", preferredStyle: UIAlertControllerStyle.Alert)
                badInput.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(badInput, animated: true, completion: nil)
            }
            
        }))
        passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Stock Symbol"
            inputTextField = textField
        })
        
        presentViewController(passwordPrompt, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StockCell", forIndexPath: indexPath)

        let rowNumber: Int = indexPath.row    // Identify the row number
        
        let name = singleton.symbols[list[rowNumber]] as! String
        
        cell.textLabel!.text = list[rowNumber]
        cell.detailTextLabel!.text = name

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        
        symbolToSend = list[rowNumber]
        
        
        performSegueWithIdentifier("showYahooFinance", sender: self)
        
    }
    
    //-------------------------------
    // Allow Editing of Rows (Cities)
    //-------------------------------
    
    // We allow each row (city) of the table view to be editable, i.e., deletable or movable
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    //---------------------
    // Delete Button Tapped
    //---------------------
    
    // This is the method invoked when the user taps the Delete button in the Edit mode
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {   // Handle the Delete action
            
            let symbol = list[indexPath.row]
            
            print("Deleting: " + symbol)
            
            applicationDelegate.watchListSymbols.removeObjectForKey(symbol)
            singleton.symbols.removeObjectForKey(symbol)
            singleton.keys = singleton.symbols.allKeys as! [String]
            
            list = singleton.keys
            list.sortInPlace() {$0 < $1}
            
            // Reload the rows and sections of the Table View countryCityTableView
            table.reloadData()
        }
    }

    
    // Informs the table view delegate that the user tapped the Detail Disclosure button
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
    
        
        symbolToSend = list[rowNumber]
        
        
        performSegueWithIdentifier("showTwitterFeed", sender: self)
    }
    
    /*
    -------------------------
    MARK: - Prepare For Segue
    -------------------------
    */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "showYahooFinance" {
            
            // Obtain the object reference of the destination view controller
            let yahooFinanceWebViewController: YahooFinanceWebViewController = segue.destinationViewController as! YahooFinanceWebViewController
            
            //Pass the data object to the destination view controller object
            yahooFinanceWebViewController.stockSymbol = symbolToSend
            
        }
        
        else if segue.identifier == "showTwitterFeed" {
            
            // Obtain the object reference of the destination view controller
            let twitterFeedWebViewController: TwitterFeedWebViewController = segue.destinationViewController as! TwitterFeedWebViewController
            
            //Pass the data object to the destination view controller object
            twitterFeedWebViewController.stockSymbol = symbolToSend
            
        }
    }
    

}
