//
//  RWForecast+.swift
//  Xoshem
//
//  Created by javierfuchs on 7/21/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import JFWindguru

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
    
    func smern(hour: Int) -> Int? {
        if SMERN.count > 0 && hour < SMERN.count {
            return SMERN[hour].value
        }
        return nil
    }
    
    func smer(hour: Int) -> Int? {
        if SMER.count > 0 && hour < SMERN.count {
            return SMER[hour].value
        }
        return nil
    }

    private func windSpeed(hour: Int) -> Float? {
        if windSpeed.count > 0 && hour < windSpeed.count {
            return windSpeed[hour].value
        }
        return nil
    }
    
    func windSpeedKnots(hour: Int) -> Float? {
        return windSpeed(hour:hour)
    }

    func windSpeedKmh(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.kmh()
        }
        return nil
    }
    
    func windSpeedMph(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.mph()
        }
        return nil
    }

    func windSpeedMps(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.mps()
        }
        return nil
    }
    
    func windSpeedBft(hour: Int) -> Int? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.bft()
        }
        return nil
    }
    
    func windSpeedBftEffect(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.effect()
        }
        return nil
    }
    
    func windSpeedBftEffectOnSea(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.effectOnSea()
        }
        return nil
    }
    
    func windSpeedBftEffectOnLand(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = KnotsBeaufort.init(value: knots)
            return knotsBft.effectOnLand()
        }
        return nil
    }
    

    func windDirection(hour: Int) -> Int? {
        if windDirection.count > 0 && hour < windDirection.count {
            return windDirection[hour].value
        }
        return nil
    }
    
    // Thanks: https://www.campbellsci.com/blog/convert-wind-directions
    func windDirectionName(hour: Int) -> String? {
        let compass = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]
        if let direction = windDirection(hour: hour) {
            let module = Double(direction % 360)
            let index = Int(module / 22.5) + 1 // degrees for each sector
            if index >= 0 && index < compass.count {
                return compass[index]
            }
        }
        return nil
    }

    func windGust(hour: Int) -> Float? {
        if windGust.count > 0 && hour < windGust.count {
            return windGust[hour].value
        }
        return nil
    }
    
    func perpw(hour: Int) -> Float? {
        if PERPW.count > 0 && hour < PERPW.count {
            return PERPW[hour].value
        }
        return nil
    }

    func htsgw(hour: Int) -> Float? {
        if HTSGW.count > 0 && hour < HTSGW.count {
            return HTSGW[hour].value
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
    
    func pcpt(hour: Int) -> Int? {
        if PCPT.count > 0 && hour < PCPT.count {
            return PCPT[hour].value
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
