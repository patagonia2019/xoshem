//
//  Facade+Location.swift
//  Xoshem
//
//  Created by javierfuchs on 10/22/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import JFCore
import CoreLocation

extension Facade {
    func updateLocations(usingDiscoveredLocations currentLocations: [CLLocation]) throws {
        JFCore.Common.synchronized(syncBlock: { [weak self] in
            self?.onProcessing = true
            var change = true
            
            if let locations = self?.locations {
                locationCycle: for locationA in locations {
                    for locationB in currentLocations {
                        if locationB.altitude == locationA.coreLocation.altitude &&
                            locationB.coordinate.latitude == locationA.coreLocation.coordinate.latitude &&
                            locationB.coordinate.longitude == locationA.coreLocation.coordinate.longitude
                        {
                            change = false
                            break locationCycle
                        }
                    }
                }
            }
            if change {
                self?.locations.removeAll()
                for corelocation in currentLocations {
                    let location = RLocation.init(location: corelocation)
                    location.searchPlacemarks(completion: { [weak self] (succeed) in
                        if (succeed) {
                            self?.locations.append(location)
                        }
                        else {
                        }
                        self?.onProcessing = false
                        self?.forecastDidUpdateNotification(object: location)
                    })
                }
            }
        })
    }
    

    func hasCurrentLocalForecast() -> Bool {
        if self.locations.count > 0 {
            return true
        }
        return false
    }
}
