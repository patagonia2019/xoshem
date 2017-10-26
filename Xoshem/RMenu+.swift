//
//  RMenu+SwiftIconFont.swift
//  Xoshem
//
//  Created by Javier Fuchs on 10/3/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import SwiftIconFont
import JFCore

extension RMenu {
    
    var iconFont: Fonts? {
        switch iconList {
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
    
    
    static func parseJSON(_ json: [[String : Any?]]?) -> [RMenu] {
        var array = [RMenu]()
        for dict in json ?? [[:]] {
            let id = dict["id"] as? Int ?? 0
            let parentId = dict["parentId"] as? Int ?? 0
            let requireLogin = dict["requireLogin"] as? Bool ?? false
            let name = dict["name"] as? String ?? ""
            let segue = dict["segue"] as? String ?? ""
            let iconList = dict["iconList"] as? String ?? ""
            let iconName = dict["iconName"] as? String ?? ""
            let file = dict["file"] as? String ?? ""
            var submenu : [RMenu]? = nil
            if let menuArray = dict["menu"] as? [[String : Any?]] {
                submenu = parseJSON(menuArray)
            }
            array.append(RMenu(edit: false, id: id, name: name.localized(), segue: segue, iconList: iconList, iconName: iconName, parentId: parentId, requireLogin: requireLogin, file: file, submenu: submenu))
        }
        return array
    }
    


}
