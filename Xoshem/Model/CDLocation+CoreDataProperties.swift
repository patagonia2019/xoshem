//
//  CDLocation+CoreDataProperties.swift
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

extension CDLocation {

    @NSManaged var altitude: Double
    @NSManaged var floorLevel: Int16
    @NSManaged var horizontalAccuracy: Double
    @NSManaged var isCurrent: Bool
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String?
    @NSManaged var verticalAccuracy: Double
    @NSManaged var placemarks: NSSet?

}
