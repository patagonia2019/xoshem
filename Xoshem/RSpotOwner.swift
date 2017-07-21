//
//  RWSpotOwner.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RSpotOwner: RSpot {
    dynamic var id_user: Int = 0

    convenience public init(spotOwner: SpotOwner) {
        let spot = spotOwner as Spot
        self.init(spot: spot)
        id_user = spotOwner.id_user ?? 0
    }
}

