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
    

    func searchSpots() {
        let array = nameArray()
        searchSpots(array: array)
    }


    private func searchSpots(array: [String]) {
        var array = array
        if array.count > 0 {
            let name = array.removeFirst()
            searchSpot(withName: name,
                failure: {
                    [weak self] (error) in
                    self?.searchSpots(array: array)
                },
                success: {
                    [weak self] (spotResult) in
                    guard let spotResult = spotResult else {
                        self?.searchSpots(array: array)
                        return
                    }
                    self?.spotResults.append(spotResult)
                    let spot = spotResult.firstSpot()
                    spot?.updateForecast()
                }
            )
        }
    }
    
    func searchSpot(withName name: String,
                    failure:@escaping (_ error: JFError?) -> Void,
                    success:@escaping (_ spotResult: SpotResult?) -> Void) {
        ForecastWindguruService.instance.searchSpots(byLocation: name,
            failure: { (error) in
                if let nserror = error?.nserror {
                    let myerror = JFError.init(code: nserror.code, desc: nserror.localizedDescription, reason: nserror.localizedFailureReason, suggestion: nserror.localizedRecoverySuggestion, path: "\(#file)", line: "\(#line)", underError: nserror)
                    failure(myerror)
                }
                else {
                    failure(nil)
                }
            },
            success: {
                (spotResult) in
                guard let spotResult = spotResult,
                    spotResult.numberOfSpots() > 0 else {
                        let myerror = JFError.init(code: 999, desc: "No posts to update", path: "\(#file)", line: "\(#line)", underError: nil)
                        failure(myerror)
                        return
                }
                success(spotResult)
            }
        )
    }
}
