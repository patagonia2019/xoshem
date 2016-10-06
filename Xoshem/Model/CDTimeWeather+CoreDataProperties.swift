//
//  CDTimeWeather+CoreDataProperties.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDTimeWeather {

    @NSManaged var cloudCoverHigh: Int16
    @NSManaged var cloudCoverLow: Int16
    @NSManaged var cloudCoverMid: Int16
    @NSManaged var cloudCoverTotal: Int16
    @NSManaged var freezingLevel: Int16
    @NSManaged var hour: Int16
    @NSManaged var precipitation: Float
    @NSManaged var relativeHumidity: Int16
    @NSManaged var seaLevelPressure: Int16
    @NSManaged var temperature: Float
    @NSManaged var temperatureReal: Float
    @NSManaged var windDirection: Int16
    @NSManaged var windDirectionName: String?
    @NSManaged var windGust: Float
    @NSManaged var windSpeed: Float
    @NSManaged var forecasts: CDForecast?

}
