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
    var object : WindguruStation?
    dynamic var id: String = ""
    dynamic var station: String = ""
    dynamic var distance: Int = 0
    dynamic var id_type: String = ""
    dynamic var wind_avg: Int = 0
}

