//
//  SpecificIndustryTableViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 12/6/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class SpecificIndustryTableViewController: UITableViewController {

    var industryName = ""
    
    var industrySpecificDictionary = [String:String]() // AAPL:Apple Inc
    
    var keys = [String]()
    
    var symbolToSend = ""
    var nameToSend = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = industryName
        
        parseCSV()
        
        keys.sortInPlace() {$0 < $1}
    }
    
    /*
    --------------------------------------------------------
    MARK: - Parse CSV
    --------------------------------------------------------
    */
    
    func parseCSV() {
        
        let csvPath = NSBundle.mainBundle().pathForResource("constituents", ofType: "csv")
        
        var csvError:NSError? = nil
        var content:String? = nil
        
        do {
            try content = String(contentsOfFile: csvPath!)
        } catch let error as NSError {
            csvError = error
            content = nil
        }
        
        if(csvError != nil) {
            print(csvError)
        }
        else {
            
            var lines = content?.componentsSeparatedByString("\n")
            
            lines?.removeFirst()
            
            for line in lines! {
                
                var words = line.componentsSeparatedByString(",")
                
                if words[2] == industryName {
                    industrySpecificDictionary[words[0]] = words[1]
                    keys.append(words[0])
                }
            }
            
        }
    }
    
    /*
    --------------------------------------------------------
    MARK: - Table view data source
    --------------------------------------------------------
    */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return keys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IndustrySpecificCell", forIndexPath: indexPath)
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        cell.textLabel!.text = keys[rowNumber]
        cell.detailTextLabel!.text = industrySpecificDictionary[keys[rowNumber]]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        
        symbolToSend = keys[rowNumber]
        nameToSend = industrySpecificDictionary[keys[rowNumber]]!
        
        
        performSegueWithIdentifier("showYahooFinanceTwo", sender: self)
        
    }
    
    // Informs the table view delegate that the user tapped the Detail Disclosure button
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        
        symbolToSend = keys[rowNumber]
        nameToSend = industrySpecificDictionary[keys[rowNumber]]!
        
        
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
        
        if segue.identifier == "showYahooFinanceTwo" {
            
            // Obtain the object reference of the destination view controller
            let yahooFinanceWithAddWebViewController: YahooFinanceWithAddWebViewController = segue.destinationViewController as! YahooFinanceWithAddWebViewController
            
            //Pass the data object to the destination view controller object
            yahooFinanceWithAddWebViewController.stockSymbol = symbolToSend
            yahooFinanceWithAddWebViewController.stockName = nameToSend
        }
        
            
        else if segue.identifier == "showTwitterFeed" {
            
            // Obtain the object reference of the destination view controller
            let twitterFeedWebViewController: TwitterFeedWebViewController = segue.destinationViewController as! TwitterFeedWebViewController
            
            //Pass the data object to the destination view controller object
            twitterFeedWebViewController.stockSymbol = symbolToSend
            
        }
    }
    

}
