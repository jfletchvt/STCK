//
//  YQL.swift
//  STCK
//
//  Created by Joe Fletcher on 11/29/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import Foundation

/*
--------------------------------------------------------
MARK: - Yahoo Query Language API Wrapper Layer
--------------------------------------------------------
*/

struct YQL {
    
    // Yahoo finance query string
    private static let prefix:NSString = "http://query.yahooapis.com/v1/public/yql?&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=&q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20"
    
    static func query(statement:String) -> NSDictionary? {

        // update query to contain symbol of stock to search on
        let escapedStatement = statement.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let query = "\(prefix)\(escapedStatement!)"
    
        var results:NSDictionary? = nil
        var jsonError:NSError? = nil
        var jsonDataError:NSError? = nil

        let jsonData: NSData?
        do {
            jsonData = try NSData(contentsOfURL: NSURL(string: query)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError {
            jsonError = error
            jsonData = nil
        }

        if jsonData != nil {
            
            do {
            results = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            }
            catch let error as NSError {
                results = nil
                jsonDataError = error
            }
        }
        if jsonError != nil || jsonDataError != nil{
            NSLog( "ERROR while fetching/deserializing YQL data. Message \(jsonError!)" )
        }
        return results
    }
}