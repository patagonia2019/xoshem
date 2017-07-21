//
//  RWSpotResult.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift
import JFWindguru

class RSpotResult: Object {
    dynamic var count = 0
    let spots = List<RSpotOwner>()
    dynamic var selectedSpot: RSpotOwner?
  
    convenience public init(spotResult: SpotResult) {
        self.init()
        count = spotResult.count ?? 0
        if let array = spotResult.spots {
            for spot in array {
                spots.append(RSpotOwner.init(spotOwner: spot))
            }
        }
    }
}

