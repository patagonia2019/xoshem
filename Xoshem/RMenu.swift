//
//  RMenu.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import RealmSwift

class RMenu: Object {
    dynamic var edit: Bool = false
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var segue: String = ""
    dynamic var iconList: String = ""
    dynamic var iconName: String = ""
    dynamic var parentId: Int = 0
    dynamic var requireLogin: Bool = false
    dynamic var file: String = ""
}
