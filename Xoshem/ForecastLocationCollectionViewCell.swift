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
        
        self.roundedContainerView.layer.cornerRadius = self.roundedContainerView.frame.size.height / 2
        self.trashButton.exclusiveTouch = true
    }
    
    func configure()
    {
        self.currentLocationImageView.alpha = 0
        self.roundedContainerView.alpha = 0
        self.cityLabel.alpha = 0
        self.spotNameLabel.alpha = 0
        self.degreeLabel.alpha = 0
        self.createAnotherCityImageView.alpha = 0
        self.trashButton.alpha = 0
    }
    
    func updateName() {
        if let _namecheck = forecastResult.namecheck() {
            self.cityLabel.text = "\(_namecheck)"
            self.cityLabel.alpha = 1
        }
        else {
            self.cityLabel.alpha = 0
        }
    }

    func updateSpotName() {
        if let name = forecastResult.name {
            self.spotNameLabel.text = "\(name)"
            self.spotNameLabel.alpha = 1
        }
        else {
            self.spotNameLabel.alpha = 0
        }
    }
    
    func updateTemperature() {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: date)
        guard let temperature : Float = forecastResult.temperatureByHour(components.hour) else {
            self.degreeLabel.alpha = 0
            self.roundedContainerView.alpha = 0
            return
        }
        self.degreeLabel.text = "\(temperature)°"
        self.roundedContainerView.alpha = 1
        self.degreeLabel.alpha = 1
    }
    
    func configureCellWithLocation(location: CDLocation, isEditing: Bool, didUpdate:(Void) -> Void)
    {
        self.configure()
//        self.forecastResult = forecastResult
        self.degreeLabel.alpha = 1
        self.trashButton.alpha = isEditing ? 1 : 0
        self.trashButton.highlighted = self.forecastResult.hide
        self.currentLocationImageView.alpha = self.forecastResult.placemarkResult != nil ? 1 : 0
        self.updateName()
        self.updateSpotName()
        self.updateTemperature()
        self.configureColor()
        self.updateClosure = didUpdate
    }
    
    func configureCell(forecastResult: CDForecastResult, isEditing: Bool, didUpdate:(Void) -> Void)
    {
        self.configure()
        self.forecastResult = forecastResult
        self.degreeLabel.alpha = 1
        self.trashButton.alpha = isEditing ? 1 : 0
        self.trashButton.highlighted = self.forecastResult.hide
        self.currentLocationImageView.alpha = self.forecastResult.placemarkResult != nil ? 1 : 0
        self.updateName()
        self.updateSpotName()
        self.updateTemperature()
        self.configureColor()
        self.updateClosure = didUpdate
    }
    
    func configureColor() {
        self.contentView.backgroundColor = forecastResult.color
    }

    func configureLastCell()
    {
        self.configure()
        self.createAnotherCityImageView.alpha = 1
        self.contentView.backgroundColor = UIColor.redColor()
    }
    
    func selected()
    {
        self.contentView.alpha = 0.5
    }
    
    func unselected()
    {
        self.contentView.alpha = 1.0
    }
    
    @IBAction func trashAction(sender: AnyObject) {
        if let closure = self.updateClosure {
            forecastResult.hide = !forecastResult.hide
            closure()
        }
    }
    
}



