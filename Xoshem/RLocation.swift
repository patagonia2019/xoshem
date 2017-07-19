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
    var object : CLLocation?
    
    dynamic var altitude: Double = 0.0
    dynamic var floorLevel: Int = 0
    dynamic var horizontalAccuracy: Double = 0.0
    dynamic var isCurrent: Bool = false
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var name: String = ""
    dynamic var verticalAccuracy: Double = 0.0
    let placemarks = List<RPlacemark>()

}
