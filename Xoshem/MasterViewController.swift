//
//  MasterViewController.swift
//  md
//
//  Created by Javier Fuchs on 7/8/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import CoreData
import JFCore
import SCLAlertView
import SwiftIconFont

class MasterViewController: BaseTableViewController {

    var detailViewController: DetailViewController? = nil

    
    override func viewDidLoad() {
        self.title = ""
        super.viewDidLoad()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let last = (controllers[controllers.count-1] as! UINavigationController)
            self.detailViewController = last.topViewController as? DetailViewController
        }
 
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.observeLocationServices()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unobserveLocationServices()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            let controller : DetailViewController
            if let dt = segue.destinationViewController as? UINavigationController {
                controller = dt.topViewController as! DetailViewController
            }
            else {
                controller = segue.destinationViewController as! DetailViewController
            }
            let object = Facade.instance.fetchRootMenu()[indexPath.row] as CDMenu
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.splitViewController?.preferredDisplayMode = .Automatic
            }
            else if self.splitViewController!.displayMode == .PrimaryOverlay {
                let animations : () -> Void = {
                    self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                }
                let completion : Bool -> Void = { _ in
                    self.splitViewController?.preferredDisplayMode = .Automatic
                }
                UIView.animateWithDuration(0.3, animations: animations, completion: completion)
            }
        }
    }
    
    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Facade.instance.fetchRootMenu().count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Common.cell.identifier.root, forIndexPath: indexPath)
        let menu = Facade.instance.fetchRootMenu()[indexPath.row] as CDMenu
        self.configureCell(cell, withMenu: menu)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, withMenu menu: CDMenu) {
        cell.backgroundColor = UIColor.clearColor()
        if let name = menu.name,
           let textLabel = cell.textLabel {
            textLabel.font = UIFont.boldSystemFontOfSize(16)
            textLabel.text = name
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
    

    private func observeLocationServices()
    {
        self.unobserveLocationServices()

        let queue = NSOperationQueue.mainQueue()
        
        NSNotificationCenter.defaultCenter().addObserverForName(JFCore.Constants.Notification.locationError, object: nil,
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
                alertView.showError(Common.title.Locationfailed, subTitle: object.description)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(JFCore.Constants.Notification.locationAuthorized, object: nil,
                                                                queue: queue) {
            (NSNotification) in
            if !JFCore.LocationManager.instance.isAuthorized() {
                SCLAlertView().showWarning(Common.title.LocationNotAuthorized, subTitle:"\(JFCore.Common.app)\(Common.title.PleaseAuthorize)")
            }
        }
    }
    
    private func locationRestart() {
        do {
            try Facade.instance.restartLocation()
        } catch {
            if let e = error as? Error {
                SCLAlertView().showError(Common.title.Servicesfailed, subTitle:e.description)
            }
        }
    }
    
    private func unobserveLocationServices()
    {
        for notification in [JFCore.Constants.Notification.locationError,
                             JFCore.Constants.Notification.locationAuthorized] {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }

}


