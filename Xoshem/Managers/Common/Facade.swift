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
import RealmSwift

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
    fileprivate var locations = [CLLocation]()
    fileprivate var started : Bool = false
    fileprivate var onProcessing : Bool = false
    fileprivate var auth: Auth!
    fileprivate static var firstTime: Bool = true
    open var lastRefreshDate : Date?

    open static let instance = Facade()

    //
    // initialization
    //
    fileprivate override init() {
        super.init()
        Crash.start()
        auth = Auth()
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
            if (Facade.firstTime) {
                try! RMenu.removeAll()
                Facade.firstTime = false
            }
        #endif
            Analytics.start()
        #if os(watchOS)
            print("TARGET_OS_WATCH")
        #else
            if (TARGET_OS_SIMULATOR == 1) {
                print("TARGET_OS_SIMULATOR")
                Analytics.logFunction(function: #function,
                                      parameters: ["line": "\(#line)" as AnyObject,
                                                   "device": "simulator" as AnyObject])
            }
            else {
                Analytics.logFunction(function: #function,
                                      parameters: ["line": "\(#line)" as AnyObject,
                                                   "device": "real device" as AnyObject])
            }
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
        
            CoreDataManager.instance.save()
            self?.started = false
        })
    }
    
    
    func updateLocations(usingDiscoveredLocations currentLocations: [CLLocation]) throws {
        JFCore.Common.synchronized(syncBlock: { [weak self] in

            do {
                guard let locations = try self?.fetchLocation() else {
                    return
                }
                
                var change = true
                
                mainFor: for locationA in locations {
                    for locationB in currentLocations {
                        if locationB.altitude == locationA.altitude &&
                            locationB.coordinate.latitude == locationA.latitude &&
                            locationB.coordinate.longitude == locationA.longitude {
                            change = false
                            break mainFor
                        }
                    }
                }
                if change {
                    let realm = try Realm()
                    try realm.write() {
                        for corelocation in currentLocations {
                            let rlocation = RLocation(location: corelocation)
                            realm.add(rlocation)
                            self?.createPlacemark(withLocation: corelocation, rlocation: rlocation)
                        }
                    }
                }
            }
            catch {
                let myerror = JFError(code: Common.ErrorCode.fetchLocationIssue.rawValue,
                    desc: Common.title.errorOnSearch,
                    reason: "Error on search / delete location",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                Analytics.logFatal(error: myerror)
                myerror.fatal()
            }
        })
    }
    
    func createPlacemark(withLocation location: CLLocation, rlocation: RLocation) {
        LocationManager.instance.reverseLocation(location: location,
            didFailWithError:{_ in },
            didUpdatePlacemarks: {
                (placemarks) in
                do {
                    let realm = try Realm()
                    try realm.write() {
                        for corePlacemark in placemarks {
                            let rplacemark = RPlacemark(placemark: corePlacemark, rlocation: rlocation)
                            realm.add(rplacemark)
                        }
                    }
                }
                catch {
                    let myerror = JFError(code: Common.ErrorCode.cdUpdateLocationIssue.rawValue,
                                          desc: Common.title.errorOnUpdate,
                                          reason: "Error on Location/Placemarks import",
                                          suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                    Analytics.logFatal(error: myerror)
                    myerror.fatal()
                }
        })

    }
    


    fileprivate func observeNotifications()
    {
        unobserveNotifications()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationUpdated), object: nil, queue: OperationQueue.main) {
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
    // MARK: - Core Data stack
 
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.fuchs.mater-detail.md" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    

    func fetchLocation() throws -> Results<RLocation>? {
        do {
            let realm = try Realm()
            return realm.objects(RLocation.self)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchLocationIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Location",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
    func forecastUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Common.notification.forecast.updated), object: nil)
    }
    
    func locationSaved() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Common.notification.location.saved), object: nil)
    }
    
    
}
