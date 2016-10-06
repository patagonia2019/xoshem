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

public class Facade: NSObject, NSFetchedResultsControllerDelegate {
    //
    // Attributes only modified by this class
    //
    private var forecast: ForecastWindguruService!
    private var locations = [CLLocation]()
    private var started : Bool = false
    private var onProcessing : Bool = false
    private var auth: Auth!
    private static var firstTime: Bool = true
    public var lastRefreshDate : NSDate?

    public static let instance = Facade()

    lazy var mco: NSManagedObjectContext = {
        let _mco: NSManagedObjectContext = CoreDataManager.instance.taskContext
        return _mco
    }()

    //
    // initialization
    //
    private override init() {
        super.init()
        self.forecast = ForecastWindguruService()
        Crash.start()
        self.auth = Auth()
    }
    
    public func restart() throws {
        stop()
        try! start()
    }
    
    

    public func restartLocation() throws {
        JFCore.Common.synchronized({
            self.spinnerStop()
            LocationManager.instance.stop()
            self.spinnerStart()

            LocationManager.instance.start()
        })
    }
    
    public func stopLocation() throws {
        JFCore.Common.synchronized({
            LocationManager.instance.stop()
            self.spinnerStop()
        })
    }
    
    
    //
    // start service manager
    //
    public func start() throws
    {
        JFCore.Common.synchronized({
            if self.started {
                return
            }
            self.spinnerStart()

            self.started = true

            self.logCurrentLanguage()
            self.observeNotifications()
            
            if (Facade.firstTime) {
                try! self.removeMenu()
                Facade.firstTime = false
            }

            Analytics.start()
        #if os(watchOS)
            print("TARGET_OS_WATCH")
        #else
            if (TARGET_OS_SIMULATOR == 1) {
                print("TARGET_OS_SIMULATOR")
                Analytics.logFunction(#function, parameters: ["line": "\(#line)", "device": "simulator"])
            }
            else {
                Analytics.logFunction(#function, parameters: ["line": "\(#line)", "device": "real device"])
            }
        #endif

            LocationManager.instance.start()
//            self.updatePlacemarksAndLocation()
            try! self.startForecastServices()
        })
    }
    
    //
    // stop service manager
    //
    public func stop()
    {
        JFCore.Common.synchronized({
            Analytics.stop()
            LocationManager.instance.stop()

            self.unobserveNotifications()
            self.stopForecastServices()
        
            CoreDataManager.instance.save()
            self.spinnerStop()
            self.started = false
        })
    }
    
    //
    // Forecast group of code
    //
    private func startForecastServices() throws
    {
        do {
            let fetchedForecastResults = try CDForecastResult.fetch(self.mco)
            if fetchedForecastResults.count > 0 {
                self.updateSpotsForecastResult(fetchedForecastResults, placemark: nil)
            }
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.ForecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
        
    }

    
    //
    // Location code
    //
    
    func didUpdateSpotOwners(spotOwners: [SpotOwner], placemark: CDPlacemark) throws {
        do {
            var array = spotOwners
            if array.count > 0 {
                let spotOwner = array.removeFirst()
                let cdSpotOwner = try CDSpotOwner.importObject(spotOwner, mco: self.mco)
                self.forecast
                    .queryWeatherSpot(spot: cdSpotOwner.identity!,
                                      updateForecastDidFailWithError: { [weak self] (error) in
                                        do {
                                            if let strong = self {
                                                try strong.didUpdateSpotOwners(array, placemark: placemark)
                                            }
                                        }
                                        catch {
                                            let myerror = Error(code: Common.ErrorCode.UpdateSpotsOwnersIssue.rawValue,
                                                desc: Common.title.failedAtImportObjects,
                                                reason: "Error on update CDSpotOwners",
                                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                                            Analytics.logFatal(myerror)
                                            myerror.fatal()
                                        }
                        },
                                      didUpdateForecastResult: { [weak self] (forecastResult) in
                                        do {
                                            if let strong = self {
                                                strong.lastRefreshDate = NSDate()
                                                try strong.didUpdateForecastResult(forecastResult, spotOwner:cdSpotOwner, placemark: placemark)
                                                try strong.didUpdateSpotOwners(array, placemark: placemark)
                                            }
                                        }
                                        catch {
                                            let myerror = Error(code: Common.ErrorCode.UpdateForecastSpotsResultIssue.rawValue,
                                                desc: Common.title.failedAtImportObjects,
                                                reason: "Error on update CDForecastResult",
                                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                                            Analytics.logFatal(myerror)
                                            myerror.fatal()
                                        }
                    })
            }
            else {
                self.forecastUpdated()
                self.spinnerStop()
            }
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.UpdateForecastSpotsResultIssue.rawValue,
                                desc: Common.title.failedAtImportObjects,
                                reason: "Error in ForecastResult/SpotOwners",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
    }
    
    func queryLocationWithString(string: String, placemark: CDPlacemark, tryAgain:() -> Void) {
        self.forecast.queryLocation(location: string,
                                    updateSpotDidFailWithError: { (error) in
                                        tryAgain()
                                    },
                                    didUpdateSpotResult: { [weak self] (spotResult) in
                                        if let array = spotResult.spots {
                                            do {
                                                if let strong = self {
                                                    try strong.didUpdateSpotOwners(array, placemark: placemark)
                                                }
                                            }
                                            catch {
                                                let myerror = Error(code: Common.ErrorCode.UpdateSpotsOwnersIssue.rawValue,
                                                    desc: Common.title.failedAtImportObjects,
                                                    reason: "Error on update CDSpotOwners",
                                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                                                Analytics.logFatal(myerror)
                                                myerror.fatal()
                                            }
                                        }
                                        else {
                                            tryAgain()
                                        }
        })
    }
    
    
    func queryLocationWithArray(strings: [String], placemark: CDPlacemark) {
        var array = strings
        if array.count > 0 {
            let string = array.removeFirst()
            self.queryLocationWithString(string, placemark: placemark, tryAgain: { [weak self] in
                if array.count > 0 {
                    if let strong = self {
                        strong.queryLocationWithArray(array, placemark: placemark)
                    }
                }
                else {
                    let myerror = Error(code: Common.ErrorCode.QueryLocationWithPlacemarkIssue.rawValue,
                        desc: Common.title.errorOnSearch,
                        reason: "Failed to query placemark with string \(string)",
                        suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: nil)
                    Analytics.logFatal(myerror)
                    myerror.fatal()
                }
            })
        }
    }
    
    
    
    func queryLocationWithPlacemark(placemark: CDPlacemark) -> Bool {
        
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
            self.queryLocationWithArray(array, placemark: placemark)
            return true
        }

        return false
    }
    
    func updatePlacemarksAndLocation() {
        if (self.locations.count > 0) {
            self.updateLocations()
        }
    }
    
    func updatePlacemarks(placemarks: [CLPlacemark], location: CDLocation) throws {
        var array = placemarks
        if array.count > 0 {
            let placemark = array.removeFirst()
            do {
                if let cdPlacemark = try CDPlacemark.importObject(placemark, mco: self.mco) {
                    cdPlacemark.location = location
                    if (self.queryLocationWithPlacemark(cdPlacemark)) {
                        try self.updatePlacemarks(array, location: location)
                    }
                }
            } catch {
                let myerror = Error(code: Common.ErrorCode.UpdatePlacemarksLocationIssue.rawValue,
                                    desc: Common.title.failedAtImportObjects,
                                    reason: "Error on update Placemark",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                Analytics.logError(myerror)
                throw myerror
            }
        }
    }

    func updateLocations(currentLocations: [CLLocation]) throws {
        JFCore.Common.synchronized({ [weak self] in
            guard let strong = self else {
                return
            }
            do {
                let locations = try strong.fetchLocation()
                
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
                        strong.mco.deleteObject(location)
                    }
                    strong.locations = currentLocations
                    strong.updateLocations()
                }
//                try self.mco.save()
            }
            catch {
                let myerror = Error(code: Common.ErrorCode.FetchLocationIssue.rawValue,
                    desc: Common.title.errorOnSearch,
                    reason: "Error on search / delete location",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                Analytics.logFatal(myerror)
                myerror.fatal()
            }
        })
    }
    


    func updateLocations() {
        if self.locations.count > 0 && !self.onProcessing {
            self.onProcessing = true
            JFCore.Common.synchronized({ [weak self] in
                guard let strong = self else {
                    return
                }
                let location = strong.locations.removeFirst()
                LocationManager.instance.reverseLocation(location,
                    didFailWithError: { (error) in
                        strong.updateLocations()
                    },
                    didUpdatePlacemarks: { (placemarks) in
                        do {
                            if let cdLocation = try CDLocation.importObject(location, mco: strong.mco) {
                                try strong.updatePlacemarks(placemarks, location: cdLocation)
                            }
                        }
                        catch {
                            let myerror = Error(code: Common.ErrorCode.CDUpdateLocationIssue.rawValue,
                                desc: Common.title.errorOnUpdate,
                                reason: "Error on Location/Placemarks import",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                            Analytics.logFatal(myerror)
                            myerror.fatal()
                        }
                        strong.updateLocations()
                })
            })
        }
        else {
            self.onProcessing = false
            self.locationSaved()
        }
    }
    
    private func logCurrentLanguage()
    {
        if let locale : NSLocale = NSLocale.currentLocale() {
            for key in [NSLocaleIdentifier, NSLocaleLanguageCode, NSLocaleCountryCode, NSLocaleScriptCode, NSLocaleVariantCode, NSLocaleUsesMetricSystem, NSLocaleMeasurementSystem, NSLocaleDecimalSeparator] {
                if let name = locale.objectForKey(key) {
                    Analytics.logFunction(#function, parameters: [key : String(name)])
                }
            }
            if let calendar = locale.objectForKey(NSLocaleCalendar) as? NSCalendar {
                Analytics.logFunction(#function, parameters: [NSLocaleCalendar : calendar.calendarIdentifier])
            }
        }
    }

    private func observeNotifications()
    {
        self.unobserveNotifications()
        
        NSNotificationCenter.defaultCenter().addObserverForName(JFCore.Constants.Notification.locationUpdated, object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) in
            if !LocationManager.instance.isRunning() {
                return
            }
            JFCore.Common.synchronized({ [weak self] in
                guard let strong = self else {
                    return
                }
                guard let locations = LocationManager.instance.locations else {
                    return
                }
                if strong.onProcessing {
                    return
                }
                try! strong.updateLocations(locations)
            })
        }

//        NSNotificationCenter.defaultCenter().addObserverForName(JFCore.Constants.Notification.locationError, object: nil, queue: NSOperationQueue.mainQueue()) {
//            note in if let object: Error = note.object as? Error {
//                object.fatal()
//            }
//        }
//
//        NSNotificationCenter.defaultCenter().addObserverForName(JFCore.Constants.Notification.locationAuthorized, object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) in
//
//        }
    }
    
    private func unobserveNotifications()
    {
        for notification in [JFCore.Constants.Notification.locationUpdated, JFCore.Constants.Notification.locationError, JFCore.Constants.Notification.locationAuthorized] {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }

    //
    // update forecast
    //
    
    func didUpdateForecastResult(forecastResult: ForecastResult, spotOwner: CDSpotOwner?, placemark: CDPlacemark?) throws {
        do {
            let forecastResult = try CDForecastResult.importObject(forecastResult, mco: self.mco)
            if let placemarkToUpdate = placemark,
                    _ = placemarkToUpdate.location {
                forecastResult.placemarkResult = placemarkToUpdate
                forecastResult.spotOwner = spotOwner
            }
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.UpdateForecastResultIssue.rawValue,
                                desc: Common.title.failedAtImportObjects,
                                reason: "Error on update ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
    }

    func updateSpotsForecastResult(fetchedForecastResults: [CDForecastResult]?, placemark: CDPlacemark?) {
        if var array : [CDForecastResult] = fetchedForecastResults {
            if array.count > 0 {
                JFCore.Common.synchronized({ [weak self] in
                    guard let strong = self else {
                        return
                    }

                    let mySpot = array.removeFirst()
                    guard let identity = mySpot.identity,
                        currentModel = mySpot.currentModel else {
                            strong.updateSpotsForecastResult(array, placemark: placemark)
                            return
                    }
                    strong.forecast.queryWeatherSpot(spot: identity, model: currentModel,
                        updateForecastDidFailWithError: { [weak self] (error) in
                            guard let strong = self else {
                                return
                            }
                            strong.updateSpotsForecastResult(array, placemark: placemark)
                        },
                        didUpdateForecastResult: { [weak self] (forecastResult) in
                            do {
                                guard let strong = self else {
                                    return
                                }
                                try strong.didUpdateForecastResult(forecastResult, spotOwner: nil, placemark: placemark)
                                strong.updateSpotsForecastResult(array, placemark: placemark)
                            }
                            catch {
                                let myerror = Error(code: Common.ErrorCode.UpdateForecastSpotsResultIssue.rawValue,
                                    desc: Common.title.errorOnUpdate,
                                    reason: "Error on update ForecastResult/Spots",
                                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
                                Analytics.logFatal(myerror)
                                myerror.fatal()
                            }
                    })
                })
            }
            else {
                self.forecastUpdated()
                self.spinnerStop()
            }
        }
    }
    
    
    private func stopForecastServices()
    {
    }
    
    // MARK: - Core Data stack
 
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.fuchs.mater-detail.md" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    

    func createMenu() throws {
                
        let menuArray : [[String: AnyObject]] = [
            [
                "parentId": Int(0),
                "id": Int(1),
                "name": Common.title.Forecast,
                "icon": "1468046481_cloud-weather-forecast-cloudy-outline-stroke",
                "iconList": "themify",
                "iconName": "cloud",
                "edit": Bool(true)
            ],
            [
                "parentId": Int(0),
                "id": Int(2),
                "name": Common.title.Search,
                "icon": "1468046237_common-search-lookup-glyph",
                "iconList": "FontAwesome",
                "iconName": "search",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(0),
                "id": Int(3),
                "name": Common.title.Options,
                "icon": "1468046524_editor-setting-gear-outline-stroke",
                "iconList": "FontAwesome",
                "iconName": "gear",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(0),
                "id": Int(4),
                "name": Common.title.Help,
                "icon": "1468046356_circle-help-question-mark-outline-stroke",
                "iconList": "Ionicons",
                "iconName": "help-circled",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(4),
                "id": Int(1),
                "name": Common.title.frequentlyAskedQuestions,
                "segue": Common.segue.web,
                "file": Common.file.faq,
                "icon": "1468046956_common-bookmark-book-open-glyph",
                "iconList": "Ionicons",
                "iconName": "ios-book-outline",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(4),
                "id": Int(2),
                "name": Common.title.Tutorial,
                "segue": Common.segue.web,
                "file": Common.file.tutorial,
                "icon": "1475082499_device-board-presentation-content-chart-outline-stroke",
                "iconList": "octicons",
                "iconName": "device-desktop",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(4),
                "id": Int(3),
                "name": Common.title.TermsOfUse,
                "segue": Common.segue.web,
                "file": Common.file.tou,
                "icon": "1468046901_editor-books-library-collection-glyph",
                "iconList": "Ionicons",
                "iconName": "bowtie",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(4),
                "id": Int(4),
                "name": Common.title.TermsAndConditions,
                "segue": Common.segue.web,
                "file": Common.file.tac,
                "icon": "1468046859_business-tie-outline-stroke",
                "iconList": "Ionicons",
                "iconName": "bowtie",
                "edit": Bool(false)
            ],
            [
                "parentId": Int(4),
                "id": Int(5),
                "name": "\(Common.title.About) \(JFCore.Common.app)",
                "segue": Common.segue.about,
                "file": Common.file.about,
                "icon": "1468046733_circle-info-more-information-detail-outline-stroke",
                "iconList": "Ionicons",
                "iconName": "ios-information-outline",
                "edit": Bool(false)
            ]
        ]

        /*
         Create a context on a private queue to:
         - Fetch existing menus to compare with incoming data.
         - Create new menus as required.
         */

        do {
            try CDMenu.importArray(menuArray, mco: self.mco)

        }
        catch {
            let myerror = Error(code: Common.ErrorCode.ImportMenuArrayIssue.rawValue,
                                desc: Common.title.errorOnImport,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
    }
    
    
    func removeMenu() throws {
        do {
            let array = try CDMenu.fetch(self.mco)
            for menu in array {
                self.mco.deleteObject(menu)
            }
            try self.mco.save()
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.CDRemoveMenuIssue.rawValue,
                                desc: Common.title.errorOnDelete,
                                reason: "Failed at fetch menu and remove",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
    }
    

    func fetchRootMenu() -> [CDMenu] {
        var array = [CDMenu]()
        do {
            array = try CDMenu.fetchRootMenu(self.mco)
            if array.count == 0 {
                try self.createMenu()
                array = try CDMenu.fetchRootMenu(self.mco)
            }
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.FetchRootMenuIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logFatal(myerror)
            myerror.fatal()
        }
        return array
    }

    
    func fetchHelpMenu() -> [CDMenu] {
        var array = [CDMenu]()
        do {
            array = try CDMenu.fetchHelpMenu(self.mco)
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.FetchHelpMenuIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Error on CDMenu",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            myerror.fatal()
        }
        return array
    }
    
    func fetchForecastResult() throws -> [CDForecastResult] {
        var array = [CDForecastResult]()
        do {
            array = try CDForecastResult.fetch(self.mco)
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.ForecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
        return array
    }
    
    
    func fetchLocation() throws -> [CDLocation] {
        var array = [CDLocation]()
        do {
            array = try CDLocation.fetch(self.mco)
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.FetchLocationIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Location",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
        return array
    }
    
    func fetchCurrentLocation() throws -> CDLocation? {
        var array = [CDLocation]()
        do {
            array = try self.fetchLocation()
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
            array = try CDPlacemark.fetch(self.mco)
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.FetchPlacemarkIssue.rawValue,
                                desc: Common.title.errorOnSearch,
                                reason: "Seems to be an initialization error in database with table Placemark",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
        return array
    }
    

    func fetchForecastModel(forecastResult: CDForecastResult) throws -> CDForecastModel {
        var array = [CDForecastModel]()
        do {
            array = try CDForecastModel.fetchWithSpot(withSpot: forecastResult, mco: self.mco)!
        }
        catch {
            let myerror = Error(code: Common.ErrorCode.ForecastResultIssue.rawValue,
                                desc: Common.title.failedAtFetchForecasts,
                                reason: "Seems to be an initialization error in database with table ForecastResult",
                                suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(myerror)
            throw myerror
        }
        return array.first!
    }

    func forecastUpdated() {
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.forecast.updated, object: nil)
    }
    
    func locationSaved() {
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.location.saved, object: nil)
    }
    

    func spinnerStart() {
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.spinner.start, object: nil)
    }
    
    func spinnerStop() {
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.spinner.stop, object: nil)
    }


#if os(iOS)

    private lazy var spinner : SpinnerView = {
        let spinnerView = SpinnerView(frame: CGRectMake(0,0,40,40))
        spinnerView.backgroundColor = UIColor.clearColor()
        spinnerView.sizeToFit()
        return spinnerView
    }()
    
    
    private func removeSpinner() {
        self.spinner.removeFromSuperview()
    }
    
    func addSpinnerToView(view: UIView, translates translatesAutoresizingMaskIntoConstraints: Bool) {
    
        self.removeSpinner()
    
        view.addSubview(self.spinner)
        
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        self.spinner.translatesAutoresizingMaskIntoConstraints = !translatesAutoresizingMaskIntoConstraints
        
        let spinnerConstraints = ["spinner" : self.spinner]
        
        let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("V:[spinner(\(self.spinner.frame.size.width))]", options: .AlignAllTop, metrics: nil, views: spinnerConstraints)
        let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat("H:[spinner(\(self.spinner.frame.size.height))]", options: .AlignAllTop, metrics: nil, views: spinnerConstraints)
        
        self.spinner.addConstraints(constraintsH)
        self.spinner.addConstraints(constraintsV)
        
        let constraintsX = NSLayoutConstraint.constraintsWithVisualFormat("V:[spinner]-1-|", options: .AlignAllTop, metrics: nil, views: spinnerConstraints)
        let constraintsY = NSLayoutConstraint.constraintsWithVisualFormat("H:[spinner]-1-|", options: .AlignAllTop, metrics: nil, views: spinnerConstraints)
        
        view.addConstraints(constraintsX)
        view.addConstraints(constraintsY)
    }
#endif
    
}
