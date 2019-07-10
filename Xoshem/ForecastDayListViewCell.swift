//
//  ForecastDayListViewCell.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit

class ForecastDayListViewCell: UITableViewCell {

    @IBOutlet weak var iconLabel: UILabel?
    @IBOutlet weak var keyLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    
    func configure()
    {
        if let iconLabel = iconLabel {
            iconLabel.alpha = 0
        }
        if let keyLabel = keyLabel {
            keyLabel.alpha = 0
        }
        if let valueLabel = valueLabel {
            valueLabel.alpha = 0
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func configure(_ iconName: Common.Symbols.FontWeather?, key: String?, value: String?)
    {
        configure()
        if let iconName = iconName,
           let iconLabel = iconLabel {
            iconLabel.alpha = 1
            iconLabel.text = "\(Common.Symbols.show(icon: iconName))"
        }
        if let key = key,
           let keyLabel = keyLabel {
            keyLabel.alpha = 1
            keyLabel.text = key + ": "
        }
        if let value = value,
           let valueLabel = valueLabel {
            valueLabel.alpha = 1
            valueLabel.text = value
        }
    }

}
