//
//  SpinnerView.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/18/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

@IBDesignable class SpinnerView: UIView, NVActivityIndicatorViewable  {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(self.randomAI)
        self.randomAI.startAnimation()
        self.observeSpinner()
    }
 
    private func observeSpinner()
    {
        self.unobserveSpinner()
        
        NSNotificationCenter.defaultCenter()
            .addObserverForName(Common.notification.spinner.start, object: nil, queue: nil) { [weak self] (NSNotification) in
                guard let strong = self else { return }
                if !strong.randomAI.animating {
                    strong.randomAI.stopAnimation()
                    strong.changeSpinner()
                    strong.randomAI.startAnimation()
                }
        }
        NSNotificationCenter.defaultCenter()
            .addObserverForName(Common.notification.spinner.stop, object: nil, queue: nil) { [weak self] (NSNotification) in
                guard let strong = self else { return }
                if strong.randomAI.animating {
                    strong.randomAI.stopAnimation()
                }
        }
    }
    
    private func unobserveSpinner()
    {
        for notification in [Common.notification.spinner.start, Common.notification.spinner.stop] {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }
    
    func randomTypeOfSpinner() -> NVActivityIndicatorType {
        let allTypes = NVActivityIndicatorType.allTypes
        let k = allTypes.count
        let r = Int(arc4random_uniform(UInt32(k))) + 1
        var ait : NVActivityIndicatorType = NVActivityIndicatorType.Blank
        
        var i : Int = 0
        for item in NVActivityIndicatorType.allTypes {
            i += 1
            ait = item
            if i == r {
                break
            }
        }
        return ait
    }
    
    func randomColorOfSpinner() -> UIColor {
        let red = CGFloat(arc4random() % 255) / 255
        let green = CGFloat(arc4random() % 255) / 255
        let blue = CGFloat(arc4random() % 255) / 255
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    func changeSpinner() {
        self.randomAI.type = self.randomTypeOfSpinner()
        self.randomAI.color = self.randomColorOfSpinner()
    }
    
    internal var randomAI: NVActivityIndicatorView {
        if _randomAI != nil {
            return _randomAI!
        }
        
        _randomAI = NVActivityIndicatorView.init(frame: frame, type: self.randomTypeOfSpinner(), color: self.randomColorOfSpinner(), padding: CGFloat(5.0))
        _randomAI?.sizeToFit()
        _randomAI?.userInteractionEnabled = false
        
        return _randomAI!
    }
    var _randomAI: NVActivityIndicatorView? = nil
}
