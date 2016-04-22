//
//  DraggableView.swift
//  STCK
//
//  Created by Joe Fletcher on 11/29/15.
//  Copyright © 2015 Joe Fletcher. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN = CGFloat(120) //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH = CGFloat(4) //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX = CGFloat(0.93) //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX = CGFloat(1) //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH = CGFloat(320) //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE = CGFloat(M_PI/8) //%%% Higher = stronger rotation angle


/*
--------------------------------------------------------
MARK: - Card Object (Draggable)
--------------------------------------------------------
*/

class DraggableView:UIView{
    var delegate:DraggableViewDelegate?
    
    var xFromCenter = CGFloat()
    var yFromCenter = CGFloat()
    
    var originalPoint = CGPoint()
    
    var stockName = UILabel()
    var stockSymbol = UILabel()
    var lastTradedPrice = UILabel()
    var stockChange = UILabel()
    var stockRangeHigh = UILabel()
    var stockRangeLow = UILabel()
    var stockYearHigh = UILabel()
    var stockYearLow = UILabel()
    var stockIndustry = UILabel()
    
    var graphURL = "http://chart.finance.yahoo.com/z?s="
    
    let imageNameCancel = "Cancel-100.png"
    let imageNameAccept = "Checked-100.png"
    var image = UIImage()
    var imageView = UIImageView()
    
    var csvDicKeyToName = [String:String]()
    var csvDicKeyToIndustry = [String:String]()
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    /*
    --------------------------------------------------------
    MARK: - Set Up Functions
    --------------------------------------------------------
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, dictionary: NSDictionary, name: String, csvDicKeyToName: [String:String], csvDicKeyToIndustry: [String:String]) {
        
        self.init(frame: frame)
        
        self.csvDicKeyToName = csvDicKeyToName
        self.csvDicKeyToIndustry = csvDicKeyToIndustry
        
        
        setupView()
        addGestureRecognizer()
        setMyInformation(dictionary, symbol: name)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.backgroundColor = UIColor.whiteColor()
        
    }
    
    /*
    --------------------------------------------------------
    MARK: - Gesture Functions
    --------------------------------------------------------
    */
    
