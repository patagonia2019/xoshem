//
//  CDManagedObject+CoreDataClass.swift
//  Xoshem
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData
import JFCore


public class CDManagedObject: NSManagedObject {    
    
    class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDManagedObject {
        assert(false)
        return CDManagedObject()
    }
    
    func create() {
        createdAt = NSDate()
    }
    
    func update() {
        updatedAt = NSDate()
    }
    
    class func createName(_ entityName: String, inManageContextObject mco: NSManagedObjectContext) -> CDManagedObject
    {
        return NSEntityDescription.insertNewObject(forEntityName: name(entityName), into: mco) as! CDManagedObject
    }
    
    class func name(_ entityName: String) -> String {
        if entityName.contains(".") {
            return entityName.components(separatedBy: ".")[1]
        }
        return entityName
    }
    
    class func searchEntityName(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, limit:Int, mco: NSManagedObjectContext)
        throws -> [AnyObject] {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name(entityName))
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
                
                array = try mco.fetch(fetchRequest)
            }
            catch {
                var reason = "Failed to fetch data from core data, check predicate \(String(describing: fetchRequest.predicate)) "
                reason += "fetchLimit \(fetchRequest.fetchLimit) "
                reason += "sortDescriptors \(String(describing: fetchRequest.sortDescriptors))"
                let myerror = JFError(code: Common.ErrorCode.cdFetchRequest.rawValue,
                                      desc: "\("Failed at fetch data from table".localized()) \(entityName)",
                    reason: reason,
                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                throw myerror
            }
            return array
    }
    
    
    class func importObject(wgObject: AnyObject?, mco: NSManagedObjectContext,
                            search:@escaping () throws -> [AnyObject]?,
                            update:@escaping (_ cdObject: CDManagedObject?) throws -> Bool,
                            create:@escaping () -> AnyObject?) throws -> CDManagedObject? {
        
        guard let wgObject = wgObject else {
            return nil
        }
        var cdObject: CDManagedObject?
        mco.performAndWait() {
            
            var array: [CDManagedObject]? = nil
            do {
                if let arrayFromSearch = try search() as? [CDManagedObject] {
                    array = arrayFromSearch
                }//as? [CDManagedObject]
            }
            catch {
                return
            }
            var brandNew = false
            if let array = array, array.count == 1 {
                if let first = array.first {
                    cdObject = first
                }
            }
            else {
                cdObject = create() as? CDManagedObject
                if let cdObject = cdObject {
                    brandNew = true
                    cdObject.create()
                }
            }
            
            do {
                if try update(cdObject),
                    let cdObject = cdObject {
                    if brandNew {
                        cdObject.updatedAt = cdObject.createdAt
                    }
                    else {
                        cdObject.update()
                    }
                }
            }
            catch {
                print("Error: \(error)\nCould not update from object: \(wgObject.description).")
                return
            }
        }
        
        return cdObject
    }
    
    override open var description : String {
        return "[\(String(describing: createdAt)),\(String(describing: updatedAt))]"
    }
    
}
