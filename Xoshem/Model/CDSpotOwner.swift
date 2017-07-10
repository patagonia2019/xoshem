//
//  CDSpotOwner.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/17/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFWindguru
import JFCore

/*    @NSManaged var nickname: String?
 @NSManaged var userId: Int16
 
 var nickname: String?
 var userId: Int?

*/
class CDSpotOwner: CDSpot {

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDSpotOwner {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDSpotOwner
    }
    
    
    
    class func importObject(_ object: SpotOwner?, mco: NSManagedObjectContext) throws -> CDSpotOwner? {
        
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            guard let identity = object.identity else {
                return nil
            }
            let predicate = NSPredicate(format: "identity = %@", identity)
            guard let array = try CDSpotOwner.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                               sortDescriptors: [], limit: 1,
                                                               mco: mco) as? [CDSpotOwner]
                else {
                    return nil
            }
            return array
            
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDSpotOwner
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDSpotOwner.createInManageContextObject(mco)
        }
        
        return try CDSpotOwner.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                            update: update, create: create) as? CDSpotOwner
    }
    
    
    func update(_ spotOwner: SpotOwner?) throws -> Bool {
        
        guard let object = spotOwner,
            let spot = spotOwner else {
            return false
        }
        
        if try super.update(spot) == false {
            return false
        }
        
        guard let
            _nickname = object.nickname as String?,
            let _userId = object.userId as Int? else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateSpotsOwnersIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed at import spotOwner boject into SpotOwner",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if nickname == _nickname && userId == Int16(_userId) {
            return false
        }

        nickname = _nickname
        userId = Int16(_userId)
        return true
    }
    
    
    override var description : String {
        var aux : String = "["
        if let _nickname = nickname {
            aux += "\(_nickname);"
        } else { aux += "();" }
        aux += "\(userId);"
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }

}
