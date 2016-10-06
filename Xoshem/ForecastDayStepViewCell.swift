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
    var updateClosure: ((value: Int) -> ())?
    
    func configureCell(hour: Int, limit:Int, didUpdate:(value: Int) -> Void) {
        self.hourLabel.text = "\(hour) h"
        self.hourStepper.maximumValue = 61
        self.updateClosure = didUpdate
    }

    @IBAction func hourStepperChanged(sender: UIStepper) {
        if let closure = self.updateClosure {
            closure(value: Int(sender.value))
        }
    }

}
