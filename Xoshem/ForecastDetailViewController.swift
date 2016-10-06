//
//  ForecastDetailViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 7/14/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

class ForecastDetailViewController: BaseViewController {

    @IBOutlet weak var dayListContainer: UIView!
    @IBOutlet weak var hierarchyContainer: UIView!
    
    var detailItem: CDForecastResult? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail.namecheck()
        }
        self.showComponent(2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    func showComponent(id: Int) {
        let array = [dayListContainer, hierarchyContainer]
        
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Common.segue.forecastDayList {
            let connectContainerViewController = segue.destinationViewController as! ForecastDayListViewController
            connectContainerViewController.forecastResult = self.detailItem
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }
    

}

