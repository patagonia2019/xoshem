//
//  CDPlacemark.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/20/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import JFCore

class CDPlacemark: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDPlacemark {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDPlacemark
    }

    
    class func importObject(_ object: CLPlacemark?, mco: NSManagedObjectContext) throws -> CDPlacemark? {
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            var predicate : NSPredicate? = nil
            if let name = object.name {
                predicate = NSPredicate(format: "name = %@", name)
            }
            else if let locality = object.locality {
                predicate = NSPredicate(format: "locality = %@", locality)
            }
            guard let array = try CDPlacemark.searchEntityName(NSStringFromClass(self),
                                                               predicate: predicate,
                                                               sortDescriptors: [],
                                                               limit: 1,
                                                               mco: mco) as? [CDPlacemark]
                else {
                    return nil
            }
            return array
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDPlacemark
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDPlacemark.createInManageContextObject(mco)
        }
        
        return try CDPlacemark.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                            update: update, create: create) as? CDPlacemark
    }

    
    func update(_ object: CLPlacemark?) throws -> Bool {
        
        guard let object = object else {
            return false
        }

        guard let
            _locality               = object.locality,
            let _name                   = object.name,
            let _country                = object.country
            else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdatePlacemarkIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed at import CLPlacemark oject into CDPlacemark",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror

        }
        locality                = _locality
        country                 = _country
        name                    = _name
        thoroughfare            = object.thoroughfare
        subThoroughfare         = object.subThoroughfare
        subLocality             = object.subLocality
        administrativeArea      = object.administrativeArea
        subAdministrativeArea   = object.subAdministrativeArea
        postalCode              = object.postalCode
        isoCountryCode          = object.isoCountryCode
        inlandWater             = object.inlandWater
        ocean                   = object.ocean
        if let _areaOfInterest = object.areasOfInterest {
            areasOfInterest         = _areaOfInterest.description
        }

        return true
    }
    
    class func search(_ placemark: CLPlacemark, mco: NSManagedObjectContext) throws -> [CDPlacemark] {
        let predicate = NSPredicate(format: "name = %@ && country = %@ && locality = %@", placemark.name!,
                                    placemark.country!, placemark.locality!)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [],
                                                    limit: 1, mco: mco) as! [CDPlacemark]
    }
    
    class func searchPlacemark(_ object: CLPlacemark, mco: NSManagedObjectContext) throws -> CDPlacemark? {
        var array = [CDPlacemark]()
        
        do {
            array = try CDPlacemark.search(object, mco: mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdSearchPlacemarksIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Failed to search all the placemarks",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
            throw myerror
        }
        
        if array.count == 1 {
            return array.first!
        }
        return nil
    }
    
    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDPlacemark] {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil, sortDescriptors: [], limit: 0, mco: mco) as! [CDPlacemark]
    }

    
    class func fetchCurrent(_ mco: NSManagedObjectContext) throws -> CDPlacemark? {
        var array = [CDPlacemark]()
        
        do {
            let predicate = NSPredicate(format: "isCurrent = %d", 1)
            array = try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                         sortDescriptors: [], limit: 1, mco: mco) as! [CDPlacemark]
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdFetchCurrentPlacemarkIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Failed to fetch current placemarks",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
            throw myerror
        }
        
        if array.count == 1 {
            return array.first!
        }
        return nil
    }
    
    func namecheck() -> String? {
        var aux : String = ""
        if let _name = name {
            aux = "\(_name)"
        }
        if let _subLocality = subLocality {
            if !aux.isEmpty {
                aux += ", "
            }
            aux = "\(_subLocality)"
        }
        else if let _locality = locality {
            if !aux.isEmpty {
                aux += ", "
            }
            aux = "\(_locality)"
        }
        else if let _administrativeArea = administrativeArea {
            if !aux.isEmpty {
                aux += ", "
            }
            aux = "\(_administrativeArea)"
        }
        else if let _subAdministrativeArea = subAdministrativeArea {
            if !aux.isEmpty {
                aux += ", "
            }
            aux = "\(_subAdministrativeArea)"
        }
        if let _country = country {
            if !aux.isEmpty {
                aux += ", "
            }
            aux += "\(_country)"
        }
        return aux.isEmpty ? nil : aux
    }

 
    override var description : String {
        var aux : String = "["
        if let _administrativeArea = administrativeArea {
            aux += "\(_administrativeArea);"
        } else { aux += "();" }
        if let _areasOfInterest = areasOfInterest {
            aux += "\(_areasOfInterest);"
        } else { aux += "();" }
        if let _country = country {
            aux += "\(_country);"
        } else { aux += "();" }
        if let _inlandWater = inlandWater {
            aux += "\(_inlandWater);"
        } else { aux += "();" }
        if let _isoCountryCode = isoCountryCode {
            aux += "\(_isoCountryCode);"
        } else { aux += "();" }
        if let _locality = locality {
            aux += "\(_locality);"
        } else { aux += "();" }
        if let _name = name {
            aux += "\(_name);"
        } else { aux += "();" }
        if let _ocean = ocean {
            aux += "\(_ocean);"
        } else { aux += "();" }
        if let _postalCode = postalCode {
            aux += "\(_postalCode);"
        } else { aux += "();" }
        if let _subAdministrativeArea = subAdministrativeArea {
            aux += "\(_subAdministrativeArea);"
        } else { aux += "();" }
        if let _subLocality = subLocality {
            aux += "\(_subLocality);"
        } else { aux += "();" }
        if let _subThoroughfare = subThoroughfare {
            aux += "\(_subThoroughfare);"
        } else { aux += "();" }
        if let _thoroughfare = thoroughfare {
            aux += "\(_thoroughfare);"
        } else { aux += "();" }
        if let _location = location {
            aux += "\(_location.description);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }
}
