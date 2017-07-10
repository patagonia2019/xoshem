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
import CoreData

/*
 *  Facade
 *
 *  Discussion:
 *    Manager of synchronization between the watch/iphone/ipad it shares plist files using a common group.
 *    It is subscribed to notifications of the LocationManager to update the plist file with the new location/country.
 */

open class Facade: NSObject, NSFetchedResultsControllerDelegate {
    //
    // Attributes only modified by this class
    //
    fileprivate var forecast: ForecastWindguruService!
    fileprivate var locations = [CLLocation]()
    fileprivate var started : Bool = false
    fileprivate var onProcessing : Bool = false
    fileprivate var auth: Auth!
    fileprivate static var firstTime: Bool = true
    open var lastRefreshDate : Date?

    open static let instance = Facade()

    lazy var mco: NSManagedObjectContext = {
        let _mco: NSManagedObjectContext = CoreDataManager.instance.taskContext
        return _mco
    }()

    //
    // initialization
    //
    fileprivate override init() {
        super.init()
        forecast = ForecastWindguruService()
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

            self?.observeNotifications()
            
            if (Facade.firstTime) {
                try! self?.removeMenu()
                Facade.firstTime = false
            }

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
//            updatePlacemarksAndLocation()
            try! self?.startForecastServices()
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
            self?.stopForecastServices()
        
            CoreDataManager.instance.save()
            self?.started = false
        })
    }
    
    //
    // Forecast group of code
    //
    fileprivate func startForecastServices() throws
    {
        do {
            let fetchedForecastResults = try CDForecastResult.fetch (mco)
            if fetchedForecastResults.count > 0 {
                updateSpotsForecastResult(fetchedForecastResults, placemark: nil)
            }
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.forecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
        
    }

    
    //
    // Location code
    //
    
    func recursivelyUpdateSpotOwners(_ spotOwners: [SpotOwner], placemark: CDPlacemark) throws {
        do {
            var array = spotOwners
            if array.count > 0 {
                let spotOwner = array.removeFirst()
                guard let cdSpotOwner = try CDSpotOwner.importObject(spotOwner, mco: mco),
                      let identity = cdSpotOwner.identity else {
                    try recursivelyUpdateSpotOwners(array, placemark: placemark)
                    return
                }
                
                forecast.queryWeatherSpot(spot: identity,
                    updateForecastDidFailWithError: {
                        [weak self] (error) in
                        do {
                            try self?.recursivelyUpdateSpotOwners(array, placemark: placemark)
                        }
                        catch {
                            let myerror = JFError(code: Common.ErrorCode.updateSpotsOwnersIssue.rawValue,
                                                  desc: Common.title.failedAtImportObjects,
                                                  reason: "Error on update CDSpotOwners",
                                                  suggestion: "\(#file):\(#line):\(#column):\(#function)",
                                underError: error as NSError)
                            Analytics.logFatal(error: myerror)
                            myerror.fatal()
                        }
                    },
                    didUpdateForecastResult: {
                        [weak self] (forecastResult) in
                        do {
                            self?.lastRefreshDate = Date.init()
                            try self?.didUpdateForecastResult(forecastResult, spotOwner:cdSpotOwner,
                                                              placemark: placemark)
                            try self?.recursivelyUpdateSpotOwners(array, placemark: placemark)
                        }
                        catch {
                            let myerror = JFError(code: Common.ErrorCode.updateForecastSpotsResultIssue.rawValue,
                                                desc: Common.title.failedAtImportObjects,
                                                reason: "Error on update CDForecastResult",
                                                suggestion: "\(#file):\(#line):\(#column):\(#function)",
                                underError: error as NSError)
                            Analytics.logFatal(error: myerror)
                            myerror.fatal()
                        }
                    })
            }
            else {
                forecastUpdated()
            }
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.updateForecastSpotsResultIssue.rawValue,
                                desc: Common.title.failedAtImportObjects,
                                reason: "Error in ForecastResult/SpotOwners",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)",
                underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
    func queryLocationWithString(_ string: String, placemark: CDPlacemark, tryAgain:@escaping () -> Void) {
        forecast.queryLocation(location: string,
            updateSpotDidFailWithError: {
                (error) in
                tryAgain()
            },
            didUpdateSpotResult: {
                [weak self] (spotResult) in
                if let array = spotResult.spots {
                    do {
                        try self?.recursivelyUpdateSpotOwners(array, placemark: placemark)
                    }
                    catch {
                        let myerror = JFError(code: Common.ErrorCode.updateSpotsOwnersIssue.rawValue,
                                              desc: Common.title.failedAtImportObjects,
                                              reason: "Error on update CDSpotOwners",
                                              suggestion: "\(#file):\(#line):\(#column):\(#function)",
                            underError: error as NSError)
                        Analytics.logFatal(error: myerror)
                        myerror.fatal()
                    }
                }
                else {
                    tryAgain()
                }
        })
    }
    
    
    func recursivelyQueryLocationWithArray(_ strings: [String], placemark: CDPlacemark) {
        var array = strings
        if array.count > 0 {
            let string = array.removeFirst()
            queryLocationWithString(string, placemark: placemark, tryAgain: { [weak self] in
                if array.count > 0 {
                    self?.recursivelyQueryLocationWithArray(array, placemark: placemark)
                }
                else {
                    let myerror = JFError(code: Common.ErrorCode.queryLocationWithPlacemarkIssue.rawValue,
                        desc: Common.title.errorOnSearch,
                        reason: "Failed to query placemark with string \(string)",
                        suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                    Analytics.logFatal(error: myerror)
                    myerror.fatal()
                }
            })
        }
    }
    
    
    
    func queryLocationWithPlacemark(_ placemark: CDPlacemark) -> Bool {
        
        var array = [String]()

        if let _subLocality = placemark.subLocality {
            array.append(_subLocality)
        }
        if let _locality = placemark.locality {
            array.append(_locality)
        }
        if let _administrativeArea = placemark.administrativeArea {
            array.append(_administrativeArea)
        }
        if let _subAdministrativeArea = placemark.administrativeArea {
            array.append(_subAdministrativeArea)
        }
        if let _country = placemark.country {
            array.append(_country)
        }

        if array.count > 0 {
            recursivelyQueryLocationWithArray(array, placemark: placemark)
            return true
        }

        return false
    }
    
    func updatePlacemarksAndLocation() {
        if  (locations.count > 0) {
            updateLocations()
        }
    }
    
    func updatePlacemarks(_ placemarks: [CLPlacemark], location: CDLocation) throws {
        var array = placemarks
        if array.count > 0 {
            let placemark = array.removeFirst()
            do {
                if let cdPlacemark = try CDPlacemark.importObject(placemark, mco: mco) {
                    cdPlacemark.location = location
                    if  (queryLocationWithPlacemark(cdPlacemark)) {
                        try updatePlacemarks(array, location: location)
                    }
                }
            } catch {
                let myerror = JFError(code: Common.ErrorCode.updatePlacemarksLocationIssue.rawValue,
                                    desc: Common.title.failedAtImportObjects,
                                    reason: "Error on update Placemark",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                Analytics.logError(error: myerror)
                throw myerror
            }
        }
    }

    func updateLocations(_ currentLocations: [CLLocation]) throws {
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
                    for location in locations {
                        self?.mco.delete(location)
                    }
                    self?.locations = currentLocations
                    self?.updateLocations()
                }
//                try mco.save()
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
    


    func updateLocations() {
        if locations.count > 0 && !self.onProcessing {
            onProcessing = true
            JFCore.Common.synchronized(syncBlock: { [weak self] in
                guard let location = self?.locations.removeFirst() else {
                    return
                }
                LocationManager.instance.reverseLocation(location: location,
                    didFailWithError: { (error) in
                        self?.updateLocations()
                    },
                    didUpdatePlacemarks: { (placemarks) in
                        do {
                            if  let mco = self?.mco,
                                let cdLocation = try CDLocation.importObject(location, mco: mco) {
                                try self?.updatePlacemarks(placemarks, location: cdLocation)
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
                        self?.updateLocations()
                })
            })
        }
        else {
            onProcessing = false
            locationSaved()
        }
    }
    

    fileprivate func observeNotifications()
    {
        unobserveNotifications()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationUpdated), object: nil, queue: OperationQueue.main) { (NSNotification) in
            if !LocationManager.instance.isRunning() {
                return
            }
            JFCore.Common.synchronized(syncBlock: { [weak self] in
                guard let locations = LocationManager.instance.locations else {
                    return
                }
                if let onProcessing = self?.onProcessing, onProcessing == true {
                    return
                }
                try! self?.updateLocations(locations)
            })
        }

    }
    
    fileprivate func unobserveNotifications()
    {
        for notification in [JFCore.Constants.Notification.locationUpdated, JFCore.Constants.Notification.locationError, JFCore.Constants.Notification.locationAuthorized] {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }

    //
    // update forecast
    //
    
    func didUpdateForecastResult(_ forecastResult: ForecastResult, spotOwner: CDSpotOwner?, placemark: CDPlacemark?) throws {
        do {
            guard let forecastResult = try CDForecastResult.importObject(forecastResult, mco: mco),
                let placemarkToUpdate = placemark,
                let _ = placemarkToUpdate.location else {
                    return
            }
            forecastResult.placemarkResult = placemarkToUpdate
            forecastResult.spotOwner = spotOwner
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.updateForecastResultIssue.rawValue,
                                desc: Common.title.failedAtImportObjects,
                                reason: "Error on update ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }

    func updateSpotsForecastResult(_ fetchedForecastResults: [CDForecastResult]?, placemark: CDPlacemark?) {
        if var array : [CDForecastResult] = fetchedForecastResults {
            if array.count > 0 {
                JFCore.Common.synchronized(syncBlock: { [weak self] in

                    let mySpot = array.removeFirst()
                    guard let identity = mySpot.identity,
                        let currentModel = mySpot.currentModel else {
                            self?.updateSpotsForecastResult(array, placemark: placemark)
                            return
                    }
                    self?.forecast.queryWeatherSpot(spot: identity, model: currentModel,
                        updateForecastDidFailWithError: { [weak self] (error) in
                            self?.updateSpotsForecastResult(array, placemark: placemark)
                        },
                        didUpdateForecastResult: { [weak self] (forecastResult) in
                            do {
                                try self?.didUpdateForecastResult(forecastResult, spotOwner: nil, placemark: placemark)
                                self?.updateSpotsForecastResult(array, placemark: placemark)
                            }
                            catch {
                                let myerror = JFError(code: Common.ErrorCode.updateForecastSpotsResultIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Error on update ForecastResult/Spots",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                                Analytics.logFatal(error: myerror)
                                myerror.fatal()
                            }
                    })
                })
            }
            else {
                forecastUpdated()
            }
        }
    }
    
    
    fileprivate func stopForecastServices()
    {
    }
    
    // MARK: - Core Data stack
 
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.fuchs.mater-detail.md" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    

    func createMenu() throws {
                
        let menuArray : [[String: AnyObject]] = [
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(1) as AnyObject,
                "name": Common.title.Forecast as AnyObject,
                "icon": "1468046481_cloud-weather-forecast-cloudy-outline-stroke" as AnyObject,
                "iconList": "themify" as AnyObject,
                "iconName": "cloud" as AnyObject,
                "edit": Bool(true) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(2) as AnyObject,
                "name": Common.title.Search as AnyObject,
                "icon": "1468046237_common-search-lookup-glyph" as AnyObject,
                "iconList": "FontAwesome" as AnyObject,
                "iconName": "search" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(3) as AnyObject,
                "name": Common.title.Options as AnyObject,
                "icon": "1468046524_editor-setting-gear-outline-stroke" as AnyObject,
                "iconList": "FontAwesome" as AnyObject,
                "iconName": "gear" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(4) as AnyObject,
                "name": Common.title.Help as AnyObject,
                "icon": "1468046356_circle-help-question-mark-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "help-circled" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(1) as AnyObject,
                "name": Common.title.frequentlyAskedQuestions as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.faq as AnyObject,
                "icon": "1468046956_common-bookmark-book-open-glyph" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "ios-book-outline" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(2) as AnyObject,
                "name": Common.title.Tutorial as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tutorial as AnyObject,
                "icon": "1475082499_device-board-presentation-content-chart-outline-stroke" as AnyObject,
                "iconList": "octicons" as AnyObject,
                "iconName": "device-desktop" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(3) as AnyObject,
                "name": Common.title.TermsOfUse as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tou as AnyObject,
                "icon": "1468046901_editor-books-library-collection-glyph" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "bowtie" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(4) as AnyObject,
                "name": Common.title.TermsAndConditions as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tac as AnyObject,
                "icon": "1468046859_business-tie-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "bowtie" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(5) as AnyObject,
                "name": "\(Common.title.About) \(JFCore.Common.app)" as AnyObject,
                "segue": Common.segue.about as AnyObject,
                "file": Common.file.about as AnyObject,
                "icon": "1468046733_circle-info-more-information-detail-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "ios-information-outline" as AnyObject,
                "edit": Bool(false) as AnyObject
            ]
        ]

        /*
         Create a context on a private queue to:
         - Fetch existing menus to compare with incoming data.
         - Create new menus as required.
         */

        do {
            try _ = CDMenu.importArray(menuArray, mco: mco)

        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.importMenuArrayIssue.rawValue,
                                desc: Common.title.errorOnImport,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
    
    func removeMenu() throws {
        do {
            let array = try CDMenu.fetch (mco)
            for menu in array {
                mco.delete(menu)
            }
            try mco.save()
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdRemoveMenuIssue.rawValue,
                                desc: Common.title.errorOnDelete,
                                reason: "Failed at fetch menu and remove",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    

    func fetchRootMenu() -> [CDMenu] {
        var array = [CDMenu]()
        do {
            array = try CDMenu.fetchRootMenu(mco)
            if array.count == 0 {
                try createMenu()
                array = try CDMenu.fetchRootMenu(mco)
            }
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchRootMenuIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logFatal(error: myerror)
            myerror.fatal()
        }
        return array
    }

    
    func fetchHelpMenu() -> [CDMenu] {
        var array = [CDMenu]()
        do {
            array = try CDMenu.fetchHelpMenu (mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchHelpMenuIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            myerror.fatal()
        }
        return array
    }
    
    func fetchForecastResult() throws -> [CDForecastResult] {
        var array = [CDForecastResult]()
        do {
            array = try CDForecastResult.fetch (mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.forecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
        return array
    }
    
    
    func fetchLocation() throws -> [CDLocation] {
        var array = [CDLocation]()
        do {
            array = try CDLocation.fetch (mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchLocationIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Location",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
        return array
    }
    
    func fetchCurrentLocation() throws -> CDLocation? {
        var array = [CDLocation]()
        do {
            array = try fetchLocation()
        }
        catch {
            return nil
        }
        if array.count > 0 {
            return array.first
        }
        return nil
    }
    
    
    func fetchPlacemarks() throws -> [CDPlacemark] {
        var array = [CDPlacemark]()
        do {
            array = try CDPlacemark.fetch (mco)
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.fetchPlacemarkIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Placemark",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
        return array
    }
    

    func fetchForecastModel(_ forecastResult: CDForecastResult) throws -> CDForecastModel {
        var array = [CDForecastModel]()
        do {
            array = try CDForecastModel.fetchWithSpot(withSpot: forecastResult, mco: mco)!
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.forecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
        return array.first!
    }

    func forecastUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Common.notification.forecast.updated), object: nil)
    }
    
    func locationSaved() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Common.notification.location.saved), object: nil)
    }
    
    
}
