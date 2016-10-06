//
//  HelpViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/11/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import CoreData
import JFCore
import SwiftIconFont

class HelpViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var currentMenuOption : CDMenu?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Facade.instance.fetchHelpMenu().count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Common.cell.identifier.help, forIndexPath: indexPath)
        let menu = Facade.instance.fetchHelpMenu()[indexPath.row]
        self.configureCell(cell, withMenu: menu)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentMenuOption = Facade.instance.fetchHelpMenu()[indexPath.row]
        guard let menu = self.currentMenuOption,
                  segue = menu.segue else { return }
        self.performSegueWithIdentifier(segue, sender: self)
    }
    
    func configureCell(cell: UITableViewCell, withMenu menu: CDMenu) {
        cell.backgroundColor = UIColor.clearColor()
        if let name = menu.name,
            let textLabel = cell.textLabel {
            textLabel.text = name
            textLabel.font = UIFont.boldSystemFontOfSize(16)
        }
        guard let fromFont = menu.iconFont,
            iconName = menu.iconName,
            cellImage = cell.imageView,
            icon = UIImage.iconToImage(fromFont, iconCode: iconName, imageSize: CGSizeMake(50, 50), fontSize: 40) else {
                assertionFailure("need icon here for \(menu)")
            return
        }
        cellImage.image = icon.convertColor(UIColor.whiteColor())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let menu = self.currentMenuOption else { return }
        if segue.identifier == Common.segue.web {
            if let web = segue.destinationViewController as? WebViewController {
                web.title = menu.name
                web.fileName = menu.file
            }
        }
        else if segue.identifier == Common.segue.about {
            if let about = segue.destinationViewController as? AboutViewController {
                about.title = menu.name
                about.fileName = menu.file
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }

}
