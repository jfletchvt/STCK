//
//  DraggableViewBackground.swift
//  STCK
//
//  Created by Joe Fletcher on 11/29/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

/*
--------------------------------------------------------
MARK: - DraggableViewBackground: What creates the cards
--------------------------------------------------------
*/

class DraggableViewBackground: UIView, DraggableViewDelegate {
    
    // Reference to plist dictionary (favorites)
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    // Sound IDs
    var rightSoundID:SystemSoundID = 0
    var leftSoundID:SystemSoundID = 1
    
    // Card UI Constraints
    let MAX_BUFFER_SIZE = 2;
    let CARD_HEIGHT = CGFloat(450.0);
    let CARD_WIDTH = CGFloat(300.0);
    
    // Local dictionaries
    var csvDicKeyToName = [String:String]()
    var csvDicKeyToIndustry = [String:String]()
    
    // Card lists and constraints
    var exampleCardLabels = [String]()
    var loadedCards = NSMutableArray()
    var allCards =  NSMutableArray()
    var cardsLoadedIndex = 0
    var numLoadedCardsCap = 0
    
    // Singleton copy
    var singleton = Singleton.sharedInstance
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    --------------------------------------------------------
    MARK: - DraggableViewBackground Init
    --------------------------------------------------------
    */
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        super.layoutSubviews()
        
        
        
        setSoundUp()
        parseCSV()
        
        setBackgroundColor()
        setLoadedCardsCap()
        
        createCards()
        displayCards()
    }

    /*
    --------------------------------------------------------
    MARK: - DraggableViewBackground: Set Up of View
    --------------------------------------------------------
    */
    func setBackgroundColor() {
        self.backgroundColor = UIColor(white: 1, alpha: 0)
//        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1);
    }
    
    func setSoundUp() {
        var soundFilePath: NSURL? = NSBundle.mainBundle().URLForResource("cashSound", withExtension: "mp3")
        var soundFileURLRef = soundFilePath! as CFURL
        AudioServicesCreateSystemSoundID(soundFileURLRef, &rightSoundID)
        
        soundFilePath = NSBundle.mainBundle().URLForResource("buzzerSound", withExtension: "mp3")
        soundFileURLRef = soundFilePath! as CFURL
        AudioServicesCreateSystemSoundID(soundFileURLRef, &leftSoundID)
        
//        let title = UILabel()
//        
//        title.text = "S&P 500 Stocks"
//        title.center = CGPoint(x: (self.frame.size.width / 3) , y: self.frame.size.height / 10)
//        title.sizeToFit()
//        title.textAlignment = NSTextAlignment.Center
//        self.addSubview(title)
    }

    /*
    --------------------------------------------------------
    MARK: - Cards Stack Capacity
    --------------------------------------------------------
    */
    func setLoadedCardsCap() {
        numLoadedCardsCap = 0;
        if (exampleCardLabels.count > MAX_BUFFER_SIZE) {
            numLoadedCardsCap = MAX_BUFFER_SIZE
        } else {
            numLoadedCardsCap = exampleCardLabels.count
        }
        
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
            
            let lines = content?.componentsSeparatedByString("\n")
            
            var randomStocks = [String]()
            
            var set = Set<Int>() // the indecies of stocks from csv
            
            for _ in 1...20 {
                
                var random = Int(arc4random_uniform(494) + 1)
                
                
                //if the same index is generated or an index mapping to a value of an already favorites stock GENERATE NEW ONE
                while(set.contains(random) || singleton.keys.contains(lines![random])) {
                    random = Int(arc4random_uniform(494) + 1)
                }
                
                set.insert(random)
                
                randomStocks.append(lines![random])
            }
        
            var symbols = [String]()
            
            for line in randomStocks {
                
                var words = line.componentsSeparatedByString(",")
                
                symbols.append(words[0])
                
                csvDicKeyToName[words[0]] = words[1]
                csvDicKeyToIndustry[words[0]] = words[2]
            }
            
            exampleCardLabels = symbols
            
            exampleCardLabels = shuffleArray(exampleCardLabels)
        }
    }
    
    /*
    --------------------------------------------------------
    MARK: - Create Stock Cards
    --------------------------------------------------------
    */
    
    func createCards() {
        if (numLoadedCardsCap > 0) {
            let cardFrame = CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)
            
            for cardLabel in exampleCardLabels {
                
                let stockName = "(\"" + cardLabel + "\")"
                
                let results = YQL.query(stockName)
                
                let queryResults = results?.valueForKeyPath("query.results")
                if queryResults != nil {
                    
                    let stockInfo = queryResults!["quote"] as! NSDictionary
                    
                    let newCard = DraggableView(frame: cardFrame, dictionary: stockInfo, name: cardLabel, csvDicKeyToName: csvDicKeyToName, csvDicKeyToIndustry: csvDicKeyToIndustry)
                    
                    newCard.delegate = self;
                    allCards.addObject(newCard)
                }
            }
        }
    }
    
    /*
    --------------------------------------------------------
    MARK: - Stock Card Attribute Functions
    --------------------------------------------------------
    */

    func displayCards() {
        for(var i = 0; i < numLoadedCardsCap; i += 1) {
            loadACardAt(i)
        }
    }
    
    func cardSwipedLeft(card: DraggableView) {
        
        // Play sound
        AudioServicesPlaySystemSound(leftSoundID)
        
        processCardSwipe()
    }
    
    func cardSwipedRight(card: DraggableView) {
        
        // Play sound
        AudioServicesPlaySystemSound(rightSoundID)
        
        
        // Add to singleton and plist to keep track of favorites list (watchlist)
        
        applicationDelegate.watchListSymbols.setObject(card.stockName.text!, forKey: card.stockSymbol.text!)
        singleton.symbols = applicationDelegate.watchListSymbols
        singleton.keys = singleton.symbols.allKeys as! [String]
        
        
        processCardSwipe()
    }

    
    func processCardSwipe() {
        loadedCards.removeObjectAtIndex(0)
        
        if (moreCardsToLoad()) {
            loadNextCard()
        }
    
        // Load more cards
        
        else {
            
            //TO DO: need to add loading image here because it takes a few seconds to load
            
            parseCSV()
            
            setBackgroundColor()
            setLoadedCardsCap()
            
            createCards()
            displayCards()
            
            loadNextCard()
        }
    }
    
    func moreCardsToLoad() -> Bool {
        return cardsLoadedIndex < allCards.count;
    }
    
    func loadNextCard() {
        loadACardAt(cardsLoadedIndex)
    }
    
    func loadACardAt(index: Int) {
        loadedCards.addObject(allCards[index])
        if (loadedCards.count > 1) {
            insertSubview(loadedCards[loadedCards.count-1] as! DraggableView, belowSubview: loadedCards[loadedCards.count-2] as! DraggableView)
            // is there a way to define the array with UIView elements so I don't have to cast?
        } else {
            addSubview(loadedCards[0] as! DraggableView)
        }
        cardsLoadedIndex += 1;
    }
    
    /*
    --------------------------------------------------------
    MARK: - Shuffle Array
    --------------------------------------------------------
    */
    
    func shuffleArray<T>( var array: Array<T>) -> Array<T>
    {
        for var index = array.count - 1; index > 0; index -= 1
        {
            // Random int from 0 to index-1
            let j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&array[index], &array[j])
        }
        return array
    }
}

