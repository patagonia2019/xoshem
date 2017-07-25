//
//  ForecastLocationCollectionViewCell.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/10/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SwiftIconFont

class ForecastLocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    var placemark: RPlacemark!
    var spotForecast: RWSpotForecast!
    var updateClosure: (() -> ())?

    override func awakeFromNib() {
        changeRounded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        changeRounded()
    }
    
    func configure()
    {
        roundedContainerView.alpha = 0
        cityLabel.alpha = 0
        spotNameLabel.alpha = 0
        degreeLabel.alpha = 0
    }
    
    func updateName() {
        spotNameLabel.text = spotForecast.spotName()
        spotNameLabel.alpha = 1
    }

    func updateSpotName() {
        cityLabel.text = placemark.locationName()
        cityLabel.alpha = 1
    }
    
    func updateTemperature() {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: date)
        guard let hour = components.hour,
              let fcst = spotForecast.fcst,
              let temperature : Float = fcst.temperatureReal(hour: hour) else { return }
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
    
    func configureCell(withPlacemark placemark: RPlacemark, isEditing: Bool, didUpdate:@escaping (Void) -> Void)
    {
        configure()
        self.placemark = placemark
        if let fcr = placemark.spotForecast {
            spotForecast = fcr
        }
        degreeLabel.alpha = 1
        updateName()
        updateSpotName()
        updateTemperature()
        configureColor()
        configureIconLocation()
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
    
    lazy var color: UIColor = {
        return JFCore.Common.randomColor(r : 0)
    }()

    func configureColor() {
        contentView.backgroundColor = color
    }

    func configureLastCell()
    {
        configure()
        roundedContainerView.alpha = 1
        degreeLabel.alpha = 1
        degreeLabel.text = "[Add]"
        contentView.backgroundColor = UIColor.red
    }
    
    func configureIconLocation()
    {
        let size = CGSize(width: 50, height: 50)
        let fontSize :CGFloat = 50.0
        let icon = UIImage.icon(from: .Ionicon, iconColor: .white, code: "location", imageSize: size, ofSize: fontSize)
        locationIcon.image = icon
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

    
    private func changeRounded() {
        let dimension = roundedContainerView.frame.size
        let lenght = dimension.width > dimension.height ? dimension.width : dimension.height
        roundedContainerView.layer.cornerRadius = lenght / 2
    }

}



