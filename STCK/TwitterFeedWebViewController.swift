//
//  TwitterFeedWebViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 12/6/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class TwitterFeedWebViewController: UIViewController {

    /*
    Store the object reference of the UIWebView object, created in the
    Storyboard (Interface Builder), into instance variable webView.
    */
    @IBOutlet var webView: UIWebView!
    
    // The URL of the web page to be displayed. Initial value is empty.
    // It will be set by the previous view controller just before this view is shown.
    var stockSymbol: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = stockSymbol
        
        let youTubeURL = "http://stocktwits.com/symbol/\(stockSymbol)?q=\(stockSymbol)" //"https://twitter.com/search?q=%23\(stockSymbol)%20stock&src=typd"
        /*
        Convert the websiteURL set by the previous view controller into an NSURL object and
        store its object reference into the local variable url. An NSURL object represents a URL.
        */
        let url = NSURL(string: youTubeURL)
        
        /*
        Convert the NSURL object into an NSURLRequest object and store its object
        reference into the local variable request. An NSURLRequest object represents
        a URL load request in a manner independent of protocol and URL scheme.
        */
        let request = NSURLRequest(URL: url!)
        
        // Ask the webView object to display the web page for the given websiteURL
        webView.loadRequest(request)
    }
    
    /******************************************************************************************
     * UIWebView Delegate Methods: These methods must be implemented whenever UIWebView is used.
     ******************************************************************************************/
    
    func webViewDidStartLoad(webView: UIWebView) {
        // Starting to load the web page. Show the animated activity indicator in the status bar
        // to indicate to the user that the UIWebVIew object is busy loading the web page.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // Finished loading the web page. Hide the activity indicator in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        /*
        Ignore this error if the page is instantly redirected via javascript or in another way.
        NSURLErrorCancelled is returned when an asynchronous load is cancelled, which happens
        when the page is instantly redirected via javascript or in another way.
        */
        if error!.code == NSURLErrorCancelled {
            return
        }
        
        // An error occurred during the web page load. Hide the activity indicator in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Create the error message in HTML as a character string and store it into the local constant errorString
        let errorString = "<html><font size=+2 color='red'><p>An error occurred: <br />Possible causes for this error:<br />- No network connection<br />- Wrong URL entered<br />- Server computer is down</p></font></html>" + error!.localizedDescription
        
        // Display the error message within the UIWebView object
        // self. is required here since this method has a parameter with the same name.
        self.webView.loadHTMLString(errorString, baseURL: nil)
    }
    
}
