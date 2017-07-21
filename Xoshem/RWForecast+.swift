//
//  RWForecast+.swift
//  Xoshem
//
//  Created by javierfuchs on 7/21/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
//#if os(watchOS)
// let h3 = hour3()
// let t = fcst.temperature[h3].value
// let t = fcst.temperature[h3].value
// appendFd("behance-heeyeun-jeong-85", key: "Temperature", value: "\(t) °C")
// let tr = fcst.temperatureReal[h3].value
// appendFd("behance-heeyeun-jeong-86", key: "Temperature Real", value: "\(tr) °C")
// let rh = fcst.relativeHumidity[h3].value
// appendFd("behance-heeyeun-jeong-12", key: "Relative humidity", value: "\(rh) %")
// let speed = fcst.windSpeed[h3].value
// appendFd("behance-heeyeun-jeong-9", key: "Wind Speed", value: "\(speed) knots")
// let gust = fcst.windGust[h3].value
// appendFd("behance-heeyeun-jeong-13", key: "Wind Gusts", value: "\(gust) knots")
// let cct = fcst.cloudCoverTotal[h3].value
// appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Total", value: "\(cct) %")
// let cch = fcst.cloudCoverHigh[h3].value
// appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover High", value: "\(cch) %")
// let ccm = fcst.cloudCoverMid[h3].value
// appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Mid", value: "\(ccm) %")
// let ccl = fcst.cloudCoverLow[h3].value
// appendFd("behance-heeyeun-jeong-7", key: "Cloud Cover Low", value: "\(ccl) %")
// let ppt = fcst.precipitation[h3].value
// appendFd("behance-heeyeun-jeong-23", key: "Precipitation", value: "\(ppt) mm/3h")
// let slp = fcst.seaLevelPressure[h3].value
// appendFd("behance-heeyeun-jeong-54", key: "Sea Level Pressure", value: "\(slp)")
// let fl = fcst.freezingLevel[h3].value
//#endif

extension RWForecast {
    
    func temperature(hour: Int) -> Float? {
        if temperature.count > 0 && hour < temperature.count {
            return temperature[hour].value
        }
        return nil
    }

    func temperatureReal(hour: Int) -> Float? {
        if temperatureReal.count > 0 && hour < temperatureReal.count {
            return temperatureReal[hour].value
        }
        return nil
    }

    func relativeHumidity(hour: Int) -> Int? {
        if relativeHumidity.count > 0 && hour < relativeHumidity.count {
            return relativeHumidity[hour].value
        }
        return nil
    }

    func windSpeed(hour: Int) -> Float? {
        if windSpeed.count > 0 && hour < windSpeed.count {
            return windSpeed[hour].value
        }
        return nil
    }

    func windGust(hour: Int) -> Float? {
        if windGust.count > 0 && hour < windGust.count {
            return windGust[hour].value
        }
        return nil
    }
    
    func cloudCoverTotal(hour: Int) -> Int? {
        if cloudCoverTotal.count > 0 && hour < cloudCoverTotal.count {
            return cloudCoverTotal[hour].value
        }
        return nil
    }
    
    func cloudCoverHigh(hour: Int) -> Int? {
        if cloudCoverHigh.count > 0 && hour < cloudCoverHigh.count {
            return cloudCoverHigh[hour].value
        }
        return nil
    }

    func cloudCoverMid(hour: Int) -> Int? {
        if cloudCoverMid.count > 0 && hour < cloudCoverMid.count {
            return cloudCoverMid[hour].value
        }
        return nil
    }

    func cloudCoverLow(hour: Int) -> Int? {
        if cloudCoverLow.count > 0 && hour < cloudCoverLow.count {
            return cloudCoverLow[hour].value
        }
        return nil
    }
    
    func precipitation(hour: Int) -> Int? {
        if precipitation.count > 0 && hour < precipitation.count {
            return precipitation[hour].value
        }
        return nil
    }
    
    func seaLevelPressure(hour: Int) -> Int? {
        if seaLevelPressure.count > 0 && hour < seaLevelPressure.count {
            return seaLevelPressure[hour].value
        }
        return nil
    }

    func freezingLevel(hour: Int) -> Int? {
        if freezingLevel.count > 0 && hour < freezingLevel.count {
            return freezingLevel[hour].value
        }
        return nil
    }
}
