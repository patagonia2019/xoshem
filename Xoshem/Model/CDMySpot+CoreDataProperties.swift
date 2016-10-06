//
//  CDMySpot+CoreDataProperties.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/24/16.
//  Copyright © 2016 Fuchs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDMySpot {

    @NSManaged var isCurrent: Bool
    @NSManaged var isLoading: Bool
    @NSManaged var code: Int32
    @NSManaged var temperature: String?
    @NSManaged var model: String?
    @NSManaged var locations: NSSet?

}
