//
//  HelpViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/11/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SwiftIconFont

class HelpViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var currentMenuOption : RMenu?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menus = try! RMenu.fetchHelp() else { return 0 }
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Common.cell.identifier.help, for: indexPath)
        if let menus = try! RMenu.fetchHelp() {
            let menu = menus[indexPath.item]
            configureCell(cell, withMenu: menu)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menus = try! RMenu.fetchHelp() else { return }
        let menu = menus[indexPath.item]
        performSegue(withIdentifier: menu.segue, sender: self)
    }
    
    func configureCell(_ cell: UITableViewCell, withMenu menu: RMenu) {
        cell.backgroundColor = UIColor.clear
        let name = menu.name
        if let textLabel = cell.textLabel {
            textLabel.text = name
            textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        }
        let iconName = menu.iconName
        guard let fromFont = menu.iconFont,
            let cellImage = cell.imageView
             else {
                assertionFailure("need icon here for \(menu)")
            return
        }
        let size = CGSize(width: 50, height: 50)
        let fontSize :CGFloat = 40.0
        let icon = UIImage.icon(from: fromFont, iconColor: .white, code: iconName, imageSize: size, ofSize: fontSize)
        cellImage.image = icon
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let menu = currentMenuOption else { return }
        if segue.identifier == Common.segue.web {
            if let web = segue.destination as? WebViewController {
                web.title = menu.name
                web.fileName = menu.file
            }
        }
        else if segue.identifier == Common.segue.about {
            if let about = segue.destination as? AboutViewController {
                about.title = menu.name
                about.fileName = menu.file
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }

}
