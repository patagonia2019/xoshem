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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.observeNotification()
        
        self.hideWeatherInfo()
        
        if self.forecastResult != nil
        {
            self.updateForecastView()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.unobserveNotification()
        
    }
    
    @IBAction func sliderAction(value: Float) {
        
    }
    
    
    
    private func updateForecastView()
    {
        if self.forecastResult != nil
        {
            self.weatherImage.setImageNamed(self.forecastResult.asCurrentWeatherImagename)
            self.windImage.setImageNamed(self.forecastResult.asCurrentWindDirectionImagename)
            self.temperatureLabel.setText(self.forecastResult.asCurrentTemperature)
            self.unitLabel.setText(self.forecastResult.asCurrentUnit)
            self.locationLabel.setText(self.forecastResult.asCurrentLocation)
            self.windSpeedLabel.setText(self.forecastResult.asCurrentWindSpeed)
            self.hourLabel.setText(self.forecastResult.asHourString)
            
            self.showWeatherInfo()
        }
        
    }
    
    
    private func observeNotification()
    {
        self.unobserveNotification()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Common.notification.forecast.updated, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            note in if let object: ForecastResult = note.object as? ForecastResult {
                self.forecastResult = object
                self.updateForecastView()
            }})
    }
    
    private func unobserveNotification()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Common.notification.forecast.updated, object: nil);
    }
    
    private func hideWeatherInfo()
    {
        self.toolbarGroup.setAlpha(0)
        self.topGroup.setAlpha(0)
        self.middleGroup.setAlpha(0)
        self.bottomGroup.setAlpha(0)
    }
    
    private func showWeatherInfo()
    {
        self.animateWithDuration(Common.animation.duration) { () -> Void in
            self.toolbarGroup.setAlpha(1)
            self.topGroup.setAlpha(1)
            self.middleGroup.setAlpha(1)
            self.bottomGroup.setAlpha(1)
        }
    }
    
    
}
