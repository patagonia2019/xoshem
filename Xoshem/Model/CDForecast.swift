//
//  CDForecast.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore
class CDForecast: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDForecast {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecast
    }
    

    class func importObject(_ object: Forecast?, forecastResultId: String?, model: String?,
                            mco: NSManagedObjectContext) throws -> CDForecast? {

        guard let object = object,
              let forecastResultId = forecastResultId,
              let model = model else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            let format = "forecastModel.forecastResult.id_spot = %@ and forecastModel.forecastResult.currentModel = %@"
            let predicate = NSPredicate(format: format, forecastResultId, model)
            guard let array = try CDForecast.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                              sortDescriptors: [], limit: 1, mco: mco) as? [CDForecast]
                else {
                    return nil
            }
            return array
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDForecast
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDForecast.createInManageContextObject(mco)
        }
        
        return try CDForecast.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                           update: update, create: create) as? CDForecast
    }
    

    func update(_ object: Forecast?) throws -> Bool {
        
        guard let object = object else {
            return false
        }
        
        guard let
            _date      = object.initDate,
            let _initDate  = _date.timeIntervalSince1970 as TimeInterval?,
            let _initStamp = object.initStamp as Int?,
            let _modelName = object.modelName as String?,
            let _temperature       = object.temperature as TimeWeather?,
            let _cloudCoverTotal   = object.cloudCoverTotal as TimeWeather?,
            let _cloudCoverHigh    = object.cloudCoverHigh as TimeWeather?,
            let _cloudCoverMid     = object.cloudCoverMid as TimeWeather?,
            let _cloudCoverLow     = object.cloudCoverLow as TimeWeather?,
            let _relativeHumidity  = object.relativeHumidity as TimeWeather?,
            let _windGust          = object.windGust as TimeWeather?,
            let _seaLevelPressure  = object.seaLevelPressure as TimeWeather?,
            let _freezingLevel     = object.freezingLevel as TimeWeather?,
            let _precipitation     = object.precipitation as TimeWeather?,
            let _windSpeed         = object.windSpeed as TimeWeather?,
            let _windDirection     = object.windDirection as TimeWeather?,
            let _windDirectionName = object.windDirectionName as TimeWeather?,
            let _temperatureReal   = object.temperatureReal as TimeWeather?
            else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update forecast",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        initDate  = _initDate
        initStamp = Int64(_initStamp)
        modelName = _modelName

        let timeWeatherMutableSet = NSMutableSet()
        
        let _temperatureValue       = _temperature.value
        let _cloudCoverTotalValue   = _cloudCoverTotal.value
        let _cloudCoverHighValue    = _cloudCoverHigh.value
        let _cloudCoverMidValue     = _cloudCoverMid.value
        let _cloudCoverLowValue     = _cloudCoverLow.value
        let _relativeHumidityValue  = _relativeHumidity.value
        let _windGustValue          = _windGust.value
        let _seaLevelPressureValue  = _seaLevelPressure.value
        let _freezingLevelValue     = _freezingLevel.value
        let _precipitationValue     = _precipitation.value
        let _windSpeedValue         = _windSpeed.value
        let _windDirectionValue     = _windDirection.value
        let _windDirectionNameValue = _windDirectionName.value
        let _temperatureRealValue   = _temperatureReal.value
        
        for hour in _temperatureValue.keys {
            guard let mco = managedObjectContext else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastCreateTimeWeatherIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update forecast",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
               throw myerror
            }
            let timeWeather = CDTimeWeather.createInManageContextObject(mco)
            timeWeather.hour = Int16(hour)!
            if let value = _temperatureValue[hour] as? Float {
                timeWeather.temperature = value
            }
            if let value = _cloudCoverTotalValue[hour] as? Int {
                timeWeather.cloudCoverTotal = Int16(value)
            }
            if let value = _cloudCoverHighValue[hour] as? Int {
                timeWeather.cloudCoverHigh = Int16(value)
            }
            if let value = _cloudCoverMidValue[hour] as? Int {
                timeWeather.cloudCoverMid = Int16(value)
            }
            if let value = _cloudCoverLowValue[hour] as? Int {
                timeWeather.cloudCoverLow = Int16(value)
            }
            if let value = _relativeHumidityValue[hour] as? Int {
                timeWeather.relativeHumidity = Int16(value)
            }
            if let value = _windGustValue[hour] as? Float {
                timeWeather.windGust = value
            }
            if let value = _seaLevelPressureValue[hour] as? Int {
                timeWeather.seaLevelPressure = Int16(value)
            }
            if let value = _freezingLevelValue[hour] as? Int {
                timeWeather.freezingLevel = Int16(value)
            }
            if let value = _precipitationValue[hour] as? Float {
                timeWeather.precipitation = value
            }
            if let value = _windSpeedValue[hour] as? Float {
                timeWeather.windSpeed = value
            }
            if let value = _windDirectionValue[hour] as? Int {
                timeWeather.windDirection = Int16(value)
            }
            if let value = _windDirectionNameValue[hour] as? String {
                timeWeather.windDirectionName = value
            }
            if let value = _temperatureRealValue[hour] as? Float {
                timeWeather.temperatureReal = value
            }
            timeWeatherMutableSet.add(timeWeather)
        }
        
        timeWeathers = timeWeatherMutableSet

        return true
    }
    
    class func search(_ forecast: Forecast, mco: NSManagedObjectContext) throws -> [CDForecast] {
        let predicate = NSPredicate(format: "modelName = %@", forecast.modelName!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDForecast]
    }
    
    func fetch(_ hour: Int) -> CDTimeWeather? {
        var hour3 = hour
        let remainder = hour % 3
        hour3 -= remainder

        guard let  _timeWeathers = timeWeathers,
                let _objects = _timeWeathers.allObjects as? [CDTimeWeather] else {
            return nil
        }
        var tw : CDTimeWeather? = nil
        for timeWeather: CDTimeWeather in _objects {
            if Int(timeWeather.hour) == hour3 {
                tw = timeWeather
                break
            }
        }
        return tw
    }
    
    class func searchWithForecastResultId(_ forecastResultId: String, model: String, mco: NSManagedObjectContext) throws -> CDForecast? {
        var array = [CDForecast]()
        
        do {
            let predicate = NSPredicate(format: "forecastModel.forecastResult.id_spot = %@ and forecastModel.forecastResult.currentModel = %@",
                                        forecastResultId, model)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                         sortDescriptors: [], limit: 1,
                                                         mco: mco) as! [CDForecast]
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdSearchForecastWithIdentifierModelIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Failed to search the forecast with id and model",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
            throw myerror
        }
        
        if array.count == 1 {
            return array.first!
        }
        return nil
    }

    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDForecast]? {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil, sortDescriptors: [], limit: 1, mco: mco) as? [CDForecast]
    }

    override var description : String {
        var aux : String = "["
        aux += "\(initStamp);"
        if let _modelName = modelName {
            aux += "\(_modelName);"
        } else { aux += "();" }
        if let _timeWeathers = timeWeathers {
            aux += "\(_timeWeathers.count);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }

}
