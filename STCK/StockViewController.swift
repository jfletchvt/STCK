//
//  StockViewController.swift
//  STCK
//
//  Created by Joe Fletcher on 11/29/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

class StockViewController: UIViewController {

    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /*
    --------------------------------------------------------
    MARK: - "Main" for the first tab
    --------------------------------------------------------
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let singleton = Singleton.sharedInstance
        
        singleton.symbols =  applicationDelegate.watchListSymbols
        
        singleton.keys = applicationDelegate.watchListSymbols.allKeys as! [String]
        
        let draggableViewBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableViewBackground);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

