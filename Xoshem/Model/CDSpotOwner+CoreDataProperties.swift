//
//  CDSpotOwner+CoreDataProperties.swift
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

extension CDSpotOwner {

    @NSManaged var spotname: String?
    @NSManaged var userId: Int16
    @NSManaged var forecastResult: CDForecastResult?

}
