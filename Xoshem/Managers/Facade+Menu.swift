//
//  Facade+Menu.swift
//  Xoshem
//
//  Created by javierfuchs on 10/23/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

extension Facade {
    #if os(watchOS)
    #else
    
    func createMenu() {
        menuArray.removeAll()
        guard let menu = menu() else {
            return
        }
        menuArray = RMenu.parseJSON(menu)
    }
    
    func fetchRoot() -> Array<RMenu>? {
        return menuArray
    }
    
    func fetchHelp() -> Array<RMenu>? {
        guard let help = menuArray.filter({ (menu) -> Bool in
            return menu.name == "\(Common.title.Help)"
        }).first else {
            return nil
        }
        return help.submenu
    }
    
    #endif
    
    public func menu() ->  [[String : Any?]]? {
        guard let info = info else {
            return nil
        }
        return info["menu"] as? [[String : Any?]]
    }

}
