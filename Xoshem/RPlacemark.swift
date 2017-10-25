//
//  RPlacemark.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import JFWindguru
import CoreLocation

class RPlacemark {
   
    var corePlacemark : CLPlacemark!
    var spotResults = [SpotResult]()
    var selectedSpot: SpotResult? = nil
    var spotForecast: WSpotForecast? = nil
    
    public init(placemark: CLPlacemark) {
        corePlacemark = placemark
    }
    
}
