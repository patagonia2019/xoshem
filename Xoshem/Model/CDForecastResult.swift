//
//  SpotForecast.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore

class CDForecastResult: CDSpot {
    
    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDForecastResult {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecastResult
    }
    
    class func importObject(_ object: SpotForecast?, mco: NSManagedObjectContext) throws -> CDForecastResult? {
        
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            guard let id_spot = object.id_spot else {
                return nil
            }
            let predicate = NSPredicate(format: "id_spot = %@", id_spot)
            guard let array = try CDForecastResult.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                                    sortDescriptors: [], limit: 1, mco: mco) as? [CDForecastResult]
                else {
                    return nil
            }
            return array
            
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDForecastResult
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDForecastResult.createInManageContextObject(mco)
        }
        
        return try CDForecastResult.importObject(wgObject: object as AnyObject, mco: mco, search: search, update: update, create: create) as? CDForecastResult
    }

    
    func update(_ forecastResult: SpotForecast?) throws -> Bool {

        guard let object = forecastResult,
              let spot = forecastResult else {
            return false
        }
        
        var ret = try super.update(spot)
        guard let
            _countryId      = object.countryId,
            let _latitude       = object.latitude,
            let _longitude      = object.longitude,
            let _altitude       = object.altitude,
            let _timezone       = object.timezone,
            let _gmtHourOffset  = object.gmtHourOffset,
            let _sunrise        = object.sunrise,
            let _sunset         = object.sunset,
            let _currentModel   = object.currentModel,
            let _tides          = object.tides,
            let _models         = object.models else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastResultIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDForecastResult using SpotForecast object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
               throw myerror
        }

        if countryId    == Int16(_countryId) &&
            latitude      == _latitude &&
            longitude     == _longitude &&
            altitude      == Int16(_altitude) &&
            timezone      == _timezone &&
            gmtHourOffset == Int16(_gmtHourOffset) &&
            sunrise       == _sunrise &&
            sunset        == _sunset &&
            currentModel  == _currentModel &&
            tides         == _tides {
            ret = false
        }
        else {
            countryId     = Int16(_countryId)
            latitude      = _latitude
            longitude     = _longitude
            altitude      = Int16(_altitude)
            timezone      = _timezone
            gmtHourOffset = Int16(_gmtHourOffset)
            sunrise       = _sunrise
            sunset        = _sunset
            currentModel  = _currentModel
            tides         = _tides
            hide          = false
            do {
                
                let set = NSMutableSet()
                for model in _models {
                    let forecasts = object.forecasts
                    guard let id_spot = object.id_spot else {
                        continue
                    }
                    if let forecastModel = forecasts[model],
                        let mco = managedObjectContext {
                        if let cdForecastModel = try CDForecastModel.importObject(forecastModel,
                                                                                  forecastResultId: id_spot,
                                                                                  mco: mco) {
                            set.add(cdForecastModel)
                        }
                    }
                }
                forecastModels = set
                
            } catch {
                ret = false
                let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastResultOnForecastModelIssue.rawValue,
                                    desc: "Failed to import ForecastModel into CDForecastModel inside CDForecastResult",
                                    reason: "Error on update forecast model inside result",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
            }
            
            ret = ret && true
        }
        return ret
    }
    
    
    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDForecastResult] {
        let predicate = NSPredicate(format: "currentModel.length > 0")
        let sortDescriptors = [NSSortDescriptor(key: "placemarkResult", ascending: false),
                               NSSortDescriptor(key: "name", ascending: true)]
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                    sortDescriptors: sortDescriptors, limit: 0, mco: mco) as! [CDForecastResult]
    }
    
    func currentForecastModel() -> CDForecastModel? {
        guard let _currentModel = currentModel,
                  let _currentForecastModel = fetch(_currentModel) else {
            return nil
        }
        return _currentForecastModel
    }
    
    func weather(_ hour: Int) -> CDTimeWeather? {
        guard let _forecastModel = currentForecastModel(),
            let _forecast = _forecastModel.forecast as CDForecast?,
            let _timeWeather = _forecast.fetch(hour)
            else {
                return nil
        }
        return _timeWeather
    }

    func temperatureByHour(_ hour: Int) -> Float? {
        guard let _forecastModel = currentForecastModel(),
                  let _forecast = _forecastModel.forecast as CDForecast?,
                  let _timeWeather = _forecast.fetch(hour),
                  let _temperature = _timeWeather.temperature as Float?
        else {
            return nil
        }
        return _temperature
    }
    
    func fetch(_ model: String) -> CDForecastModel? {
        guard let _forecastModels = forecastModels else {
            return nil
        }
        var fm : CDForecastModel? = nil
        for forecastModel in _forecastModels {
            if (forecastModel as AnyObject).model == model {
                fm = forecastModel as? CDForecastModel
                break
            }
        }
        return fm
    }
    
    override func namecheck() -> String? {
        var aux : String = ""
        if let _placemarkResult = placemarkResult,
               let _namecheck = _placemarkResult.namecheck() {
                aux = _namecheck
        } else {
            if let _namecheck = super.namecheck() {
                aux = _namecheck
            }
        }
        return aux.isEmpty ? nil : aux
    }
    
    override var description : String {
        var aux : String = "["
        aux += "\(countryId);"
        aux += "\(latitude);"
        aux += "\(longitude);"
        aux += "\(altitude);"
        if let _sunrise = sunrise {
            aux += "\(_sunrise);"
        } else { aux += "();" }
        if let _sunset = sunset {
            aux += "\(_sunset);"
        } else { aux += "();" }
        if let _currentModel = currentModel {
            aux += "\(_currentModel);"
        } else { aux += "();" }
        if let _forecastModels = forecastModels {
            aux += "\(_forecastModels.count);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }
    
    var color: UIColor {
        if _color != nil {
            return _color!
        }
        _color = JFCore.Common.randomColor()
        
        return _color!
    }
    var _color: UIColor? = nil

}
