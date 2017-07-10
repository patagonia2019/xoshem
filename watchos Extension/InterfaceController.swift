//
//  InterfaceController.swift
//  Xoshem-watch WatchKit Extension
//
//  Created by Javier Fuchs on 10/3/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import WatchKit
import Foundation
import JFWindguru

class InterfaceController: WKInterfaceController {
    @IBOutlet var spinner: WKInterfaceActivityRing!
    @IBOutlet var toolbarGroup: WKInterfaceGroup!
    @IBOutlet var topGroup: WKInterfaceGroup!
    @IBOutlet var middleGroup: WKInterfaceGroup!
    @IBOutlet var bottomGroup: WKInterfaceGroup!
    @IBOutlet var slider: WKInterfaceSlider!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var windImage: WKInterfaceImage!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    @IBOutlet var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet var hourLabel: WKInterfaceLabel!
    
    var forecastResult: ForecastResult!
    var sliderHeight: Float!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        observeNotification()
        
        hideWeatherInfo()
        
        if forecastResult != nil
        {
            updateForecastView()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        unobserveNotification()
        
    }
    
    @IBAction func sliderAction(_ value: Float) {
        
    }
    
    
    
    fileprivate func updateForecastView()
    {
        if forecastResult != nil
        {
            weatherImage.setImageNamed (forecastResult.asCurrentWeatherImagename)
            windImage.setImageNamed (forecastResult.asCurrentWindDirectionImagename)
            temperatureLabel.setText (forecastResult.asCurrentTemperature)
            unitLabel.setText (forecastResult.asCurrentUnit)
            locationLabel.setText (forecastResult.asCurrentLocation)
            windSpeedLabel.setText (forecastResult.asCurrentWindSpeed)
            hourLabel.setText (forecastResult.asHourString)
            
            showWeatherInfo()
        }
        
    }
    
    
    fileprivate func observeNotification()
    {
        unobserveNotification()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Common.notification.forecast.updated), object: nil, queue: OperationQueue.main,
               using: {
                [weak self]
                note in if let object: ForecastResult = note.object as? ForecastResult {
                    self?.forecastResult = object
                    self?.updateForecastView()
                }
        })
    }
    
    fileprivate func unobserveNotification()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Common.notification.forecast.updated), object: nil);
    }
    
    fileprivate func hideWeatherInfo()
    {
        toolbarGroup.setAlpha(0)
        topGroup.setAlpha(0)
        middleGroup.setAlpha(0)
        bottomGroup.setAlpha(0)
    }
    
    fileprivate func showWeatherInfo()
    {
        animate(withDuration: Common.animation.duration) { [weak self] () -> Void in
            self?.toolbarGroup.setAlpha(1)
            self?.topGroup.setAlpha(1)
            self?.middleGroup.setAlpha(1)
            self?.bottomGroup.setAlpha(1)
        }
    }
    
    
}
