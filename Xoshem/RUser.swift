//
//  RUser.swift
//  Xoshem
//
//  Created by javierfuchs on 7/24/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RUser: Object {

    dynamic var id_user: Int = 0
    dynamic var username: String? = nil
    dynamic var id_country: Int = 0
    dynamic var wind_units: String? = nil
    dynamic var temp_units: String? = nil
    dynamic var wave_units: String? = nil
    dynamic var pro: Int = 0
    dynamic var no_ads: Int = 0
    dynamic var view_hours_from: Int = 0
    dynamic var view_hours_to: Int = 0
    dynamic var temp_limit: Int = 0
    let wind_rating_limits = List<FloatObject>()

    convenience public init(user: User) {
        self.init()

        id_user = user.id_user ?? 0
        username = user.username
        id_country = user.id_country ?? 0
        wind_units = user.wind_units
        temp_units = user.temp_units
        wave_units = user.wave_units
        pro = user.pro ?? 0
        no_ads = user.no_ads ?? 0
        view_hours_from = user.view_hours_from ?? 0
        view_hours_to = user.view_hours_to ?? 0
        temp_limit = user.temp_limit ?? 0
        if let wrl = user.wind_rating_limits {
            for f in wrl { wind_rating_limits.append(FloatObject(value: [f])) }
        }
    }
}
