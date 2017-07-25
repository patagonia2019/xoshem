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
    @IBOutlet weak var configureButton: UIButton!

    var updateClosure: ((_ value: Int) -> ())?

    var configureClosure: (() -> ())?

    func configureCell(_ hour: Int,
                       limit:Int,
                       didUpdate: @escaping ((_ value: Int) -> ()),
                       didTapConfigure: @escaping () -> Void)
    {
        hourLabel.text = "\(hour) h"
        hourStepper.maximumValue = 61
        updateClosure = didUpdate
        configureClosure = didTapConfigure
        configureSettingsButton()
    }
    
    fileprivate func configureSettingsButton() {
        let size = CGSize(width: 50, height: 50)
        let fontSize :CGFloat = 50.0
        let icon = UIImage.icon(from: .Ionicon, iconColor: .white, code: "settings", imageSize: size, ofSize: fontSize)
        configureButton.setImage(icon, for: .normal)
    }

    @IBAction func hourStepperChanged(_ sender: UIStepper) {
        if let closure = updateClosure {
            closure(Int(sender.value))
        }
    }
    
    @IBAction func configureAction() {
        if let closure = configureClosure {
            closure()
        }
    }

}
