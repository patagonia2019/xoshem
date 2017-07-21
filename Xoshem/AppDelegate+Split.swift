//
//  AppDelegate+Split.swift
//  Xoshem
//
//  Created by javierfuchs on 7/20/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import UIKit
import JFCore

extension AppDelegate: UISplitViewControllerDelegate {

    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController,
                             sender: Any?) -> Bool {
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController,
                             sender: Any?) -> Bool {
        
        return false
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo
        displayMode: UISplitViewControllerDisplayMode)
    {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            NotificationCenter.default.post(name: EditDidReceiveNotification, object: false)
        })
    }
    
    
    func configureSplitView() -> Bool {
        // Override point for customization after application launch.
        guard let window = window else {
            return false
        }
        let splitViewController = window.rootViewController as! UISplitViewController
        let vcs = splitViewController.viewControllers
        if let navigationController = vcs.last as? UINavigationController,
            let top = navigationController.topViewController {
            top.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        }
        splitViewController.delegate = self
        
        if let bgImage = UIImage.init(named: Common.image.background) {
            splitViewController.view.backgroundColor = bgImage.patternColor(customSize: UIScreen.main.bounds.size)
        }
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        return true
    }
    
}
