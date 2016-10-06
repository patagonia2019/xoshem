//
//  CDManagedObject.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFCore

protocol WGGenericProtocol {
    associatedtype WGAbstractType
    associatedtype CDAbstractType
    func update(wgObject: WGAbstractType) throws -> Bool
    static func createInManageContextObject(mco: NSManagedObjectContext) -> CDAbstractType
    static func importObject(wgObject: WGAbstractType, mco: NSManagedObjectContext,
                            search:(wgObject: WGAbstractType, mco: NSManagedObjectContext) throws -> [AnyObject],
                            update:(cdObject: CDAbstractType, wgObject: WGAbstractType, mco: NSManagedObjectContext) throws -> Bool,
                            create:(mco: NSManagedObjectContext) -> AnyObject) throws -> CDAbstractType
    static func searchEntityName(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit:Int, mco: NSManagedObjectContext) throws -> [AnyObject]
}

class CDManagedObject: NSManagedObject, WGGenericProtocol {
    
    typealias WGAbstractType = AnyObject
    typealias CDAbstractType = CDManagedObject
    
    
    func update(wgObject: WGAbstractType) throws -> Bool {
        timeStamp = NSDate().timeIntervalSince1970
        return true
    }
    
    class func createInManageContextObject(mco: NSManagedObjectContext) -> CDAbstractType {
        assert(false)
        return CDAbstractType()
    }
    
    class func createName(entityName: String, inManageContextObject mco: NSManagedObjectContext) -> CDManagedObject
    {
        return NSEntityDescription.insertNewObjectForEntityForName(name(entityName), inManagedObjectContext: mco) as! CDManagedObject
    }

    class func name(entityName: String) -> String {
        if entityName.containsString(".") {
            return entityName.componentsSeparatedByString(".")[1]
        }
        return entityName
    }
    
    class func searchEntityName(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit:Int, mco: NSManagedObjectContext)
        throws -> [AnyObject] {
            let fetchRequest = NSFetchRequest(entityName: name(entityName))
            var array = [AnyObject]()
            do {
                if let apredicate = predicate {
                    fetchRequest.predicate = apredicate
                }
                if limit > 0 {
                    fetchRequest.fetchLimit = limit
                }
                
                if let sortD = sortDescriptors {
                    fetchRequest.sortDescriptors = sortD
                }
                
                array = try mco.executeFetchRequest(fetchRequest)
            }
            catch {
                let myerror = Error(code: Common.ErrorCode.CDFetchRequest.rawValue,
                                    desc: "\("Failed at fetch data from table".Localized()) \(entityName)",
                                    reason: "Failed to fetch data from core data, check predicate \(fetchRequest.predicate) " +
                                    "fetchLimit \(fetchRequest.fetchLimit) " +
                                    "sortDescriptors \(fetchRequest.sortDescriptors)",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                throw myerror
            }
            return array
    }
    

    func update() -> Bool {
        timeStamp = NSDate().timeIntervalSince1970
        return true
    }
    
    class func importObject(wgObject: WGAbstractType, mco: NSManagedObjectContext,
                            search:(wgObject: WGAbstractType, mco: NSManagedObjectContext) throws -> [AnyObject],
                            update:(cdObject: CDAbstractType, wgObject: WGAbstractType, mco: NSManagedObjectContext) throws -> Bool,
                            create:(mco: NSManagedObjectContext) -> AnyObject) throws -> CDAbstractType {
        
        var cdObject: CDAbstractType?
        mco.performBlockAndWait() {
            
            let array: [CDAbstractType]
            
            do {
                array = try search(wgObject: wgObject, mco: mco) as! [CDAbstractType]
            }
            catch {
                return
            }
            
            if array.count == 1 {
                cdObject = array.first!
            }
            else {
                cdObject = create(mco: mco) as? CDAbstractType
            }
            
            do {
                try update(cdObject: cdObject!, wgObject: wgObject, mco: mco)
            }
            catch {
                print("Error: \(error)\nCould not update from object: \(wgObject.description).")
                return
            }
        }
        
        return cdObject!
    }
    
    override var description : String {
        return "[\(timeStamp):\(self.dynamicType)]"
    }

}
