//
//  RSpotForecast.swift
//  Xoshem
//
//  Created by javierfuchs on 7/18/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RWSpotForecast: Object {
    var object : WSpotForecast?
    dynamic var id_spot = 0
    dynamic var id_user = 0
    dynamic var spotname: String?
    dynamic var spot: String?
    dynamic var lat: Float = 0.0
    dynamic var lon: Float = 0.0
    dynamic var alt = 0
    dynamic var id_model: String?
    dynamic var model: String?
    dynamic var model_alt = 0
    dynamic var levels = 0
    dynamic var sst: String?
    dynamic var sunrise: String?
    dynamic var sunset: String?
    dynamic var tz: String?
    dynamic var tzutc: String?
    dynamic var utc_offset = 0
    dynamic var tzid: String?
    dynamic var tides = 0
    dynamic var md5chk: String?
    dynamic var fcst: RWForecast?
    dynamic var wgs = false
    let wgs_arr = List<RWindguruStation>()
    dynamic var wgs_wind_avg = 0
}

