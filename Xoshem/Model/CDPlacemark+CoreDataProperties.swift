//
//  CDPlacemark+CoreDataProperties.swift
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

extension CDPlacemark {

    @NSManaged var administrativeArea: String?
    @NSManaged var areasOfInterest: String?
    @NSManaged var country: String?
    @NSManaged var inlandWater: String?
    @NSManaged var isoCountryCode: String?
    @NSManaged var locality: String?
    @NSManaged var name: String?
    @NSManaged var ocean: String?
    @NSManaged var postalCode: String?
    @NSManaged var subAdministrativeArea: String?
    @NSManaged var subLocality: String?
    @NSManaged var subThoroughfare: String?
    @NSManaged var thoroughfare: String?
    @NSManaged var forecastResults: NSSet?
    @NSManaged var location: CDLocation?

}
