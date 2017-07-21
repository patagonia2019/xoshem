//
//  RWForecast.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift

public class StringObject: Object {
    public dynamic var value: String = ""
}

public class FloatObject: Object {
    dynamic var value: Float = 0.0
}

public class IntObject: Object {
    dynamic var value: Int = 0
}

public class DictObject: Object {
    dynamic var key: String = ""
    dynamic var value: String = ""
}

class RWForecast: Object {
    dynamic var initStamp   = 0  // initstamp
    let temperature         = List<FloatObject>() // TMP: temperature
    let cloudCoverTotal     = List<IntObject>() // TCDC: Cloud cover (%) Total
    let cloudCoverHigh      = List<IntObject>() // HCDC: Cloud cover (%) High
    let cloudCoverMid       = List<IntObject>() // MCDC: Cloud cover (%) Mid
    let cloudCoverLow       = List<IntObject>() // LCDC: Cloud cover (%) Low
    let relativeHumidity    = List<IntObject>() // RH: Relative humidity: relative humidity in percent
    let windGust            = List<FloatObject>() // GUST: Wind gusts (knots)
    let seaLevelPressure    = List<IntObject>() // SLP: sea level pressure
    let freezingLevel       = List<IntObject>() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    let precipitation       = List<IntObject>() //  APCP: Precip. (mm/3h)
    let windSpeed           = List<FloatObject>() //  WINDSPD: Wind speed (knots)
    let windDirection       = List<IntObject>() //  WINDDIR: Wind direction
    let SMERN               = List<IntObject>()
    let temperatureReal     = List<FloatObject>() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    let PCPT                = List<IntObject>()
    let hr_weekday          = List<IntObject>()
    let hr_h                = List<StringObject>()
    let hr_d                = List<StringObject>()
    let hours               = List<StringObject>()
    dynamic var initDate: Date = Date()
    dynamic var init_d: String = ""
    dynamic var init_dm: String = ""
    dynamic var init_h: String = ""
    dynamic var initstr: String = ""
    dynamic var model_name: String = ""
    dynamic var model_longname: String = ""
    dynamic var id_model: String = ""
    dynamic var update_last: Date = Date()
    dynamic var update_next: Date = Date()
    let img_param           = List<DictObject>()
    let img_var_map         = List<DictObject>()
}

