//
//  RWSpot.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RSpot: Object {
    dynamic var id_spot: String = ""
    dynamic var spotname: String = ""
    dynamic var country: String = ""

    convenience public init(spot: Spot) {
        self.init()
        id_spot = spot.id_spot ?? ""
        spotname = spot.spotname ?? ""
        country = spot.country ?? ""
    }
}
