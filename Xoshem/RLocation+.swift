//
//  RLocation+.swift
//  Xoshem
//
//  Created by javierfuchs on 10/22/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import JFCore

extension RLocation {
    
    func searchPlacemarks(completion: @escaping ((Bool) -> Swift.Void))
    {
        LocationManager.instance.reverseLocation(location: coreLocation,
                                                 didFailWithError: { _ in
                                                    completion(false)
        },
                                                 didUpdatePlacemarks: {
                                                    [weak self]
                                                    (placemarkCores) in
                                                    for pl in placemarkCores {
                                                        let placemark = RPlacemark.init(placemark: pl)
                                                        self?.placemarks.append(placemark)
                                                    }
                                                    self?.selectedPlacemark = self?.placemarks.first
                                                    self?.selectedPlacemark?.searchSpots(completion: completion)
        })
        
    }

}
