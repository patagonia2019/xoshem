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
    @IBOutlet weak var currentLocationImageView: UIImageView!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var createAnotherCityImageView: UIImageView!
    @IBOutlet weak var trashButton: UIButton!
    var forecastResult: CDForecastResult!
    var updateClosure: (() -> ())?

    override func awakeFromNib() {
        
        roundedContainerView.layer.cornerRadius = roundedContainerView.frame.size.height / 2
        trashButton.isExclusiveTouch = true
    }
    
    func configure()
    {
        currentLocationImageView.alpha = 0
        roundedContainerView.alpha = 0
        cityLabel.alpha = 0
        spotNameLabel.alpha = 0
        degreeLabel.alpha = 0
        createAnotherCityImageView.alpha = 0
        trashButton.alpha = 0
    }
    
    func updateName() {
        if let _namecheck = forecastResult.namecheck() {
            cityLabel.text = "\(_namecheck)"
            cityLabel.alpha = 1
        }
        else {
            cityLabel.alpha = 0
        }
    }

    func updateSpotName() {
        if let name = forecastResult.name {
            spotNameLabel.text = "\(name)"
            spotNameLabel.alpha = 1
        }
        else {
            spotNameLabel.alpha = 0
        }
    }
    
    func updateTemperature() {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: date)
        guard let hour = components.hour else {
            return
        }
        guard let temperature : Float = forecastResult.temperatureByHour(hour) else {
            degreeLabel.alpha = 0
            roundedContainerView.alpha = 0
            return
        }
        degreeLabel.text = "\(temperature)°"
        roundedContainerView.alpha = 1
        degreeLabel.alpha = 1
    }
    
    func configureCellWithLocation(_ location: CDLocation, isEditing: Bool, didUpdate:@escaping (Void) -> Void)
    {
        configure()
        degreeLabel.alpha = 1
        trashButton.alpha = isEditing ? 1 : 0
        trashButton.isHighlighted = forecastResult.hide
        currentLocationImageView.alpha = forecastResult.placemarkResult != nil ? 1 : 0
        updateName()
        updateSpotName()
        updateTemperature()
        configureColor()
        updateClosure = didUpdate
    }
    
    func configureCell(_ fcr: CDForecastResult, isEditing: Bool, didUpdate:@escaping (Void) -> Void)
    {
        configure()
        forecastResult = fcr
        degreeLabel.alpha = 1
        trashButton.alpha = isEditing ? 1 : 0
        trashButton.isHighlighted = forecastResult.hide
        currentLocationImageView.alpha = forecastResult.placemarkResult != nil ? 1 : 0
        updateName()
        updateSpotName()
        updateTemperature()
        configureColor()
        updateClosure = didUpdate
    }
    
    func configureColor() {
        contentView.backgroundColor = forecastResult.color
    }

    func configureLastCell()
    {
        configure()
        createAnotherCityImageView.alpha = 1
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
            forecastResult.hide = !forecastResult.hide
            closure()
        }
    }
    
}



