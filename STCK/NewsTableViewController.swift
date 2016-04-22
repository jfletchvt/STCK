//
//  NewsTableViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 12/9/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    /*
    --------------------------------------------------------
    MARK: - News Information
    --------------------------------------------------------
    */
    
    let listOfNews = ["Bloomberg", "CNBC", "MarketWatch", "Seeking Alpha", "Yahoo Finance"]
    let listOfImages = ["bloomberg.png", "cnbc.png", "marketwatch.png", "seekingalpha.png", "yahoofinance.png"]
    
    var nameToURL = ["Bloomberg": "http://www.bloomberg.com", "CNBC": "http://www.cnbc.com", "MarketWatch": "http://www.marketwatch.com", "Seeking Alpha": "http://seekingalpha.com/news/all", "Yahoo Finance": "http://finance.yahoo.com"]
    
    var keyToSend = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 100.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return listOfNews.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:NewsTableViewCell = tableView.dequeueReusableCellWithIdentifier("newsCell") as! NewsTableViewCell
        
        let image = UIImage(named: listOfImages[indexPath.row])
        
        cell.newsImage.image = image
        
        cell.newsImage?.contentMode = .ScaleAspectFit
        
        
        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        keyToSend = listOfNews[indexPath.row]
        
        performSegueWithIdentifier("showNewsWebsite", sender: self)
    }
    
    /*
    -------------------------
    MARK: - Prepare For Segue
    -------------------------
    */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "showNewsWebsite" {
            
            // Obtain the object reference of the destination view controller
            let newsWebViewController: NewsWebViewController = segue.destinationViewController as! NewsWebViewController
            
            //Pass the data object to the destination view controller object
            newsWebViewController.name = keyToSend
            newsWebViewController.urlLink = nameToURL[keyToSend]!
            
        }

    }
    

}
