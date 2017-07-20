//
//  AppDelegate.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/3/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var started: Bool = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        started = true
        try! Facade.instance.start()

        return configureSplitView()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        Facade.instance.stop()
        started = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if !started {
            try! Facade.instance.start()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

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
            NotificationCenter.default.post(name: Notification.Name(rawValue: Common.notification.editing), object: false)
        })
    }

    
    private func configureSplitView() -> Bool {
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
        
        return true
    }

}

