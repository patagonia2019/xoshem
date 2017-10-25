//
//  RMenu.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

struct RMenu {
    var edit: Bool = false
    var id: Int = 0
    var name: String = ""
    var segue: String = ""
    var iconList: String = ""
    var iconName: String = ""
    var parentId: Int = 0
    var requireLogin: Bool = false
    var file: String = ""
    var submenu : [RMenu]?
}
