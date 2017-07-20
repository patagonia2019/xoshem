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
    
}
