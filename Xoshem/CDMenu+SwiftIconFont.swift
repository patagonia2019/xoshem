//
//  CDMenu+SwiftIconFont.swift
//  Xoshem
//
//  Created by Javier Fuchs on 10/3/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import SwiftIconFont

extension CDMenu {
    var iconFont: Fonts? {
        guard let il = iconList else {
            assertionFailure("icon list does not exist for \(self)")
            return nil
        }
        switch il {
        case "FontAwesome":
            return .FontAwesome
        case "open-iconic":
            return .Iconic
        case "Ionicons":
            return .Ionicon
        case "octicons":
            return .Octicon
        case "themify":
            return .Themify
        case "map-icons":
            return .MapIcon
        case "MaterialIcons-Regular":
            return .MaterialIcon
        default:
            return nil
        }
    }
}
