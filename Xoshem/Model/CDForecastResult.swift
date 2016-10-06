//
//  ForecastResult.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore

class CDForecastResult: CDSpot {
    
    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDForecastResult {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecastResult
    }
    
    func update(forecastResult: ForecastResult) throws -> Bool {
        // Only update the menu if all the relevant properties can be accessed.
        var ret = try super.update(forecastResult as Spot)
        guard let
            _countryId      = forecastResult.countryId,
            _latitude       = forecastResult.latitude,
            _longitude      = forecastResult.longitude,
            _altitude       = forecastResult.altitude,
            _timezone       = forecastResult.timezone,
            _gmtHourOffset  = forecastResult.gmtHourOffset,
            _sunrise        = forecastResult.sunrise,
            _sunset         = forecastResult.sunset,
            _currentModel   = forecastResult.currentModel,
            _tides          = forecastResult.tides,
            _models         = forecastResult.models else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateForecastResultIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDForecastResult using ForecastResult object",
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
                    if let forecastModel = forecastResult.forecasts![model],
                           mco = self.managedObjectContext {
                        if let cdForecastModel = try CDForecastModel.importObject(forecastModel,
                                                                                  forecastResultId: forecastResult.identity!,
                                                                                  mco: mco) {
                            set.addObject(cdForecastModel)
                        }
                    }
                }
                forecastModels = set
                
            } catch {
                ret = false
                let myerror = Error(code: Common.ErrorCode.CDUpdateForecastResultOnForecastModelIssue.rawValue,
                                    desc: "Failed to import ForecastModel into CDForecastModel inside CDForecastResult",
                                    reason: "Error on update forecast model inside result",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
            }
            
            ret = ret && true
        }
        return ret
    }
    
    
    class func importObject(object: ForecastResult, mco: NSManagedObjectContext) throws -> CDForecastResult {
        return try CDForecastResult.importObject(object, mco: mco,
        search: {
            (wgObject, mco) -> [AnyObject] in
            let predicate = NSPredicate(format: "identity = %@", object.identity!)
            return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDForecastResult]
        },
        update: {
            (cdObject, wgObject, mco) -> Bool in
            return try (cdObject as! CDForecastResult).update(wgObject as! ForecastResult)
        },
        create: { (mco) -> AnyObject in
            return CDForecastResult.createInManageContextObject(mco)
        }) as! CDForecastResult
    }
    
    class func fetch(mco: NSManagedObjectContext) throws -> [CDForecastResult] {
        let predicate = NSPredicate(format: "currentModel.length > 0")
        let sortDescriptors = [NSSortDescriptor(key: "placemarkResult", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: sortDescriptors, limit: 0, mco: mco) as! [CDForecastResult]
    }
    
    func currentForecastModel() -> CDForecastModel? {
        guard let _currentModel = currentModel,
                  _currentForecastModel = fetch(_currentModel) else {
            return nil
        }
        return _currentForecastModel
    }
    
    func weather(hour: Int) -> CDTimeWeather? {
        guard let _forecastModel = currentForecastModel(),
            _forecast = _forecastModel.forecast as CDForecast?,
            _timeWeather = _forecast.fetch(hour)
            else {
                return nil
        }
        return _timeWeather
    }

    func temperatureByHour(hour: Int) -> Float {
        guard let _forecastModel = currentForecastModel(),
                  _forecast = _forecastModel.forecast as CDForecast?,
                  _timeWeather = _forecast.fetch(hour),
                  _temperature = _timeWeather.temperature as Float?
        else {
            return 0.0
        }
        return _temperature
    }
    
    func fetch(model: String) -> CDForecastModel? {
        guard let _forecastModels = self.forecastModels else {
            return nil
        }
        var fm : CDForecastModel? = nil
        for forecastModel in _forecastModels {
            if forecastModel.model == model {
                fm = forecastModel as? CDForecastModel
                break
            }
        }
        return fm
    }
    
    override func namecheck() -> String? {
        var aux : String = ""
        if let _placemarkResult = placemarkResult,
               _namecheck = _placemarkResult.namecheck() {
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
