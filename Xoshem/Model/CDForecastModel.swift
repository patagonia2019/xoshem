//
//  CDForecastModel.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore

class CDForecastModel: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDForecastModel {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecastModel
    }

    class func importObject(_ object: ForecastModel?, forecastResultId: String?,
                            mco: NSManagedObjectContext) throws -> CDForecastModel? {
        
        guard let object = object,
            let forecastResultId = forecastResultId else {
                return nil
        }
        
        let search = { () -> [AnyObject]? in
            guard let model = object.model else {
                return nil
            }
            let format = "model = %@ and forecastResult.id_spot = %@"
            let predicate = NSPredicate(format: format, model, forecastResultId)
            guard let array = try CDForecastModel.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                              sortDescriptors: [], limit: 1, mco: mco) as? [CDForecastModel]
                else {
                    return nil
            }
            return array
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDForecastModel
            let wgo = object
            return try obj.update(wgo, forecastResultId: forecastResultId)
        }
        let create = { () -> AnyObject? in
            return CDForecastModel.createInManageContextObject(mco)
        }
        
        return try CDForecastModel.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                           update: update, create: create) as? CDForecastModel
    }

    func update(_ object: ForecastModel?, forecastResultId: String?) throws -> Bool {
        guard let object = object,
            let forecastResultId = forecastResultId else {
                return false
        }

        guard let
            _model      = object.model as String?,
            let _forecast  =  object.info as Forecast?,
            let _mco = managedObjectContext,
            let _cdForecast = try CDForecast.importObject(_forecast, forecastResultId: forecastResultId,
                                                      model: _model, mco: _mco)
            else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastModelIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDForecastModel using ForecastModel object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }

        model  = _model
        forecast = _cdForecast

        return true
    }
    
    
    class func search(_ wgObject: ForecastModel, mco: NSManagedObjectContext) throws -> [CDForecastModel] {
        let predicate = NSPredicate(format: "model = %@", wgObject.model!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [],
                                                    limit: 1, mco: mco) as! [CDForecastModel]
    }
    
    class func fetchWithSpot(withSpot spot:CDSpot, mco: NSManagedObjectContext) throws -> [CDForecastModel]? {
        let predicate = NSPredicate(format: "forecastResult.id_spot = %@", spot.id_spot!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: nil, limit: 0, mco: mco) as? [CDForecastModel]
    }
    
    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDForecastModel]? {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil, sortDescriptors: [], limit: 0, mco: mco) as? [CDForecastModel]
    }

    class func fetchCurrent(_ forecastResult: CDForecastResult, mco: NSManagedObjectContext) throws -> CDForecastModel? {
        var array = [CDForecastModel]()
        
        do {
            guard let id_spot = forecastResult.id_spot,
                      let currentModel = forecastResult.currentModel else {
                        return nil
            }
            let predicate = NSPredicate(format: "forecastResult.id_spot = %@ and forecastResult.currentModel = %@",
                                        id_spot, currentModel)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                         sortDescriptors: [], limit: 1,
                                                         mco: mco) as! [CDForecastModel]
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdSearchCurrentForecastModelIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Failed to search the current firecat",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
            throw myerror
        }
        
        if array.count == 1 {
            return array.first!
        }
        return nil
    }


    override var description : String {
        var aux : String = "["
        if let _model = model {
            aux += "\(_model);"
        } else { aux += "();" }
        if let _forecast = forecast {
            aux += "\(_forecast.description);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }

}
