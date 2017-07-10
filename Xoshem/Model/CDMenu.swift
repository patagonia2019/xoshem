//
//  CDMenu.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/12/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import CoreData
import JFCore

class CDMenu: CDManagedObject {

    typealias CDAbstractType = CDMenu

    override class func createInManageContextObject(_ mco: NSManagedObjectContext) -> CDMenu {
        return super.createName(NSStringFromClass(self), inManageContextObject: mco) as! CDMenu
    }
    
    
    class func importArray(_ array: [[String: AnyObject]]?, mco: NSManagedObjectContext) throws -> Bool {
        /*
         Create a request to fetch existing menus with the same codes as those in
         the JSON data.
         
         Existing menus will be updated with new data; if there isn't a match, then
         create a new menu to represent the event.
         */
        guard let array = array else {
            return false
        }
        

        for menuDictionary in array {
            
            do {
                _ = try importObject(menuDictionary, mco: mco)
            }
            catch {
                let myerror = JFError(code: Common.ErrorCode.cdImportMenuArrayIssue.rawValue,
                                      desc: Common.title.errorOnImport,
                                      reason: "Failed to import array/dictionary into CDMenu",
                                      suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
            }
        }
        return true
        
    }
    
    
    class func importObject(_ object: [String: AnyObject]?, mco: NSManagedObjectContext) throws -> CDMenu? {
        
        guard let object = object else {
            return nil
        }
        
        let search = { () -> [AnyObject]? in
            guard let id = object["id"] as? Int,
                let parentId = object["parentId"] as? Int else {
                    return nil
            }
            let predicate = NSPredicate(format: "id = %d and parentId = %d", id, parentId)
            guard let array = try CDMenu.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                                    sortDescriptors: [], limit: 1,
                                                                    mco: mco) as? [CDMenu]
                else {
                    return nil
            }
            return array
            
        }
        
        let update = { (cdObject: CDManagedObject?) -> Bool in
            let obj = cdObject as! CDMenu
            let wgo = object
            return try obj.update(wgo)
        }
        let create = { () -> AnyObject? in
            return CDMenu.createInManageContextObject(mco)
        }
        
        return try CDMenu.importObject(wgObject: object as AnyObject, mco: mco, search: search,
                                       update: update, create: create) as? CDMenu
    }

    
    func update(_ dictionary: [String: AnyObject]?) throws -> Bool {
        // Only update the menu if all the relevant properties can be accessed.
        
        guard let dictionary = dictionary else {
            return false
        }

        guard let _id = dictionary["id"] as? Int,
            let _parentId = dictionary["parentId"] as? Int,
            let _name = dictionary["name"] as? String,
            let _edit = dictionary["edit"] as? Bool else {
                let myerror = JFError(code: Common.ErrorCode.cdUpdateMenuIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Failed to update CDMenu using dictionary object",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                throw myerror
        }
        if id == Int16(_id) &&
            parentId == Int16(_parentId) &&
            name == _name &&
            edit == _edit {
            return false
        }

        id = Int16(_id)
        parentId = Int16(_parentId)
        if let _file = dictionary["file"] as? String {
            file = _file
        }
        if let _segue = dictionary["segue"] as? String {
            segue = _segue
        }
        if let _iconList = dictionary["iconList"] as? String {
            iconList = _iconList
        }
        if let _iconName = dictionary["iconName"] as? String {
            iconName = _iconName
        }
        if let _requireLogin = dictionary["requireLogin"] as? Bool {
            requireLogin = _requireLogin
        }
        name = _name
        edit = _edit
        
        return true
    }
    
    class func search(_ id: Int, parentId: Int, mco: NSManagedObjectContext) throws -> [CDMenu] {
        let predicate = NSPredicate(format: "id = %d and parentId = %d", id, parentId)
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                    sortDescriptors: [], limit: 1, mco: mco) as! [CDMenu]
    }
    
    class func searchParentId(_ parentId: Int, mco: NSManagedObjectContext) throws -> [CDMenu] {
        let predicate = NSPredicate(format: "parentId = %d", parentId)
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: predicate,
                                                    sortDescriptors: sortDescriptors, limit: 0, mco: mco) as! [CDMenu]
    }

    class func fetch(_ mco: NSManagedObjectContext) throws -> [CDMenu] {
        return try CDManagedObject.searchEntityName(NSStringFromClass(self), predicate: nil,
                                                    sortDescriptors: [], limit: 0, mco: mco) as! [CDMenu]
    }

    class func fetchRootMenu(_ mco: NSManagedObjectContext) throws -> [CDMenu] {
        return try searchParentId(0, mco: mco)
    }

    class func fetchHelpMenu(_ mco: NSManagedObjectContext) throws -> [CDMenu] {
        return try searchParentId(4, mco: mco)
    }
    

    override var description : String {        
        var aux : String = "["
        aux += "\(parentId);"
        aux += "\(id);"
        if let _file = file {
            aux += "\(_file);"
        } else { aux += "();" }
        if let _segue = segue {
            aux += "\(_segue);"
        } else { aux += "();" }
        if let _iconList = iconList {
            aux += "\(_iconList);"
        } else { aux += "();" }
        if let _iconName = iconName {
            aux += "\(_iconName);"
        } else { aux += "();" }
        if let _name = name {
            aux += "\(_name);"
        } else { aux += "();" }
        aux += "\(edit);"
        aux += "\(requireLogin);"
        aux += "->\(super.description)"
        aux += "]"
        return aux
    }
}

