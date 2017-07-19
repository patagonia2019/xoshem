//
//  RPlacemark.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RPlacemark: Object {
    var object : CLPlacemark?
    
    dynamic var administrativeArea: String = ""
    dynamic var areasOfInterest: String = ""
    dynamic var country: String = ""
    dynamic var inlandWater: String = ""
    dynamic var isoCountryCode: String = ""
    dynamic var locality: String = ""
    dynamic var name: String = ""
    dynamic var ocean: String = ""
    dynamic var postalCode: String = ""
    dynamic var subAdministrativeArea: String = ""
    dynamic var subLocality: String = ""
    dynamic var subThoroughfare: String = ""
    dynamic var thoroughfare: String = ""
    let forecastResults = List<RWSpotForecast>()
    dynamic var location: RLocation? // to-one relationships must be optional
}
