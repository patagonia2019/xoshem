//
//  MasterViewController.swift
//  md
//
//  Created by Javier Fuchs on 7/8/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SCLAlertView
import SwiftIconFont

class MasterViewController: BaseTableViewController {

    var detailViewController: DetailViewController? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = JFCore.Common.app
        if let split = splitViewController {
            let controllers = split.viewControllers
            let last = (controllers[controllers.count-1] as! UINavigationController)
            detailViewController = last.topViewController as? DetailViewController
        }
 
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        observeLocationServices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unobserveLocationServices()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
            let controller : DetailViewController
            if let dt = segue.destination as? UINavigationController {
                controller = dt.topViewController as! DetailViewController
            }
            else {
                controller = segue.destination as! DetailViewController
            }
            guard let menus = try! RMenu.fetchRoot() else { return }
            let menu = menus[indexPath.item]
            controller.detailItem = menu
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                splitViewController?.preferredDisplayMode = .automatic
            }
            else if splitViewController!.displayMode == .primaryOverlay {
                let animations : () -> Void = { [weak self] in
                    self?.splitViewController?.preferredDisplayMode = .primaryHidden
                }
                let completion : (Bool) -> Void = { [weak self] _ in
                    self?.splitViewController?.preferredDisplayMode = .automatic
                }
                UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
            }
        }
    }
    
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
    

    fileprivate func observeLocationServices()
    {
        unobserveLocationServices()

        let queue = OperationQueue.main
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationError), object: nil,
                                                                queue: queue) {
            note in if let object: Error = note.object as? Error {
                let alertView = SCLAlertView()
                alertView.addButton(Common.title.Cancel) { (isOtherButton) in
                    try! Facade.instance.stopLocation()
                }
                alertView.addButton(Common.title.Retry) { [weak self] (isOtherButton) in
                    if let strong = self {
                        strong.locationRestart()
                    }
                }
                alertView.showError(Common.title.Locationfailed, subTitle: object.localizedDescription)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationAuthorized), object: nil,
                                                                queue: queue) {
            (NSNotification) in
            if !JFCore.LocationManager.instance.isAuthorized() {
                SCLAlertView().showWarning(Common.title.LocationNotAuthorized, subTitle:"\(JFCore.Common.app)\(Common.title.PleaseAuthorize)")
            }
        }
    }
    
    fileprivate func locationRestart() {
        do {
            try Facade.instance.restartLocation()
        } catch {
            let e = error
            SCLAlertView().showError(Common.title.Servicesfailed, subTitle:e.localizedDescription)
        }
    }
    
    fileprivate func unobserveLocationServices()
    {
        for notification in [JFCore.Constants.Notification.locationError,
                             JFCore.Constants.Notification.locationAuthorized] {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }

}


