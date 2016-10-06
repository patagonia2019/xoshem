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

    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDForecast {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecast
    }
    
    func update(object: Forecast) throws -> Bool {
        var ret = super.update()
        guard let
            _date      = object.initDate,
            _initDate  = _date.timeIntervalSince1970 as NSTimeInterval?,
            _initStamp = object.initStamp as Int?,
            _modelName = object.modelName as String?,
            _temperature       = object.temperature as TimeWeather?,
            _cloudCoverTotal   = object.cloudCoverTotal as TimeWeather?,
            _cloudCoverHigh    = object.cloudCoverHigh as TimeWeather?,
            _cloudCoverMid     = object.cloudCoverMid as TimeWeather?,
            _cloudCoverLow     = object.cloudCoverLow as TimeWeather?,
            _relativeHumidity  = object.relativeHumidity as TimeWeather?,
            _windGust          = object.windGust as TimeWeather?,
            _seaLevelPressure  = object.seaLevelPressure as TimeWeather?,
            _freezingLevel     = object.freezingLevel as TimeWeather?,
            _precipitation     = object.precipitation as TimeWeather?,
            _windSpeed         = object.windSpeed as TimeWeather?,
            _windDirection     = object.windDirection as TimeWeather?,
            _windDirectionName = object.windDirectionName as TimeWeather?,
            _temperatureReal   = object.temperatureReal as TimeWeather?,
            _temperatureValue       = _temperature.value,
            _cloudCoverTotalValue   = _cloudCoverTotal.value,
            _cloudCoverHighValue    = _cloudCoverHigh.value,
            _cloudCoverMidValue     = _cloudCoverMid.value,
            _cloudCoverLowValue     = _cloudCoverLow.value,
            _relativeHumidityValue  = _relativeHumidity.value,
            _windGustValue          = _windGust.value,
            _seaLevelPressureValue  = _seaLevelPressure.value,
            _freezingLevelValue     = _freezingLevel.value,
            _precipitationValue     = _precipitation.value,
            _windSpeedValue         = _windSpeed.value,
            _windDirectionValue     = _windDirection.value,
            _windDirectionNameValue = _windDirectionName.value,
            _temperatureRealValue   = _temperatureReal.value
            else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateForecastIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update forecast",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        initDate  = _initDate
        initStamp = Int64(_initStamp)
        modelName = _modelName

        let timeWeathers = NSMutableSet()
        
        for hour in _temperatureValue.keys {
            guard let mco = self.managedObjectContext else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateForecastCreateTimeWeatherIssue.rawValue,
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
            timeWeathers.addObject(timeWeather)
        }
        
        self.timeWeathers = timeWeathers

        ret = ret && true
        
        return ret
    }
    
    class func search(forecast: Forecast, mco: NSManagedObjectContext) throws -> [CDForecast] {
        let predicate = NSPredicate(format: "modelName = %@", forecast.modelName!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDForecast]
    }
    
    class func importObject(object: Forecast, forecastResultId: String, model: String, mco: NSManagedObjectContext) throws -> CDForecast? {
        return try CDForecast.importObject(object, mco: mco,
           search: {
                (wgObject, mco) -> [AnyObject] in
                    let predicate = NSPredicate(format: "forecastModel.forecastResult.identity = %@ and forecastModel.forecastResult.currentModel = %@",
                        forecastResultId, model)
                    return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                        sortDescriptors: [], limit: 1,
                        mco: mco) as! [CDForecast]

            },
           update: {
                (cdObject, wgObject, mco) -> Bool in
                return try (cdObject as! CDForecast).update(wgObject as! Forecast)
            },
           create: { (mco) -> AnyObject in
                return CDForecast.createInManageContextObject(mco)
        }) as? CDForecast
    }

    func fetch(hour: Int) -> CDTimeWeather? {
        var hour3 = hour
        let remainder = hour % 3
        hour3 -= remainder

        guard let  _timeWeathers = self.timeWeathers,
                _objects = _timeWeathers.allObjects as? [CDTimeWeather] else {
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
    
    class func searchWithForecastResultId(forecastResultId: String, model: String, mco: NSManagedObjectContext) throws -> CDForecast? {
        var array = [CDForecast]()
        
        do {
            let predicate = NSPredicate(format: "forecastModel.forecastResult.identity = %@ and forecastModel.forecastResult.currentModel = %@",
                                        forecastResultId, model)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                         sortDescriptors: [], limit: 1,
                                                         mco: mco) as! [CDForecast]
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.CDSearchForecastWithIdentifierModelIssue.rawValue,
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

    class func fetch(mco: NSManagedObjectContext) throws -> [CDForecast]? {
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
