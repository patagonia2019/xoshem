//
//  MasterViewController.swift
//  md
//
//  Created by Javier Fuchs on 7/8/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import SwiftIconFont
import SwiftSpinner

class MasterViewController: BaseTableViewController {

    var detailViewController: DetailViewController? = nil
    var errorized : Bool! = false
    var usingSpinner: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = JFCore.Common.app
        if let split = splitViewController {
            let controllers = split.viewControllers
            let last = (controllers[controllers.count-1] as! UINavigationController)
            detailViewController = last.topViewController as? DetailViewController
        }
//        tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .bottom)
//        performSegue(withIdentifier: "showDetail", sender: self)
        startSpinner()
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
            guard let menus = Facade.instance.fetchRoot() else { return }
            let menu = menus[indexPath.item]
            controller.detailItem = menu
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftBarButtonItem?.tintColor = .white
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
    

    fileprivate func observeLocationServices()
    {
        unobserveLocationServices()

        let queue = OperationQueue.main
        
        NotificationCenter.default.addObserver(forName: RequestDidStartNotification, object: nil, queue: queue)
        { note in
            DispatchQueue.main.async() { [unowned self] in
                self.showSpinner()
            }
        }

        NotificationCenter.default.addObserver(forName: RequestDidStopNotification, object: nil, queue: queue)
        { note in
            DispatchQueue.main.async() { [unowned self] in
                self.hideSpinner()
            }
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationError), object: nil, queue: queue)
            {
                note in
                JFCore.Common.synchronized {
                    [weak self] in
                    if (self?.errorized)! {
                        return
                    }
                    self?.errorized = true
                    
                    if let object: Error = note.object as? Error {
//                        let alertView = SCLAlertView()
//                        alertView.addButton(Common.title.Cancel) { (isOtherButton) in
//                            try! Facade.instance.stopLocation()
//                        }
//                        alertView.addButton(Common.title.Retry) { [weak self] (isOtherButton) in
//                            if let strong = self {
//                                strong.locationRestart()
//                            }
//                        }
//                        alertView.showError(Common.title.Locationfailed, subTitle: object.localizedDescription).setDismissBlock {
//                            self?.errorized = false
//                        }
                        
                    }
                }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationAuthorized), object: nil,
                                               queue: queue)
            {
                (note) in
                JFCore.Common.synchronized {
                    [weak self] in
                    if (self?.errorized)! {
                        return
                    }
                    self?.errorized = true
                    if !JFCore.LocationManager.instance.isAuthorized() {
//                        SCLAlertView().showWarning(Common.title.LocationNotAuthorized,
//                                                   subTitle:"\(JFCore.Common.app)\(Common.title.PleaseAuthorize)").setDismissBlock { [weak self] in
//                                                    self?.errorized = false
//                        }

                    }
                }
        }

        NotificationCenter.default.addObserver(forName: FacadeDidErrorNotification, object: nil,
                                                                queue: queue)
            {
                (note) in
                JFCore.Common.synchronized {
                    [weak self] in
                    if (self?.errorized)! {
                        return
                    }
                    self?.errorized = true
//                    let alertView = SCLAlertView()
//                    if let object: JFError = note.object as? JFError {
//                        alertView.showError(object.title(), subTitle: object.debugDescription).setDismissBlock {
//                            self?.errorized = false
//                        }
//                    }
//                    else if let object = note.object as? Error {
//                        alertView.showError(Common.title.error, subTitle: object.localizedDescription).setDismissBlock {
//                            self?.errorized = false
//                        }
//                    }
                }
        }
    }
    
    fileprivate func locationRestart() {
        do {
            try Facade.instance.restartLocation()
        } catch {
            let e = error
//            SCLAlertView().showError(Common.title.Servicesfailed, subTitle:e.localizedDescription)
        }
    }
    
    fileprivate func unobserveLocationServices()
    {
        for notification in [JFCore.Constants.Notification.locationError,
                             JFCore.Constants.Notification.locationAuthorized,
                             FacadeDidErrorNotification.rawValue,
                             RequestDidStartNotification.rawValue,
                             RequestDidStopNotification.rawValue] {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    
    func startSpinner() {
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 10))
        SwiftSpinner.useContainerView(view)
        showSpinner()
    }
    
    func showSpinner() {
        if !usingSpinner {
            usingSpinner = true
            SwiftSpinner.show("Sunshine is delicious, rain is refreshing, wind braces us up, snow is exhilarating; there is really no such thing as bad weather, only different kinds of good weather. ~John Ruskin")
        }
    }
    
    func hideSpinner() {
        usingSpinner = false
        SwiftSpinner.hide()
    }

}


