//
//  ForecastDayStepViewCell.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/3/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit

class ForecastDayStepViewCell: UITableViewCell {

    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var hourStepper: UIStepper!
    var updateClosure: ((_ value: Int) -> ())?
    
    func configureCell(_ hour: Int, limit:Int, didUpdate:@escaping (_ value: Int) -> Void) {
        hourLabel.text = "\(hour) h"
        hourStepper.maximumValue = 61
        updateClosure = didUpdate
    }

    @IBAction func hourStepperChanged(_ sender: UIStepper) {
        if let closure = updateClosure {
            closure(Int(sender.value))
        }
    }

}
