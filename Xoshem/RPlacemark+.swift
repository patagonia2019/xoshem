//
//  RPlacemark+.swift
//  Xoshem
//
//  Created by javierfuchs on 7/24/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import JFCore
import JFWindguru

extension RPlacemark {
    func locationName() -> String {
        var fullName = ""
        if let string = corePlacemark.name {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = corePlacemark.locality {
            fullName += string + ", "
        } else if let string = corePlacemark.subLocality {
            fullName += string + ", "
        }
        if let string = corePlacemark.administrativeArea {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = corePlacemark.subAdministrativeArea {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = corePlacemark.inlandWater {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = corePlacemark.country {
            if !fullName.contains(string) {
                fullName += string
            }
        }
        
        return fullName

    }
    
    func nameArray() -> [String] {
        
        var array = [String]() // TODO: remove repeated
        
        if let string = corePlacemark.subLocality {
            array.append(string)
        }
        if let string = corePlacemark.locality {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = corePlacemark.administrativeArea {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = corePlacemark.subAdministrativeArea {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = corePlacemark.name {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = corePlacemark.inlandWater {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = corePlacemark.country {
            if !array.contains(string) {
                array.append(string)
            }
        }
        
        return array
    }
    

    func searchSpots(completion: @escaping ((Bool) -> Swift.Void)) {
        let array = nameArray()
        searchSpots(array: array, completion: completion)
    }


    private func searchSpots(array: [String], completion: @escaping ((Bool) -> Swift.Void)) {
        var array = array
        if array.count > 0 {
            let name = array.removeFirst()
            ForecastWindguruService.instance.searchSpots(byLocation: name,
                failure: {
                    [weak self] (error) in
                    self?.searchSpots(array: array, completion: completion)
                },
                success: {
                    [weak self] (spotResult) in
                    guard let spotResult = spotResult,
                          let spot = spotResult.firstSpot(),
                          let spotId = spot.id() else {
                        self?.searchSpots(array: array, completion: completion)
                        return
                    }
                    self?.spotResults.append(spotResult)
                    ForecastWindguruService.instance.wforecast(bySpotId: spotId, failure: {_ in },
                        success: {
                            [weak self] (wspotforecast) in
                            self?.wspotForecast = wspotforecast
                            completion(true)
                        }
                    )
                }
            )
        }
    }
    
}
