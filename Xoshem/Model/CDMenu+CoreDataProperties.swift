//
//  CDMenu+CoreDataProperties.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/2/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDMenu {

    @NSManaged var edit: Bool
    @NSManaged var id: Int16
    @NSManaged var name: String?
    @NSManaged var segue: String?
    @NSManaged var iconList: String?
    @NSManaged var iconName: String?
    @NSManaged var parentId: Int16
    @NSManaged var requireLogin: Bool
    @NSManaged var file: String?
}
