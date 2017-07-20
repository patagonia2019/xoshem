//
//  RLocation.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RLocation: Object {

    convenience public init(location: CLLocation) {
        self.init()
        altitude = location.altitude
        if let floor = location.floor {
            floorLevel = floor.level
        }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
    }

    dynamic var altitude: Double = 0.0
    dynamic var floorLevel: Int = 0
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var horizontalAccuracy: Double = 0.0
    dynamic var verticalAccuracy: Double = 0.0
    let placemarks = List<RPlacemark>()
}
