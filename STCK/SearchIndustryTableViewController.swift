//
//  SearchIndustryTableViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 12/6/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class SearchIndustryTableViewController: UITableViewController {

    var industries = Set<String>()
    var sortedIndustries = [String]()
    
    var industrySelected = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parseCSV()
        
        for industry in industries {
            
            sortedIndustries.append(industry)
        }
        
        sortedIndustries.sortInPlace() {$0 < $1}
        
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
                
                industries.insert(words[2])
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
        return sortedIndustries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IndustryCell", forIndexPath: indexPath)
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        cell.textLabel!.text = sortedIndustries[rowNumber]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNumber: Int = indexPath.row    // Identify the row number
        
        
        industrySelected = sortedIndustries[rowNumber]
        
        
        performSegueWithIdentifier("showSpecificIndustry", sender: self)
        
    }
    

    
    
    /*
    -------------------------
    MARK: - Prepare For Segue
    -------------------------
    */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "showSpecificIndustry" {
            
            // Obtain the object reference of the destination view controller
            let specificIndustryTableViewController: SpecificIndustryTableViewController = segue.destinationViewController as! SpecificIndustryTableViewController
            
            //Pass the data object to the destination view controller object
            specificIndustryTableViewController.industryName = industrySelected
            
        }

    }

}
