//
//  MasterViewController+UITable.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation

extension MasterViewController {
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menus = try! RMenu.fetchRoot() else { return 0 }
        return menus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Common.cell.identifier.root, for: indexPath)
        
        if let menus = try! RMenu.fetchRoot() {
            let menu = menus[indexPath.item]
            configureCell(cell, withMenu: menu)
        }
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, withMenu menu: RMenu) {
        cell.backgroundColor = UIColor.clear
        let name = menu.name
        if let textLabel = cell.textLabel {
            textLabel.font = UIFont.boldSystemFont(ofSize: 16)
            textLabel.text = name
        }
        let iconName = menu.iconName
        guard let fromFont = menu.iconFont,
            let cellImage = cell.imageView else {
                assertionFailure("need icon here for \(menu)")
                return
        }
        let size = CGSize(width: 50, height: 50)
        let fontSize :CGFloat = 40.0
        let icon = UIImage.icon(from: fromFont, iconColor: .white, code: iconName, imageSize: size, ofSize: fontSize)
        cellImage.image = icon
    }
    

}
