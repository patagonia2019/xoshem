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
        if let info = Bundle.main.infoDictionary,
            let schemaVersion = info["CFBundleShortVersionString"] as? Int
        {
            let version = UInt64(schemaVersion)
            let config = Realm.Configuration(
                schemaVersion: version,
                migrationBlock: { migration, oldSchemaVersion in
                    if (oldSchemaVersion < 1) {
                    }
            })
            Realm.Configuration.defaultConfiguration = config
        }

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
                do {
                    try RMenu.removeAll()
                }
                catch {
                    self?.facadeDidErrorNotification(object: error)
                    return
                }

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
        
            self?.started = false
        })
    }
    
    
    func updateLocations(usingDiscoveredLocations currentLocations: [CLLocation]) throws {
        JFCore.Common.synchronized(syncBlock: { [weak self] in
            do {
                self?.onProcessing = true
                let realm = try Realm()
                let locations = realm.objects(RLocation.self)
                
                var change = true
                
                mainFor: for locationA in locations {
                    for locationB in currentLocations {
                        if let placemark = locationA.placemarks.last,
                            placemark.spotForecast != nil &&
                            locationB.altitude == locationA.altitude &&
                            locationB.coordinate.latitude == locationA.latitude &&
                            locationB.coordinate.longitude == locationA.longitude
                        {
                            change = false
                            break mainFor
                        }
                    }
                }
                if change {
                    try realm.write() {
                        for location in locations {
                            for placemark in location.placemarks {
                                if let spotForecast = placemark.spotForecast {
                                    realm.delete(spotForecast)
                                }
//                                if let selectedSpot = placemark.selectedSpot {
//                                    realm.delete(selectedSpot)
//                                }
//                                realm.delete(placemark.spotResults)
                            }
                            realm.delete(location.placemarks)
                        }
                        realm.delete(locations)
                        for corelocation in currentLocations {
                            let rlocation = RLocation(location: corelocation)
                            realm.add(rlocation)
                            self?.createPlacemark(withLocation: corelocation, rlocation: rlocation)
                        }
                    }
                }
                else {
                    self?.onProcessing = false
                }
            }
            catch {
                self?.onProcessing = false
                let myerror = JFError(code: Common.ErrorCode.fetchLocationIssue.rawValue,
                    desc: Common.title.errorOnSearch,
                    reason: "Error on search / delete location",
                    suggestion: "\(#function)", path: "\(#file)", line: "\(#line)", underError: error as? NSError)
                Analytics.logFatal(error: myerror)
                myerror.fatal()
            }
        })
    }
    
    func createPlacemark(withLocation location: CLLocation, rlocation: RLocation) {
        LocationManager.instance.reverseLocation(location: location,
            didFailWithError:{ [weak self] (error) in
                self?.onProcessing = false
                self?.facadeDidErrorNotification(object: error)
            },
            didUpdatePlacemarks: {
                [weak self]
                (placemarks) in
                do {
                    let realm = try Realm()
                    try realm.write() {
                        for corePlacemark in placemarks {
                            let rplacemark = RPlacemark(placemark: corePlacemark)
                            realm.add(rplacemark)
                            rlocation.placemarks.append(rplacemark)
                        }
                        self?.updateSpotsUsingPlacemarks()
                    }
                }
                catch {
                    let myerror = JFError(code: Common.ErrorCode.cdUpdateLocationIssue.rawValue,
                                          desc: Common.title.errorOnUpdate,
                                          reason: "Error on Location/Placemarks import",
                                          suggestion: "\(#function)", path: "\(#file)", line: "\(#line)", underError: error as NSError)
                    Analytics.logFatal(error: myerror)
                    self?.onProcessing = false
                    self?.facadeDidErrorNotification(object: myerror)
                    myerror.fatal()
                }
        })

    }
    

    func updateSpotsUsingPlacemarks() {
        let realm = try! Realm()
        let placemarks = realm.objects(RPlacemark.self)
        for placemark in placemarks {
            let array = createNameArray(withPlacemark: placemark)
            updateSpots(usingPlacemark: placemark, array: array)
        }
    }
    
    func updateSpots(usingPlacemark placemark: RPlacemark, array: [String]) {
        var array = array
        var lastError : JFError? = nil
        if array.count > 0 {
            let name = array.removeFirst()
            updateSpotsTrying(withName: name, failure: {
                [weak self] (error) in
                lastError = error
                self?.updateSpots(usingPlacemark: placemark, array: array)
            }, success: {
                [weak self] (spotResult) in
                guard let spotResult = spotResult else {
                    self?.updateSpots(usingPlacemark: placemark, array: array)
                    return
                }
                let realm = try! Realm()
                let placemarks = realm.objects(RPlacemark.self)
                try! realm.write {
                    let rspotresult = RSpotResult(spotResult: spotResult)
                    realm.add(rspotresult)
                    placemark.spotResults.append(rspotresult)
                    if placemarks.last == placemark {
                        self?.updateForecastUsingFirstPlacemarkSpot()
                   }
                }
            })
        }
        else {
            onProcessing = false
            facadeDidErrorNotification(object: lastError)
        }
    }
    
    func createNameArray(withPlacemark placemark: RPlacemark) -> [String] {
        
        var array = [String]() // TODO: remove repeated
        
        if let string = placemark.subLocality {
            array.append(string)
        }
        if let string = placemark.locality {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = placemark.administrativeArea {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = placemark.subAdministrativeArea {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = placemark.name {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = placemark.inlandWater {
            if !array.contains(string) {
                array.append(string)
            }
        }
        if let string = placemark.country {
            if !array.contains(string) {
                array.append(string)
            }
        }
        
        return array
    }
    

    
    func updateSpotsTrying(withName name: String,
                           failure:@escaping (_ error: JFError?) -> Void,
                           success:@escaping (_ spotResult: SpotResult?) -> Void) {
        ForecastWindguruService.instance.searchSpots(byLocation: name, failure: { (error) in
            if let nserror = error?.nserror {
                let myerror = JFError.init(code: nserror.code, desc: nserror.localizedDescription, reason: nserror.localizedFailureReason, suggestion: nserror.localizedRecoverySuggestion, path: "\(#file)", line: "\(#line)", underError: nserror)
                failure(myerror)
            }
            else {
                failure(nil)
            }
        }, success: {
            (spotResult) in
            guard let spotResult = spotResult,
                let spots = spotResult.spots,
                spots.count > 0 else {
                    let myerror = JFError.init(code: 999, desc: "No posts to update", path: "\(#file)", line: "\(#line)", underError: nil)
                    failure(myerror)
                    return
            }
            success(spotResult)
        })
    }
    
    func updateForecastUsingFirstPlacemarkSpot() {
        
        let realm = try! Realm()
        let placemarks = realm.objects(RPlacemark.self)
        for placemark in placemarks {
            if let spotResult = placemark.spotResults.first,
                let spotOwner = spotResult.spots.first {
                ForecastWindguruService.instance.wforecast(bySpotId: spotOwner.id_spot, failure:
                {
                    [weak self]
                    (error) in
                    self?.onProcessing = false
                    self?.facadeDidErrorNotification(object: error)
                }, success: {
                    [weak self]
                    (spotForecast) in
                    guard let spotForecast = spotForecast else {
                        self?.onProcessing = false
                        let myerror = JFError(code: Common.ErrorCode.cdUpdateForecastIssue.rawValue,
                                              desc: Common.title.errorOnUpdate,
                                              reason: "Error on update forecast",
                                              suggestion: "\(#function)", path: "\(#file)", line: "\(#line)")
                        self?.facadeDidErrorNotification(object: myerror)
                        return
                    }
                    try! realm.write {
                        let rwspotforecast = RWSpotForecast(spotForecast: spotForecast)
                        realm.add(rwspotforecast)
                        placemark.spotForecast = rwspotforecast
                        if placemarks.last == placemark {
                            self?.forecastDidUpdateNotification(object: realm.objects(RWSpotForecast.self).last)
                            self?.onProcessing = false
                        }
                    }
                })
            }
        }
    }
    

    func fetchLocation() throws -> Results<RLocation>? {
        do {
            let realm = try Realm()
            return realm.objects(RLocation.self)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchLocationIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Location",
                                suggestion: "\(#function)", path: "\(#file)", line: "\(#line)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
    func forecastDidUpdateNotification(object: Any?) {
        NotificationCenter.default.post(name: ForecastDidUpdateNotification, object: object)
    }
    
    func locationDidUpdateNotification(object: Any?) {
        NotificationCenter.default.post(name: LocationDidUpdateNotification, object: object)
    }

    func facadeDidErrorNotification(object: Any?) {
        NotificationCenter.default.post(name: FacadeDidErrorNotification, object: object)
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
    
#if os(watchOS)
#else
    func fetchRoot() -> Results<RMenu>? {
        do {
            return try RMenu.fetchRoot()
        }
        catch {
            facadeDidErrorNotification(object: error)
            return nil
        }
    }

    func fetchHelp() -> Results<RMenu>? {
        do {
           return try RMenu.fetchHelp()
        }
        catch {
            facadeDidErrorNotification(object: error)
            return nil
        }
    }
    
    func fetchLocalForecast() -> RWSpotForecast? {
        do {
            let realm = try Realm()
            if let placemark = realm.objects(RPlacemark.self).last {
                return placemark.spotForecast
            }
        }
        catch {
            facadeDidErrorNotification(object: error)
        }
        return nil
    }
#endif
    
    
}
