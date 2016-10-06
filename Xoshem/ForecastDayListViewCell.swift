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
        self.iconView.alpha = 0
        self.keyLabel.alpha = 0
        self.valueLabel.alpha = 0
    }
    
    func configure(iconName: String?, key: String?, value: String?)
    {
        self.configure()
        if let _iconName = iconName {
            self.iconView.alpha = 1
            self.iconView.image = UIImage.init(named: _iconName)
        }
        if let _key = key {
            self.keyLabel.alpha = 1
            self.keyLabel.text = _key
        }
        if let _value = value {
            self.valueLabel.alpha = 1
            self.valueLabel.text = _value
        }
    }

}
