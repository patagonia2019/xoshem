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
import RealmSwift

class ForecastLocationViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
//    var cellSize: CGSize! = CGSize(width: 191.5, height: 350.0)
//    var updateSize: CGSize! = CGSize.zero
    var forecasts: [RWSpotForecast]!
    var locations: Results<RLocation>?
    var currentForecast: RWSpotForecast?
    let interItemSpacing: CGFloat = 0
    let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

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
    
    
    func cellWidth() -> CGFloat {
        return (collectionView!.bounds.size.width - (interItemSpacing * 2) - edgeInsets.left - edgeInsets.right) / 2
    }
    
    func boardCellSize() -> CGSize {
        return CGSize(width: cellWidth(), height: cellWidth())
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        updateSize = size
        collectionView.reloadData()
    }

    /// Notifications
    
    fileprivate func observeNotification()
    {
        unobserveNotification()
        
        let notiCenter = NotificationCenter.default
        let queue = OperationQueue.main

        notiCenter
            .addObserver(forName: EditDidReceiveNotification, object: nil, queue: queue,
                using: {
                    [weak self] note in
                    if let strong = self {
                        if let isEditing: Bool = note.object as? Bool {
                            strong.setEditing(isEditing, animated: true)
                            strong.collectionView.reloadData()
                        }
                    }})
        
        for notification in [ForecastDidUpdateNotification]
        {
            notiCenter
            .addObserver(forName: notification, object: nil, queue: queue,
                using: {
                    [weak self] (note) in
                    self?.updateForecastView(true)
            })
        }
    }
    
    fileprivate func unobserveNotification()
    {
        for notification in [EditDidReceiveNotification,
                             ForecastDidUpdateNotification]
        {
            NotificationCenter.default.removeObserver(self, name: notification, object: nil)
        }
    }
    
    func reloadView() {
        collectionView.reloadData()
        collectionView.flashScrollIndicators()
    }
    
    func updateForecastView(_ showAlert: Bool)
    {
        do {
            
//            currentLocation = try Facade.instance.fetchCurrentLocation()
            
//            forecasts = try Facade.instance.fetchForecastResult()
            
            if (showAlert) {
                let alertView = SCLAlertView()
                alertView.addButton(Common.title.Reload) {
                    [weak self] (isOtherButton) in
                    self?.reloadView()
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
                vc.detailItem = currentForecast
                vc.title = currentForecast?.spotname
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
