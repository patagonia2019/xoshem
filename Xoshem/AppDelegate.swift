//
//  AppDelegate.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/3/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var started: Bool = false

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        started = true
        try! Facade.instance.start()
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let vcs = splitViewController.viewControllers
        let navigationController = vcs.last as! UINavigationController
        if let top = navigationController.topViewController {
            top.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        }
        splitViewController.delegate = self
        
        if let bgImage = UIImage.init(named: Common.image.background) {
            splitViewController.view.backgroundColor = bgImage.patternColor(UIScreen.mainScreen().bounds.size)
        }
        
        Facade.instance.addSpinnerToView(splitViewController.view, translates: true)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        Facade.instance.stop()
        started = false
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if !started {
            try! Facade.instance.start()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController,
                             collapseSecondaryViewController secondaryViewController:UIViewController,
                                                             ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, showViewController vc: UIViewController,
                             sender: AnyObject?) -> Bool {
        return true
    }

    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController,
                             sender: AnyObject?) -> Bool {

        return false
    }

    func splitViewController(svc: UISplitViewController, willChangeToDisplayMode
        displayMode: UISplitViewControllerDisplayMode)
    {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.editing, object: false)
        })
    }

}

