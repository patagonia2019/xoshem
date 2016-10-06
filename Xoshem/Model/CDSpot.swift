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

    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDSpot {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDSpot
    }

    func update(spot: Spot) throws -> Bool {

        var ret = super.update()
        guard let
            _identity = spot.identity
            else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateSpotIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDSpot using Spot object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if identity == _identity {
            ret = false
        }
        else {
            identity = _identity
            if let _country = spot.country {
                country = _country
            }
            if let _name = spot.name {
                name = _name
            }
            ret = ret && true
        }
        return ret
    }

    class func importObject(object: Spot, mco: NSManagedObjectContext) throws -> CDSpot {
        return try CDSpot.importObject(object, mco: mco,
        search: {
            (wgObject, mco) -> [AnyObject] in
            let predicate = NSPredicate(format: "identity = %@", object.identity!)
            return try CDSpot.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDSpot]
        },
        update: {
            (cdObject, wgObject, mco) -> Bool in
            return try (cdObject as! CDSpot).update(wgObject as! Spot)
        },
        create: { (mco) -> AnyObject in
            return CDSpot.createInManageContextObject(mco)
        }) as! CDSpot
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
