//
//  ForecastLocationCollectionViewCell.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/10/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

class ForecastLocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    var spotForecast: RWSpotForecast!
    var updateClosure: (() -> ())?

    override func awakeFromNib() {
        
        roundedContainerView.layer.cornerRadius = roundedContainerView.frame.size.height / 2
    }
    
    func configure()
    {
        roundedContainerView.alpha = 0
        cityLabel.alpha = 0
        spotNameLabel.alpha = 0
        degreeLabel.alpha = 0
    }
    
    func updateName() {
        spotNameLabel.text = "\(spotForecast.spotName())"
        spotNameLabel.alpha = 1
    }

    func updateSpotName() {
        if let name = spotForecast.locationName() {
            cityLabel.text = "\(name)"
            cityLabel.alpha = 1
        }
        else {
            cityLabel.alpha = 0
        }
    }
    
    func updateTemperature() {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: date)
        guard let hour = components.hour,
              let fcst = spotForecast.fcst else { return }
        let temperature : Float = fcst.temperature[hour].value
        degreeLabel.text = "\(temperature)°"
        roundedContainerView.alpha = 1
        degreeLabel.alpha = 1
    }
    
    func configureCellWithLocation(_ location: RLocation, isEditing: Bool, didUpdate:@escaping (Void) -> Void)
    {
        configure()
        degreeLabel.alpha = 1
        updateName()
        updateSpotName()
        updateTemperature()
        configureColor()
        updateClosure = didUpdate
    }
    
    func configureCell(_ fcr: RWSpotForecast, isEditing: Bool, didUpdate:@escaping (Void) -> Void)
    {
        configure()
        spotForecast = fcr
        degreeLabel.alpha = 1
        updateName()
        updateSpotName()
        updateTemperature()
        configureColor()
        updateClosure = didUpdate
    }
    
    var color: UIColor {
        if _color != nil {
            return _color!
        }
        _color = JFCore.Common.randomColor()
        
        return _color!
    }
    var _color: UIColor? = nil

    func configureColor() {
        contentView.backgroundColor = color
    }

    func configureLastCell()
    {
        configure()
        contentView.backgroundColor = UIColor.red
    }
    
    func selected()
    {
        contentView.alpha = 0.5
    }
    
    func unselected()
    {
        contentView.alpha = 1.0
    }
    
    @IBAction func trashAction(_ sender: AnyObject) {
        if let closure = updateClosure {
            closure()
        }
    }
    
}



