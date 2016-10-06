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

    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDLocation {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDLocation
    }
    
    func update(object: CLLocation) throws -> Bool {
        
        var ret = super.update()
        guard let
            _latitude           = object.coordinate.latitude as Double?,
            _longitude          = object.coordinate.longitude as Double?,
            _altitude           = object.altitude as Double?,
            _horizontalAccuracy = object.horizontalAccuracy as Double?,
            _verticalAccuracy   = object.verticalAccuracy as Double?,
            _floor              = object.floor as CLFloor?,
            _floorLevel         = Int16(_floor.level) as Int16?,
            _name               = "[\(_latitude):\(_longitude):\(_altitude)]" as String?
            else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateLocationIssue.rawValue,
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
            ret = false
        }
        else {
            latitude           = _latitude
            longitude          = _longitude
            altitude           = _altitude
            horizontalAccuracy = _horizontalAccuracy
            verticalAccuracy   = _verticalAccuracy
            floorLevel         = _floorLevel
            name               = _name
            ret = ret && true
        }
        return ret
    }

    class func search(object: CLLocation, mco: NSManagedObjectContext) throws -> [CDLocation] {
        let name = "[\(object.coordinate.latitude):\(object.coordinate.longitude):\(object.altitude)]"
        let predicate = NSPredicate(format: "name = %@", name as String)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDLocation]
    }
    
    class func searchLocation(object: CLLocation, mco: NSManagedObjectContext) throws -> CDLocation? {
        var array = [CDLocation]()
        
        do {
            array = try CDLocation.search(object, mco: mco)
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.CDSearchLocationsIssue.rawValue,
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
    
    class func importObject(object: CLLocation, mco: NSManagedObjectContext) throws -> CDLocation? {
        return try CDLocation.importObject(object, mco: mco,
        search: {
            (wgObject, mco) -> [AnyObject] in
            let name = "[\(object.coordinate.latitude):\(object.coordinate.longitude):\(object.altitude)]"
            let predicate = NSPredicate(format: "name = %@", name)
            return try CDLocation.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDLocation]
        },
        update: {
            (cdObject, wgObject, mco) -> Bool in
            return try (cdObject as! CDLocation).update(wgObject as! CLLocation)
        },
        create: { (mco) -> AnyObject in
            return CDLocation.createInManageContextObject(mco)
        }) as? CDLocation
    }
    
    class func fetch(mco: NSManagedObjectContext) throws -> [CDLocation] {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil,
                                                    sortDescriptors: [], limit: 0, mco: mco) as! [CDLocation]
    }
    
    class func fetchCurrent(mco: NSManagedObjectContext) throws -> CDLocation? {
        var array = [CDLocation]()
        
        do {
            let predicate = NSPredicate(format: "isCurrent = %d", 1)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                        sortDescriptors: [], limit: 1, mco: mco) as! [CDLocation]
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.CDSearchCurrentLocationIssue.rawValue,
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
