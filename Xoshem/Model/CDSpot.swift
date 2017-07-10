//
//  CDSpot.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFWindguru
import JFCore

class CDSpot: CDManagedObject {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDSpot {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDSpot
    }
    
    
    class func importObject(_ object: Spot?, mco: NSManagedObjectContext) throws -> CDSpot? {
        
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            guard let identity = object.identity else {
                    return nil
            }
            let predicate = NSPredicate(format: "identity = %@", identity)
            guard let array = try CDSpot.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                          sortDescriptors: [], limit: 1,
                                                          mco: mco) as? [CDSpot]
                else {
                    return nil
            }
            return array
            
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDSpot
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDSpot.createInManageContextObject(mco)
        }
        
        return try CDSpot.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                       update: update, create: create) as? CDSpot
    }

    func update(_ spot: Spot?) throws -> Bool {

        guard let spot = spot else {
            return false
        }

        guard let
            _identity = spot.identity
            else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateSpotIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDSpot using Spot object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if identity == _identity {
            return false
        }

        identity = _identity
        if let _country = spot.country {
            country = _country
        }
        if let _name = spot.name {
            name = _name
        }
        
        return false
    }
    
    func namecheck() -> String? {
        var aux : String = ""
        if let _name = name {
            aux = "\(_name)"
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
        if let _country = country {
            aux += "\(_country);"
        } else { aux += "();" }
        if let _identity = identity {
            aux += "\(_identity);"
        } else { aux += "();" }
        if let _name = name {
            aux += "\(_name);"
        } else { aux += "();" }
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }


}
