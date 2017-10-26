//
//  Facade.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore
import JFWindguru

/*
 *  Facade
 *
 *  Discussion:
 *    Manager of synchronization between the watch/iphone/ipad it shares plist files using a common group.
 *    It is subscribed to notifications of the LocationManager to update the plist file with the new location/country.
 */

open class Facade: NSObject {
    //
    // Attributes only modified by this class
    //
    var locations = [RLocation]()
    var menuArray = [RMenu]()
    fileprivate var started : Bool = false
    var onProcessing : Bool = false {
        willSet {
            if newValue == true {
                requestDidStartNotification(object: nil)
            }
            else {
                requestDidStopNotification(object: nil)
            }
        }
    }
    fileprivate static var firstTime: Bool = true
    open var lastRefreshDate : Date?

    open static let instance = Facade()
    

    //
    // initialization
    //
    fileprivate override init() {
        super.init()
        Crash.start()
    }
    
    open func restart() throws {
        stop()
        try! start()
    }
    
    

    open func restartLocation() throws {
        JFCore.Common.synchronized(syncBlock: {
            LocationManager.instance.stop()

            LocationManager.instance.start()
        })
    }
    
    open func stopLocation() throws {
        JFCore.Common.synchronized(syncBlock: {
            LocationManager.instance.stop()
        })
    }
    
    
    //
    // start service manager
    //
    open func start() throws
    {
        JFCore.Common.synchronized(syncBlock: { [weak self] in
            if let started = self?.started, started == true {
                return
            }

            self?.started = true

        #if os(watchOS)
        #else
            HockeyAppManager.instance.configure()
        #endif
            
            self?.observeNotifications()
            
        #if os(watchOS)
        #else
            if (Facade.firstTime && self?.menuArray.count == 0) {
                self?.createMenu()
                Facade.firstTime = false
            }
        #endif
            Analytics.start()
        #if os(watchOS)
            print("TARGET_OS_WATCH")
        #else
            Analytics.logFunction(function: #function,
                                  parameters: ["line": "\(#line)" as AnyObject,
                                               "device": ((TARGET_OS_SIMULATOR == 1) ? "simulator" : "realdevice") as AnyObject])
        #endif

            LocationManager.instance.start()
        })
    }
    
    //
    // stop service manager
    //
    open func stop()
    {
        JFCore.Common.synchronized(syncBlock: { [weak self] in
            Analytics.stop()
            LocationManager.instance.stop()
            
            self?.unobserveNotifications()
        
            self?.started = false
        })
    }
        
    func forecastDidUpdateNotification(object: Any?) {
        NotificationCenter.default.post(name: ForecastDidUpdateNotification, object: object)
    }
    
    func locationDidUpdateNotification(object: Any?) {
        NotificationCenter.default.post(name: LocationDidUpdateNotification, object: object)
    }
    
    func requestDidStartNotification(object: Any?) {
        NotificationCenter.default.post(name: RequestDidStartNotification, object: object)
    }
    
    func requestDidStopNotification(object: Any?) {
        NotificationCenter.default.post(name: RequestDidStopNotification, object: object)
    }

    func facadeDidErrorNotification(object: Any?) {
        NotificationCenter.default.post(name: FacadeDidErrorNotification, object: object)
    }

    fileprivate func observeNotifications()
    {
        unobserveNotifications()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationUpdated), object: nil, queue: OperationQueue.main)
        {
            [weak self]
            (NSNotification) in
            if !LocationManager.instance.isRunning() {
                return
            }
            guard let locations = LocationManager.instance.locations else {
                return
            }
            if let onProcessing = self?.onProcessing, onProcessing == true {
                return
            }
            try! self?.updateLocations(usingDiscoveredLocations: locations)
        }
        
    }
    
    fileprivate func unobserveNotifications()
    {
        for notification in [JFCore.Constants.Notification.locationUpdated, JFCore.Constants.Notification.locationError, JFCore.Constants.Notification.locationAuthorized] {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }
    public lazy var info : [String : AnyObject]? = {
        guard let appDict = Bundle.main.infoDictionary,
            let bundleName = appDict["CFBundleName"] as? String,
            let path = Bundle.main.path(forResource: bundleName, ofType: "plist"),
            let dict = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dict
    }()
    

}
