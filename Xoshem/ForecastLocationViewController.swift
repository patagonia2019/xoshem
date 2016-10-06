//
//  ForecastLocationViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/10/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFWindguru
import JFCore
import SCLAlertView

class ForecastLocationViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var cellSize: CGSize! = CGSizeMake(191.5, 350.0)
    var updateSize: CGSize! = CGSizeZero
    var forecasts: [CDForecastResult]!
    var currentLocation: CDLocation?
    var currentForecast: CDForecastResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateForecastView(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.flashScrollIndicators()
        self.observeNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unobserveNotification()
    }
    
    ///
    /// UICollectionViewDataSource
    ///
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func totalCells() -> Int {
        var count = 0
        
        // current location
        if let _ = self.currentLocation {
            count = 1
        }
        // rest of the forecast
        //        count = count + self.forecastsFiltered.count
        
        // Add new (+)
        count = count + 1
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCells()
    }
    
    func currentForecastResult() -> CDForecastResult? {
        if let location = self.currentLocation {
            if let placemark = location.placemarks?.allObjects.first as! CDPlacemark? {
                return placemark.forecastResults?.allObjects.first as! CDForecastResult?
            }
        }
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(Common.cell.identifier.forecast, forIndexPath: indexPath) as! ForecastLocationCollectionViewCell
        
        if indexPath.row == totalCells() - 1 {
            cell.configureLastCell()
        }
        else if indexPath.row == 0 {
            if let forecastResult = self.currentForecastResult() {
                cell.configureCell(forecastResult, isEditing: self.editing, didUpdate: { (Void) in
                    self.updateForecastView(false)
                })
            }
        }
        //        else if self.forecastsFiltered.count > 0 {
        //            cell.configureCell(forecastsFiltered[indexPath.row-1], isEditing: self.editing, didUpdate: { (Void) in
        //                self.updateForecastView(false)
        //            })
        //        }
        return cell
    }
    
    ///
    /// UICollectionViewDelegate
    ///
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            let forecastCell = cell as! ForecastLocationCollectionViewCell
            forecastCell.selected()
            UIView.animateWithDuration(0.5, animations: {
                forecastCell.unselected()
            })
            
            if indexPath.row == totalCells() - 1 {
                self.performSegueWithIdentifier(Common.segue.search, sender: nil)
            }
            else if indexPath.row == 0 {
                if let forecastResult = self.currentForecastResult() {
                    self.currentForecast = forecastResult
                    self.performSegueWithIdentifier(Common.segue.forecastDetail, sender: nil)
                }
            }
            //            else if self.forecastsFiltered.count > 0 {
            //                self.currentForecast = forecastsFiltered[indexPath.row]
            //                self.performSegueWithIdentifier(Common.segue.forecastDetail, sender: nil)
            //            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = self.cellSize
        let viewSize = CGSizeEqualToSize(self.updateSize, CGSizeZero) ? self.collectionView.frame.size : self.updateSize
        let itemsInWidth = Int(viewSize!.width / (size?.width)!)
        size!.width = viewSize!.width / CGFloat(itemsInWidth)
        if size!.width > (self.cellSize.width * 1.5) {
            size!.width = self.cellSize.width
        }
        return size!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator
        coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.updateSize = size
        self.collectionView.reloadData()
    }
    
    /// Notifications
    
    private func observeNotification()
    {
        self.unobserveNotification()
        
        let queue = NSOperationQueue.mainQueue()
        
        NSNotificationCenter.defaultCenter()
            .addObserverForName(Common.notification.editing, object: nil, queue: queue,
                                usingBlock: { [weak self] note in
                                    if let strong = self {
                                        if let isEditing: Bool = note.object as? Bool {
                                            strong.setEditing(isEditing, animated: true)
                                            strong._forecastsFiltered = nil
                                            strong.collectionView.reloadData()
                                        }
                                    }})
        
        NSNotificationCenter.defaultCenter()
            .addObserverForName(Common.notification.forecast.updated, object: nil, queue: queue,
                                usingBlock: { [weak self] (NSNotification) in
                                    if let strong = self {
                                        strong.updateForecastView(false)
                                    }
                })
    }
    
    private func unobserveNotification()
    {
        for notification in [Common.notification.location.saved, JFCore.Constants.Notification.locationUpdated,
                             JFCore.Constants.Notification.locationError, JFCore.Constants.Notification.locationAuthorized,
                             Common.notification.editing, Common.notification.forecast.updated] {
                                NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }
    
    var forecastsFiltered: [CDForecastResult] {
        if _forecastsFiltered != nil {
            return _forecastsFiltered!
        }
        
        _forecastsFiltered = self.forecasts.filter { (forecast) -> Bool in
            if self.editing {
                return true
            }
            if forecast.hide {
                return false
            }
            return true
        }
        
        return _forecastsFiltered!
    }
    var _forecastsFiltered: [CDForecastResult]? = nil
    
    func reloadView() {
        UIView.animateWithDuration(0.3, animations: {
            self.collectionView.reloadData()
            }, completion: { (completed) in
                self.collectionView.flashScrollIndicators()
        })
    }
    
    private func updateForecastView(showAlert: Bool)
    {
        do {
            self.currentLocation = try Facade.instance.fetchCurrentLocation()
            
            self.forecasts = try Facade.instance.fetchForecastResult()
            
            if (showAlert) {
                let alertView = SCLAlertView()
                alertView.addButton(Common.title.Reload) { [weak self] (isOtherButton) in
                    if let strong = self {
                        strong.reloadView()
                    }
                }
                alertView.showSuccess(Common.title.fetchForecast, subTitle: "\(Common.title.successGetting) \(self.forecasts.count) \(Common.title.forecasts)")
            }
            else {
                self.reloadView()
            }
        }
        catch {
            if let e = error as? Error {
                let alertView = SCLAlertView()
                alertView.addButton(Common.title.Reload) { [weak self] (isOtherButton) in
                    if let strong = self {
                        strong.updateForecastView(false)
                    }
                }
                alertView.showError(Common.title.fetchForecast, subTitle: e.description)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Common.segue.forecastDetail {
            let vc:ForecastDetailViewController = segue.destinationViewController as! ForecastDetailViewController
            if let _currentForecast = self.currentForecast {
                vc.detailItem = _currentForecast
                vc.title = _currentForecast.namecheck()
            }
        }
        else if segue.identifier == Common.segue.search {
            let vc:UIViewController = segue.destinationViewController
            vc.title = Common.title.Search
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }
    
}
