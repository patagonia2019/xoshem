//
//  CDManagedObject+CoreDataProperties.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/9/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import CoreData


extension CDManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDManagedObject> {
        return NSFetchRequest<CDManagedObject>(entityName: "CDManagedObject")
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?

}
