//
//  ForecastDayListViewCell.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit

class ForecastDayListViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
        
    func configure()
    {
        iconView.alpha = 0
        keyLabel.alpha = 0
        valueLabel.alpha = 0
    }
    
    func configure(_ iconName: String?, key: String?, value: String?)
    {
        configure()
        if let _iconName = iconName {
            iconView.alpha = 1
            iconView.image = UIImage.init(named: _iconName)
        }
        if let _key = key {
            keyLabel.alpha = 1
            keyLabel.text = _key
        }
        if let _value = value {
            valueLabel.alpha = 1
            valueLabel.text = _value
        }
    }

}