    func addGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DraggableView.beingDragged(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) {
        xFromCenter = gestureRecognizer.translationInView(self).x;
        yFromCenter = gestureRecognizer.translationInView(self).y;
        
        imageView.removeFromSuperview()
        
        switch (gestureRecognizer.state) {
            
            case .Began:
                self.originalPoint = self.center;
                break;
            
            
            case .Changed:
                //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
                let rotationStrength = min(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
                
                //%%% degree change in radians
                let rotationAngel = (ROTATION_ANGLE * rotationStrength);
                
                //%%% amount the height changes when you move the card up to a certain point
                let scale = max(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
                
                //%%% move the object's center by center + gesture coordinate
                self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
                
                if xFromCenter < 0 {
                    
                    image = UIImage(named: imageNameCancel)!
                    imageView = UIImageView(image: image)
                    
                    imageView.frame = CGRect(x: self.center.x, y: self.center.y - CGFloat(350), width: 100, height: 100)
                    
                    self.addSubview(imageView)
                }
                else {
                    
                    image = UIImage(named: imageNameAccept)!
                    imageView = UIImageView(image: image)
                    
                    imageView.frame = CGRect(x: self.center.x - 150, y: self.center.y - CGFloat(350), width: 100, height: 100)
                    
                    self.addSubview(imageView)
                }
                
                //%%% rotate by certain amount
                let transform = CGAffineTransformMakeRotation(rotationAngel);
                
                //%%% scale by certain amount
                let scaleTransform = CGAffineTransformScale(transform, scale, scale);
                
                //%%% apply transformations
                self.transform = scaleTransform;
                
                break;
            case .Ended:
                afterSwipeAction()
            break;
            default:
            break;
        }
        
    }
    
    func afterSwipeAction() {
        
        if (xFromCenter > ACTION_MARGIN) {
            rightAction();
        } else if (xFromCenter < -ACTION_MARGIN){
            leftAction();
        } else {
            animateCardBack()
           
        }
    }
    
    func rightAction() {
        animateCardToTheRight()
        delegate?.cardSwipedRight(self)
    }
    
    func animateCardToTheRight() {
        let rightEdge = CGFloat(500)
        animateCardOutTo(rightEdge)
    }
    
    func leftAction() {
        animateCardToTheLeft()
        delegate?.cardSwipedLeft(self)
    }
    
    func animateCardToTheLeft() {
        let leftEdge = CGFloat(-500)
        animateCardOutTo(leftEdge)
    }
    
    func animateCardOutTo(edge: CGFloat) {
        let finishPoint = CGPointMake(edge, 2*yFromCenter + self.originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint;
            }, completion: {
                (value: Bool) in
                self.removeFromSuperview()
        })
        
    }

    func animateCardBack() {
        UIView.animateWithDuration(0.3, animations: {
            self.center = self.originalPoint;
            self.transform = CGAffineTransformMakeRotation(0);
            //self.overlayView?.alpha = 0;
            }
        )
    }


    /**
     
     Dictionary:
     
     AverageDailyVolume = 3802800;
     Change = "-0.85";
     DaysHigh = "25.82";
     DaysLow = "24.56";
     DaysRange = "24.56 - 25.82";
     LastTradePriceOnly = "25.46";
     MarketCapitalization = "4.38B";
     Name = "Murphy Oil Corporation Common S";
     StockExchange = NYQ;
     Symbol = MUR;
     Volume = 3212238;
     YearHigh = "52.00";
     YearLow = "23.20";
     symbol = MUR;
     
    **/
    
     /*
     --------------------------------------------------------
     MARK: - Update Card Information
     --------------------------------------------------------
     */
    
    func setMyInformation(dictionary: NSDictionary, symbol:String) {
        
        // Retrieve Card Information
        let lastTradePriceOnly = dictionary["LastTradePriceOnly"]!.description
        let name = csvDicKeyToName[symbol]
        let range = dictionary["DaysRange"]!.description
        let yearHigh = dictionary["YearHigh"]!.description
        let yearLow = dictionary["YearLow"]!.description
        let industry = csvDicKeyToIndustry[symbol]
        let change = dictionary["Change"]!.description
        
        let index = change.startIndex.advancedBy(0)
        
        // Set Border Color based on if the stock has a negative change (red) or positive change (green)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.blackColor().CGColor
        
        
        // % Change 
        let topRect = CGRectMake(0, 0, self.frame.size.width, 50)
        let headerView: UIView = UIView(frame: topRect)
        
        var imageName = ""
        
        if change[index] == "+" {
            
            headerView.backgroundColor = UIColorFromRGB(0x2BC65E)
            imageName = "UpArrow.png"
            
        }
        else {
            
            headerView.backgroundColor = UIColorFromRGB(0xDE342E)
            imageName = "DownArrow.png"
        }
        
        // Add Header View 
        self.addSubview(headerView)
        
        // Add arrow to the view
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 230, y: 120, width: 40, height: 60)
        self.addSubview(imageView)
        
        
        // Begin to programatically place all UI componenets and assign appropriate values
        
        var label = ""
        let font:UIFont? = UIFont.boldSystemFontOfSize(14.0)
        var boldAge = NSMutableAttributedString()
        
        self.stockSymbol.frame = CGRectMake(0, 15, self.frame.size.width, 20)
        self.stockSymbol.textAlignment = .Center
        self.stockSymbol.text = symbol;
        self.stockSymbol.font = UIFont (name: "Helvetica-Bold", size: 22)
        self.stockSymbol.textColor = UIColor.whiteColor();
        self.addSubview(self.stockSymbol)
        
        self.stockName.frame = CGRectMake(0, 75, self.frame.size.width, 20)
        self.stockName.textAlignment = .Center
        self.stockName.text = name;
        self.stockName.textColor = UIColor.blackColor();
        self.stockName.font = UIFont.systemFontOfSize(16)
        self.stockName.adjustsFontSizeToFitWidth = true
        self.addSubview(self.stockName)
        
        self.lastTradedPrice.frame = CGRectMake(10, 120, self.frame.size.width, 20)
        self.lastTradedPrice.textAlignment = .Left
        label = "Price: $" + lastTradePriceOnly
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 7));
        self.lastTradedPrice.font = UIFont.systemFontOfSize(16)
        self.lastTradedPrice.attributedText = boldAge
        self.addSubview(self.lastTradedPrice)
        
        self.stockChange.frame = CGRectMake(220, 180, self.frame.size.width, 20)
        self.stockChange.textAlignment = .Left
        label = change + "%"
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
//        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 8));
        self.stockChange.font = UIFont.systemFontOfSize(16)
        self.stockChange.attributedText = boldAge
        self.addSubview(self.stockChange)
        
        self.stockRangeHigh.frame = CGRectMake(10, 150, self.frame.size.width, 20)
        self.stockRangeHigh.textAlignment = .Left
        let array = range.componentsSeparatedByString(" ")
        label = "Days High: $" + array[0]
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 10));
        self.stockRangeHigh.font = UIFont.systemFontOfSize(16)
        self.stockRangeHigh.attributedText = boldAge
        self.addSubview(self.stockRangeHigh)
        
        self.stockRangeLow.frame = CGRectMake(10, 180, self.frame.size.width, 20)
        self.stockRangeLow.textAlignment = .Left
        
        if array.count < 2 {
            label = "Days Low: $ N/A"
        }
        
        else {
          label = "Days Low: $" + array[2]
        }
        
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 9));
        self.stockRangeLow.font = UIFont.systemFontOfSize(16)
        self.stockRangeLow.attributedText = boldAge
        self.addSubview(self.stockRangeLow)
        
        
        self.stockYearHigh.frame = CGRectMake(10, 210, self.frame.size.width, 20)
        self.stockYearHigh.textAlignment = .Left
        label = "Year High: $" + yearHigh
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 11));
        self.stockYearHigh.font = UIFont.systemFontOfSize(16)
        self.stockYearHigh.attributedText = boldAge
        self.addSubview(self.stockYearHigh)
        
        self.stockYearLow.frame = CGRectMake(10, 240, self.frame.size.width, 20)
        self.stockYearLow.textAlignment = .Left
        label = "Year Low: $" + yearLow
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 10));
        self.stockYearLow.font = UIFont.systemFontOfSize(16)
        self.stockYearLow.attributedText = boldAge
        self.addSubview(self.stockYearLow)
        
        self.stockIndustry.frame = CGRectMake(10, 270, self.frame.size.width, 20)
        self.stockIndustry.textAlignment = .Left
        label = "Industry: " + industry!
        boldAge = NSMutableAttributedString(string:label, attributes:nil)
        boldAge.addAttribute(NSFontAttributeName, value: font!, range:  NSRange(location: 0, length: 10));
        self.stockIndustry.font = UIFont.systemFontOfSize(16)
        self.stockIndustry.attributedText = boldAge
        self.addSubview(self.stockIndustry)
        
    
        let webV:UIWebView = UIWebView(frame: CGRectMake(2, 320, self.frame.size.width-5, self.frame.size.height-320))
        webV.loadRequest(NSURLRequest(URL: NSURL(string: graphURL + symbol)!))
        webV.scalesPageToFit = true
        webV.scrollView.scrollEnabled = false
        webV.contentMode = .ScaleAspectFit
        
        self.addSubview(webV)
    }
    
    // helper function for UI Color RGB convertion
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Mark - Web View Delegate Methods
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        print("Webview fail with error \(error)");
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        print("Webview started Loading")
    }
    func webViewDidFinishLoad(webView: UIWebView!) {
        print("Webview did finish load")
    }


}


/*
--------------------------------------------------------
MARK: - Protocols
--------------------------------------------------------
*/

protocol DraggableViewDelegate {
    func cardSwipedLeft(card: DraggableView)
    func cardSwipedRight(card: DraggableView)
}