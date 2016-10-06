//
//  ExtensionDelegate.swift
//  Xoshem-watch WatchKit Extension
//
//  Created by Javier Fuchs on 10/3/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import WatchKit
import JFCore

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        do {
            try Facade.instance.start()
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.AppDidBecomeActiveError.rawValue,
                                desc: "Failed at start of services",
                                reason: "Error on did become active",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            print(myerror)
        }
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
        Facade.instance.stop()
        
    }
    
}
