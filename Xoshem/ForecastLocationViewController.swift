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
    var cellSize: CGSize! = CGSize(width: 191.5, height: 350.0)
    var updateSize: CGSize! = CGSize.zero
    var forecasts: [CDForecastResult]!
    var currentLocation: CDLocation?
    var currentForecast: CDForecastResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateForecastView(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.flashScrollIndicators()
        observeNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unobserveNotification()
    }
    
    ///
    /// UICollectionViewDataSource
    ///
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func totalCells() -> Int {
        var count = 0
        
        // current location
        if let _ = currentLocation {
            count = 1
        }
        // rest of the forecast
        //        count = count + forecastsFiltered.count
        
        // Add new (+)
        count = count + 1
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalCells()
    }
    
    func currentForecastResult() -> CDForecastResult? {
        if let location = currentLocation {
            if let placemark = location.placemarks?.allObjects.first as! CDPlacemark? {
                return placemark.forecastResults?.allObjects.first as! CDForecastResult?
            }
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Common.cell.identifier.forecast, for: indexPath) as! ForecastLocationCollectionViewCell
        
        if (indexPath as NSIndexPath).row == totalCells() - 1 {
            cell.configureLastCell()
        }
        else if (indexPath as NSIndexPath).row == 0 {
            if let forecastResult = currentForecastResult() {
                cell.configureCell(forecastResult, isEditing: isEditing, didUpdate: { [weak self] (Void) in
                    self?.updateForecastView(false)
                })
            }
        }
        //        else if forecastsFiltered.count > 0 {
        //            cell.configureCell(forecastsFiltered[indexPath.row-1], isEditing: editing, didUpdate: { (Void) in
        //                updateForecastView(false)
        //            })
        //        }
        return cell
    }
    
    ///
    /// UICollectionViewDelegate
    ///
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let forecastCell = cell as! ForecastLocationCollectionViewCell
            forecastCell.selected()
            UIView.animate(withDuration: 0.5, animations: {
                forecastCell.unselected()
            })
            
            if (indexPath as NSIndexPath).row == totalCells() - 1 {
                performSegue(withIdentifier: Common.segue.search, sender: nil)
            }
            else if (indexPath as NSIndexPath).row == 0 {
                if let forecastResult = currentForecastResult() {
                    currentForecast = forecastResult
                    performSegue(withIdentifier: Common.segue.forecastDetail, sender: nil)
                }
            }
            //            else if forecastsFiltered.count > 0 {
            //                currentForecast = forecastsFiltered[indexPath.row]
            //                performSegueWithIdentifier(Common.segue.forecastDetail, sender: nil)
            //            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = cellSize
        let viewSize = updateSize.equalTo(CGSize.zero) ? collectionView.frame.size : updateSize
        let itemsInWidth = Int(viewSize!.width / (size?.width)!)
        size!.width = viewSize!.width / CGFloat(itemsInWidth)
        if size!.width >  (cellSize.width * 1.5) {
            size!.width = cellSize.width
        }
        return size!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateSize = size
        collectionView.reloadData()
    }

    /// Notifications
    
    fileprivate func observeNotification()
    {
        unobserveNotification()
        
        let queue = OperationQueue.main
        
        NotificationCenter.default
            .addObserver(forName: NSNotification.Name(rawValue: Common.notification.editing), object: nil, queue: queue,
                                using: { [weak self] note in
                                    if let strong = self {
                                        if let isEditing: Bool = note.object as? Bool {
                                            strong.setEditing(isEditing, animated: true)
                                            strong._forecastsFiltered = nil
                                            strong.collectionView.reloadData()
                                        }
                                    }})
        
        NotificationCenter.default
            .addObserver(forName: NSNotification.Name(rawValue: Common.notification.forecast.updated), object: nil, queue: queue,
                                using: { [weak self] (NSNotification) in
                                    if let strong = self {
                                        strong.updateForecastView(false)
                                    }
                })
    }
    
    fileprivate func unobserveNotification()
    {
        for notification in [Common.notification.location.saved, JFCore.Constants.Notification.locationUpdated,
                             JFCore.Constants.Notification.locationError, JFCore.Constants.Notification.locationAuthorized,
                             Common.notification.editing, Common.notification.forecast.updated] {
                                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification), object: nil);
        }
    }
    
    var forecastsFiltered: [CDForecastResult] {
        if _forecastsFiltered != nil {
            return _forecastsFiltered!
        }
        
        _forecastsFiltered = forecasts.filter { (forecast) -> Bool in
            if isEditing {
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
        UIView.animate(withDuration: 0.3,
           animations: {
                [weak self] in
                self?.collectionView.reloadData()
            },
           completion: {
                [weak self]
                (completed) in
                self?.collectionView.flashScrollIndicators()
        })
    }
    
    fileprivate func updateForecastView(_ showAlert: Bool)
    {
        do {
            currentLocation = try Facade.instance.fetchCurrentLocation()
            
            forecasts = try Facade.instance.fetchForecastResult()
            
            if (showAlert) {
                let alertView = SCLAlertView()
                alertView.addButton(Common.title.Reload) { [weak self] (isOtherButton) in
                    if let strong = self {
                        strong.reloadView()
                    }
                }
                let subtitle = "\(Common.title.successGetting) \(forecasts.count) \(Common.title.forecasts)"
                alertView.showSuccess(Common.title.fetchForecast,
                                      subTitle: subtitle)
            }
            else {
                reloadView()
            }
        }
        catch {
            let e = error
            let alertView = SCLAlertView()
            alertView.addButton(Common.title.Reload) { [weak self] (isOtherButton) in
                if let strong = self {
                    strong.updateForecastView(false)
                }
            }
            alertView.showError(Common.title.fetchForecast, subTitle: e.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Common.segue.forecastDetail {
            let vc:ForecastDetailViewController = segue.destination as! ForecastDetailViewController
            if let _currentForecast = currentForecast {
                vc.detailItem = _currentForecast
                vc.title = _currentForecast.namecheck()
            }
        }
        else if segue.identifier == Common.segue.search {
            let vc:UIViewController = segue.destination
            vc.title = Common.title.Search
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    
}
