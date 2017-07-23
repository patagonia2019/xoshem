//
//  RWSpotForecast+.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

extension RWSpotForecast {
    
    func locationName() -> String? {
        guard let windguruStation = wgs_arr.first
            else { return nil }
        return windguruStation.station
    }
    
    func spotName() -> String {
        if let locationName = locationName() {
            return locationName
        }
        if let spot = spot {
            return spot
        }
        if let spotname = spotname {
            return spotname
        }
        if let nickname = nickname {
            return nickname
        }
        if let tzid = tzid {
            return tzid
        }
        return "Spot id: \(id_spot)"
    }
    
}
