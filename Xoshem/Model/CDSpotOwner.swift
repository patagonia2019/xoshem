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

    override class func createInManageContextObject(mco: NSManagedObjectContext) -> CDSpotOwner {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDSpotOwner
    }
    
    func update(spotOwner: SpotOwner) throws -> Bool {
        
        var ret = try super.update(spotOwner as Spot)
        guard let
            _nickname = spotOwner.nickname as String?,
            _userId = spotOwner.userId as Int? else {
                let myerror = Error(code: Common.ErrorCode.CDUpdateSpotsOwnersIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed at import spotOwner boject into SpotOwner",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if nickname == _nickname && userId == Int16(_userId) {
            ret = false
        }
        else {
            nickname = _nickname
            userId = Int16(_userId)
            ret = ret && true
        }
        return ret
    }
    
    class func importObject(object: SpotOwner, mco: NSManagedObjectContext) throws -> CDSpotOwner {
        return try CDSpotOwner.importObject(object, mco: mco,
                                       search: {
                                        (wgObject, mco) -> [AnyObject] in
                                        let predicate = NSPredicate(format: "identity = %@", object.identity!)
                                        return try CDSpotOwner.searchEntityName(NSStringFromClass(self), predicate: predicate, sortDescriptors: [], limit: 1, mco: mco) as! [CDSpotOwner]
            },
                                       update: {
                                        (cdObject, wgObject, mco) -> Bool in
                                        return try (cdObject as! CDSpotOwner).update(wgObject as! SpotOwner)
            },
                                       create: { (mco) -> AnyObject in
                                        return CDSpotOwner.createInManageContextObject(mco)
        }) as! CDSpotOwner
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
