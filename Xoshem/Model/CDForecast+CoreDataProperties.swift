//
//  CDForecast+CoreDataProperties.swift
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

extension CDForecast {

    @NSManaged var initDate: NSTimeInterval
    @NSManaged var initStamp: Int64
    @NSManaged var modelName: String?
    @NSManaged var forecastModel: CDForecastModel?
    @NSManaged var timeWeathers: NSSet?

}
