//
//  RLocation.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import CoreLocation

class RLocation {
    let coreLocation : CLLocation!
    var placemarks = [RPlacemark]()
    var selectedPlacemark: RPlacemark? = nil
    
    public init(location: CLLocation) {
        coreLocation = location
    }
}
