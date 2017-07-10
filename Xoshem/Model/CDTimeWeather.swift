//
//  CDTimeWeather.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore

class CDTimeWeather: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDTimeWeather {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDTimeWeather
    }
    
    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDTimeWeather]? {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil, sortDescriptors: nil,
                                                    limit: 0, mco: mco) as? [CDTimeWeather]
    }
    
    class func fetchWithForecastResult(_ forecastResult: CDForecastResult,
                                       mco: NSManagedObjectContext) throws -> [CDTimeWeather]? {
        guard let identity = forecastResult.identity else {
            return nil
        }
        let predicate = NSPredicate(format: "forecastResult = %@", identity)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self),
                                                    predicate: predicate, sortDescriptors: nil,
                                                    limit: 0, mco: mco) as? [CDTimeWeather]
    }
    
    override var description : String {
        var aux : String = "["
        aux += "\(hour);"
        aux += "\(cloudCoverHigh);"
        aux += "\(cloudCoverLow);"
        aux += "\(cloudCoverMid);"
        aux += "\(cloudCoverTotal);"
        aux += "\(freezingLevel);"
        aux += "\(precipitation);"
        aux += "\(relativeHumidity);"
        aux += "\(seaLevelPressure);"
        aux += "\(temperature);"
        aux += "\(temperatureReal);"
        aux += "\(windDirection);"
        if let _windDirectionName = windDirectionName {
            aux += "\(_windDirectionName);"
        } else { aux += "();" }
        aux += "\(windGust);"
        aux += "\(windSpeed);"
        if let _forecasts = forecasts {
            aux += "\(_forecasts.description)"
        } else { aux += "();" }
        aux += "]"
        return aux
    }
}
