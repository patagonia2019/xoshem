//
//  RWindguruStation.swift
//  Xoshem
//
//  Created by javierfuchs on 7/19/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RWindguruStation : Object {
    dynamic var id: String = ""
    dynamic var station: String = ""
    dynamic var distance: Int = 0
    dynamic var id_type: String = ""
    dynamic var wind_avg: Int = 0

    convenience public init(windguruStation: WindguruStation) {
        self.init()
        id = windguruStation.id ?? ""
        station = windguruStation.station ?? ""
        distance = windguruStation.distance ?? 0
        id_type = windguruStation.id_type ?? ""
        wind_avg = windguruStation.wind_avg ?? 0
    }
}

