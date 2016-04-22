//
//  AppDelegate.swift
//  STCK
//
//  Created by Joe Fletcher on 11/29/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    /*
    Since .writeToFile function is not yet provided for the Swift dictionary we continue to use NSMutableDictionary.
    Create and initialize an NSMutableDictionary.
    */
    var watchListSymbols: NSMutableDictionary = NSMutableDictionary()
    
    
    /*
    ---------------------------
    MARK: - Read the Dictionary
    ---------------------------
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        /*
        All application-specific and user data must be written to files that reside in the iOS device's
        Documents directory. Nothing can be written into application's main bundle (project folder) because
        it is locked for writing after your app is published.
        
        The contents of the iOS device's Documents directory are backed up by iTunes during backup of an iOS device.
        Therefore, the user can recover the data written by your app from an earlier device backup.
        
        The Documents directory path on an iOS device is different from the one used for iOS Simulator.
        
        To obtain the Documents directory path, you use the NSSearchPathForDirectoriesInDomains function.
        However, this function was created originally for Mac OS X, where multiple such directories could exist.
        Therefore, it returns an array of paths rather than a single path.
        
        For iOS, the resulting array's first element (index=0) contains the path to the Documents directory.
        */
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/WatchListSymbols.plist"
        
        
        /*
        NSMutableDictionary manages an *unordered* collection of mutable (changeable) key-value pairs.
        Instantiate an NSMutableDictionary object and initialize it with the contents of the CountryCities.plist file.
        */
        let dictionaryFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInDocumentDirectory)
        
        
        /*
        IF the optional variable dictionaryFromFile has a value, THEN
        CountryCities.plist exists in the Documents directory and the dictionary is successfully created
        ELSE read CountryCities.plist from the application's main bundle.
        */
        if let dictionaryFromFileInDocumentDirectory = dictionaryFromFile {
            
            // CountryCities.plist exists in the Documents directory
            watchListSymbols = dictionaryFromFileInDocumentDirectory
            
        } else {
            
            // CountryCities.plist does not exist in the Documents directory; Read it from the main bundle.
            
            // Obtain the file path to the plist file in the mainBundle (project folder)
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("WatchListSymbols", ofType: "plist")
            
            // Instantiate an NSMutableDictionary object and initialize it with the contents of the CountryCities.plist file.
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            // Assign it to the instance variable
            watchListSymbols = dictionaryFromFileInMainBundle!
        }
        
        
        return true
    }
    
    /*
    ----------------------------
    MARK: - Write the Dictionary
    ----------------------------
    */
    func applicationWillResignActive(application: UIApplication) {
        /*
        "UIApplicationWillResignActiveNotification is posted when the app is no longer active and loses focus.
        An app is active when it is receiving events. An active app can be said to have focus.
        It gains focus after being launched, loses focus when an overlay window pops up or when the device is
        locked, and gains focus when the device is unlocked." [Apple]
        */
        
        print("WRITE TO PLIST")
        
        // Define the file path to the CountryCities.plist file in the Documents directory
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/WatchListSymbols.plist"
        
        
        // Write the NSMutableDictionary to the CountryCities.plist file in the Documents directory
        watchListSymbols.writeToFile(plistFilePathInDocumentDirectory, atomically: true)
        
        
        /*
        The flag "atomically" specifies whether the file should be written atomically or not.
        
        If flag is TRUE, the dictionary is first written to an auxiliary file, and
        then the auxiliary file is renamed to path plistFilePathInDocumentDirectory.
        
        If flag is FALSE, the dictionary is written directly to path plistFilePathInDocumentDirectory.
        This is a bad idea since the file can be corrupted if the system crashes during writing.
        
        The TRUE option guarantees that the file will not be corrupted even if the system crashes during writing.
        */
    }
}

