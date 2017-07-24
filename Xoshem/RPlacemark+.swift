//
//  RPlacemark+.swift
//  Xoshem
//
//  Created by javierfuchs on 7/24/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

extension RPlacemark {
    func locationName() -> String {
        var fullName = ""
        if let string = name {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = locality {
            fullName += string + ", "
        } else if let string = subLocality {
            fullName += string + ", "
        }
        if let string = administrativeArea {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = subAdministrativeArea {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = inlandWater {
            if !fullName.contains(string) {
                fullName += string + ", "
            }
        }
        if let string = country {
            if !fullName.contains(string) {
                fullName += string
            }
        }
        
        return fullName

    }
}
