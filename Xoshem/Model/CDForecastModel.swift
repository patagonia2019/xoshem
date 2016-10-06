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

    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDForecastModel {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDForecastModel
    }
    
    func update(object: ForecastModel, forecastResultId: String) throws -> Bool {
        var ret = super.update()
        guard let
            _model      = object.model as String?,
            _forecast  =  object.info as Forecast?,
            _mco = self.managedObjectContext,
            _cdForecast = try CDForecast.importObject(_forecast, forecastResultId: forecastResultId,
                                                      model: _model, mco: _mco)
            else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateForecastModelIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDForecastModel using ForecastModel object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }

        model  = _model
        forecast = _cdForecast
        ret = ret && true
        return ret
    }
    
    class func search(wgObject: ForecastModel, mco: NSManagedObjectContext) throws -> [CDForecastModel] {
        let predicate = NSPredicate(format: "model = %@", wgObject.model!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [],
                                                    limit: 1, mco: mco) as! [CDForecastModel]
    }
    
    class func importObject(object: ForecastModel, forecastResultId: String, mco: NSManagedObjectContext) throws -> CDForecastModel? {
        return try CDForecastModel.importObject(object, mco: mco,
            search: {
                (wgObject, mco) -> [AnyObject] in
                let predicate = NSPredicate(format: "model = %@ and forecastResult.identity = %@", (wgObject as! ForecastModel).model!,
                                            forecastResultId)
                return try CDForecastModel.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDForecastModel]
                
            },
            update: {
                (cdObject, wgObject, mco) -> Bool in
                return try (cdObject as! CDForecastModel).update(wgObject as! ForecastModel, forecastResultId: forecastResultId)
            }, create: { (mco) -> AnyObject in
                return CDForecastModel.createInManageContextObject(mco)
        }) as? CDForecastModel
    }
    
    class func fetchWithSpot(withSpot spot:CDSpot, mco: NSManagedObjectContext) throws -> [CDForecastModel]? {
        let predicate = NSPredicate(format: "forecastResult.identity = %@", spot.identity!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: nil, limit: 0, mco: mco) as? [CDForecastModel]
    }
    
    class func fetch(mco: NSManagedObjectContext) throws -> [CDForecastModel]? {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil, sortDescriptors: [], limit: 0, mco: mco) as? [CDForecastModel]
    }

    class func fetchCurrent(forecastResult: CDForecastResult, mco: NSManagedObjectContext) throws -> CDForecastModel? {
        var array = [CDForecastModel]()
        
        do {
            guard let identity = forecastResult.identity,
                      currentModel = forecastResult.currentModel else {
                        return nil
            }
            let predicate = NSPredicate(format: "forecastResult.identity = %@ and forecastResult.currentModel = %@",
                                        identity, currentModel)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                         sortDescriptors: [], limit: 1,
                                                         mco: mco) as! [CDForecastModel]
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.CDSearchCurrentForecastModelIssue.rawValue,
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
