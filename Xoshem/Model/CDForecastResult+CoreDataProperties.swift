//
//  CDForecastResult+CoreDataProperties.swift
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

extension CDForecastResult {

    @NSManaged var altitude: Int16
    @NSManaged var countryId: Int16
    @NSManaged var currentModel: String?
    @NSManaged var gmtHourOffset: Int16
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var sunrise: String?
    @NSManaged var sunset: String?
    @NSManaged var tides: String?
    @NSManaged var timezone: String?
    @NSManaged var hide: Bool
    @NSManaged var forecastModels: NSSet?
    @NSManaged var placemarkResult: CDPlacemark?
    @NSManaged var spotOwner: CDSpotOwner?

}
