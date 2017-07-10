//
//  CDLocation.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/20/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import JFCore

class CDLocation: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDLocation {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDLocation
    }
    
    class func importObject(_ object: CLLocation?, mco: NSManagedObjectContext) throws -> CDLocation? {
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            let name = "[\(object.coordinate.latitude):\(object.coordinate.longitude):\(object.altitude)]"
            let predicate = NSPredicate(format: "name = %@", name)
            guard let array = try CDLocation.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                   sortDescriptors: [], limit: 1, mco: mco) as? [CDLocation]
                else {
                    return nil
            }
            return array
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDLocation
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDLocation.createInManageContextObject(mco)
        }
        
        return try CDLocation.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                           update: update, create: create) as? CDLocation
    }

    func update(_ object: CLLocation?) throws -> Bool {
        
        guard let object = object else {
            return false
        }

        guard let
            _latitude           = object.coordinate.latitude as Double?,
            let _longitude          = object.coordinate.longitude as Double?,
            let _altitude           = object.altitude as Double?,
            let _horizontalAccuracy = object.horizontalAccuracy as Double?,
            let _verticalAccuracy   = object.verticalAccuracy as Double?,
            let _floor              = object.floor as CLFloor?,
            let _floorLevel         = Int16(_floor.level) as Int16?,
            let _name               = "[\(_latitude):\(_longitude):\(_altitude)]" as String?
            else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateLocationIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed at import CLLocation object into CDLocation",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if  latitude           == _latitude &&
            longitude          == _longitude &&
            altitude           == _altitude &&
            horizontalAccuracy == _horizontalAccuracy &&
            verticalAccuracy   == _verticalAccuracy &&
            floorLevel         == _floorLevel &&
            name               == _name {
            return false
        }

        latitude           = _latitude
        longitude          = _longitude
        altitude           = _altitude
        horizontalAccuracy = _horizontalAccuracy
        verticalAccuracy   = _verticalAccuracy
        floorLevel         = _floorLevel
        name               = _name
        return true
    }

    class func search(_ object: CLLocation, mco: NSManagedObjectContext) throws -> [CDLocation] {
        let name = "[\(object.coordinate.latitude):\(object.coordinate.longitude):\(object.altitude)]"
        let predicate = NSPredicate(format: "name = %@", name as String)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDLocation]
    }
    
    class func searchLocation(_ object: CLLocation, mco: NSManagedObjectContext) throws -> CDLocation? {
        var array = [CDLocation]()
        
        do {
            array = try CDLocation.search(object, mco: mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdSearchLocationsIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Failed to search all the locations using CLLocation",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
           throw myerror
        }
        
        if array.count == 1 {
            return array.first!
        }
        return nil
    }
    

    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDLocation] {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil,
                                                    sortDescriptors: [], limit: 0, mco: mco) as! [CDLocation]
    }
    
    class func fetchCurrent(_ mco: NSManagedObjectContext) throws -> CDLocation? {
        var array = [CDLocation]()
        
        do {
            let predicate = NSPredicate(format: "isCurrent = %d", 1)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                        sortDescriptors: [], limit: 1, mco: mco) as! [CDLocation]
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdSearchCurrentLocationIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Error on search entity name location",
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
        aux += "\(altitude);"
        aux += "\(floorLevel);"
        aux += "\(horizontalAccuracy);"
        aux += "\(isCurrent);"
        aux += "\(latitude);"
        aux += "\(longitude);"
        if let _name = name {
            aux += "\(_name);"
        } else { aux += "();" }
        aux += "\(verticalAccuracy);"
        if let _placemarks = placemarks {
            aux += "\(_placemarks.count);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }
    
}
