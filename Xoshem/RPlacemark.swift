//
//  RPlacemark.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru
import CoreLocation

class RPlacemark: Object {
    
    dynamic var administrativeArea: String? = nil
    let areasOfInterest = List<StringObject>()
    dynamic var country: String? = nil
    dynamic var inlandWater: String? = nil
    dynamic var isoCountryCode: String? = nil
    dynamic var locality: String? = nil
    dynamic var name: String? = nil
    dynamic var ocean: String? = nil
    dynamic var postalCode: String? = nil
    dynamic var subAdministrativeArea: String? = nil
    dynamic var subLocality: String? = nil
    dynamic var subThoroughfare: String? = nil
    dynamic var thoroughfare: String? = nil
    let spotResults = List<SpotResult>()
    dynamic var selectedSpot: SpotResult?
    dynamic var spotForecast: WSpotForecast?
    
    convenience public init(placemark: CLPlacemark) {
        self.init()
        administrativeArea = placemark.administrativeArea
        if let areas = placemark.areasOfInterest {
            for area in areas { areasOfInterest.append(StringObject(value: [area])) }
        }
        country = placemark.country
        inlandWater = placemark.inlandWater
        isoCountryCode = placemark.isoCountryCode
        locality = placemark.locality
        name = placemark.name
        ocean = placemark.ocean
        postalCode = placemark.postalCode
        subAdministrativeArea = placemark.subAdministrativeArea
        subLocality = placemark.subLocality
        subThoroughfare = placemark.subThoroughfare
        thoroughfare = placemark.thoroughfare
    }
    
}
