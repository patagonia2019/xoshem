//
//  DetailViewController.swift
//  md
//
//  Created by Javier Fuchs on 7/8/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

let EditDidReceiveNotification: NSNotification.Name = NSNotification.Name(rawValue: "EditDidReceiveNotification")

class DetailViewController: UIViewController {

    @IBOutlet weak var forecastContainer: UIView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var helpContainer: UIView!

    var detailItem: RMenu? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            title = detail.name
            updateRightBarButtonItem()
            showComponent(Int(detail.id))
        }
    }

    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        if detailItem == nil {
            if let menus = try! RMenu.fetchRoot() {
                detailItem = menus[0]
            }
        }
        configureView()
        super.viewDidLoad()
    }
    
    func showComponent(_ id: Int) {
        let array = [forecastContainer, searchContainer, helpContainer, helpContainer]
        
        for subview in array {
            if subview != nil {
                subview?.alpha = 0
            }
        }

        if let subview = array[id-1] {
            UIView.animate(withDuration: 0.5, animations: {
                subview.alpha = 1
            })
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        NotificationCenter.default.post(name: EditDidReceiveNotification, object: editing)
    }
    
    func updateRightBarButtonItem() {
        
        if let detailItem = detailItem {
            navigationItem.rightBarButtonItem = detailItem.edit ? editButtonItem : nil
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }


}

