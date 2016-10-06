//
//  DetailViewController.swift
//  md
//
//  Created by Javier Fuchs on 7/8/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

class DetailViewController: BaseViewController {

    @IBOutlet weak var forecastContainer: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var helpContainer: UIView!

    var detailItem: CDMenu? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail.name
            self.updateRightBarButtonItem(false)
            self.showComponent(Int(detail.id))
        }
    }

    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        if self.detailItem == nil {
            self.detailItem = Facade.instance.fetchRootMenu()[0] as CDMenu
        }
        self.configureView()
        super.viewDidLoad()
    }
    
    func showComponent(id: Int) {
        let array = [forecastContainer, searchContainer, helpContainer, helpContainer]
        
        for subview in array {
            if subview != nil {
                subview.alpha = 0
            }
        }

        if let subview = array[id-1] {
            UIView.animateWithDuration(0.5, animations: {
                subview.alpha = 1
            })
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notification.editing, object: editing)
    }
    
    func updateRightBarButtonItem(showSpinner:Bool) {
        
        if showSpinner {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinnerView)
        }
        else if let detailItem = self.detailItem {
            self.navigationItem.rightBarButtonItem = detailItem.edit ? self.editButtonItem() : nil
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    var spinnerButton: UIBarButtonItem {
        if _spinnerButton != nil {
            return _spinnerButton!
        }
        _spinnerButton = UIBarButtonItem(customView: self.spinnerView)
        self.spinnerView.sizeToFit()

        return _spinnerButton!
    }
    var _spinnerButton: UIBarButtonItem? = nil


    var spinnerView: SpinnerView {
        if _spinnerView != nil {
            return _spinnerView!
        }
        _spinnerView = SpinnerView(frame: CGRectMake(0,0,45,45))
        _spinnerView!.sizeToFit()

        return _spinnerView!
    }
    var _spinnerView: SpinnerView? = nil

    private func observeSpinner()
    {
        self.unobserveSpinner()
        
        let queue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(Common.notification.spinner.start, object: nil, queue: queue) {
            (NSNotification) in
            self.updateRightBarButtonItem(true)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(Common.notification.spinner.stop, object: nil, queue: queue) {
            (NSNotification) in
            self.updateRightBarButtonItem(false)
        }
    }
    
    private func unobserveSpinner()
    {
        for notification in [Common.notification.spinner.start, Common.notification.spinner.stop] {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: notification, object: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }


}

