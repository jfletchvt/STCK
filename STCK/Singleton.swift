//
//  Singleton.swift
//  STCK
//
//  Created by Joe Fletcher on 12/5/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import Foundation

/*
----------------------------------------
MARK: - Singleton Used for favorite list
----------------------------------------
*/

class Singleton {
    
    static let sharedInstance = Singleton()
    
    //the symbols of the stocks being watched ie AAPL
    var keys = [String]()
    //dictionary mapping stock symbols to company names ie: AAPL:Apple Inc
    var symbols = NSMutableDictionary()
    
    init() {
        
    }
    
}