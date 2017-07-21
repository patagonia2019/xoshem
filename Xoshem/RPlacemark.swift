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
    
    dynamic var administrativeArea: String = ""
    let areasOfInterest = List<StringObject>()
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
    let spotResults = List<RSpotResult>()
    dynamic var selectedSpot: RSpotResult?
    dynamic var spotForecast: RWSpotForecast?
    
    convenience public init(placemark: CLPlacemark) {
        self.init()
        administrativeArea = placemark.administrativeArea ?? ""
        if let areas = placemark.areasOfInterest {
            for area in areas { areasOfInterest.append(StringObject(value: [area])) }
        }
        country = placemark.country ?? ""
        inlandWater = placemark.inlandWater ?? ""
        isoCountryCode = placemark.isoCountryCode ?? ""
        locality = placemark.locality ?? ""
        name = placemark.name ?? ""
        ocean = placemark.ocean ?? ""
        postalCode = placemark.postalCode ?? ""
        subAdministrativeArea = placemark.subAdministrativeArea ?? ""
        subLocality = placemark.subLocality ?? ""
        subThoroughfare = placemark.subThoroughfare ?? ""
        thoroughfare = placemark.thoroughfare ?? ""
    }
    
}
