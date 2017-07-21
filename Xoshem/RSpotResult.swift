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
    dynamic var spot : RSpotOwner?
    
    convenience public init(spotResult: SpotResult) {
        self.init()
        count = spotResult.count ?? 0
        if let spots = spotResult.spots,
            let first = spots.first {
            spot = RSpotOwner.init(spotOwner: first)
        }        
    }
}

