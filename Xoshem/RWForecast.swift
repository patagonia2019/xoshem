//
//  RWForecast.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

public class StringObject: Object {
    dynamic var value: String = ""
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
    
    convenience public init(forecast: WForecast) {
        self.init()
        initStamp = forecast.initStamp ?? 0
        if let temp = forecast.temperature {
            for f in temp { temperature.append(FloatObject(value: [f])) }
        }
        if let cct = forecast.cloudCoverTotal {
            for i in cct { cloudCoverTotal.append(IntObject(value: [i])) }
        }
        if let cch = forecast.cloudCoverHigh {
            for i in cch { cloudCoverHigh.append(IntObject(value: [i])) }
        }
        if let ccm = forecast.cloudCoverMid {
            for i in ccm { cloudCoverMid.append(IntObject(value: [i])) }
        }
        if let ccl = forecast.cloudCoverLow {
            for i in ccl { cloudCoverLow.append(IntObject(value: [i])) }
        }
        if let rh = forecast.relativeHumidity {
            for i in rh { relativeHumidity.append(IntObject(value: [i])) }
        }
        if let wg = forecast.windGust {
            for f in wg { windGust.append(FloatObject(value: [f])) }
        }
        if let slp = forecast.seaLevelPressure {
            for i in slp { seaLevelPressure.append(IntObject(value: [i])) }
        }
        if let fl = forecast.freezingLevel {
            for i in fl { freezingLevel.append(IntObject(value: [i])) }
        }
        if let ppt = forecast.precipitation {
            for i in ppt { precipitation.append(IntObject(value: [i])) }
        }
        if let ws = forecast.windSpeed {
            for f in ws { windSpeed.append(FloatObject(value: [f])) }
        }
        if let wd = forecast.windDirection {
            for i in wd { windDirection.append(IntObject(value: [i])) }
        }
        if let smern = forecast.SMERN {
            for i in smern { SMERN.append(IntObject(value: [i])) }
        }
        if let tr = forecast.temperatureReal {
            for f in tr { temperatureReal.append(FloatObject(value: [f])) }
        }
        if let pcpt = forecast.PCPT {
            for i in pcpt { PCPT.append(IntObject(value: [i])) }
        }
        if let hrw = forecast.hr_weekday {
            for i in hrw { hr_weekday.append(IntObject(value: [i])) }
        }
        if let hrh = forecast.hr_h {
            for s in hrh { hr_h.append(StringObject(value: [s])) }
        }
        if let hrd = forecast.hr_d {
            for s in hrd { hr_d.append(StringObject(value: [s])) }
        }
        if let hrs = forecast.hours {
            for s in hrs { hours.append(StringObject(value: [s])) }
        }
        initDate = forecast.initDate ?? Date()
        init_d = forecast.init_d ?? ""
        init_dm = forecast.init_dm ?? ""
        init_h = forecast.init_h ?? ""
        initstr = forecast.initstr ?? ""
        model_name = forecast.model_name ?? ""
        model_longname = forecast.model_longname ?? ""
        id_model = forecast.id_model ?? ""
        update_last = forecast.update_last ?? Date()
        update_next = forecast.update_next ?? Date()
    }
}

