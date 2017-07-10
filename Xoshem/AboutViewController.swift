//
//  AboutViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 9/15/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: WebViewController {
    
    override func viewDidLoad() {
        title = Common.title.About
        super.viewDidLoad()
//        let dic = ProcessInfo.processInfo.environment
        if let tks = aboutTokens() {
            tokens = tks
        }

    }
    
    func aboutTokens() -> [String : String]? {
        let date = Facade.instance.lastRefreshDate ?? Date.init()
        if let info = Bundle.main.infoDictionary,
           let bundleName = info["CFBundleName"] as? String,
           let bundleShortVersion = info["CFBundleShortVersionString"] as? String,
           let bundleVersion = info["CFBundleVersion"] as? String
        {
           return [
                "<ABOUT_APPNAME>": bundleName,
                "<ABOUT_COPYRIGHT>": Common.title.copyright,
                "<ABOUT_VERSION>": bundleShortVersion,
                "<ABOUT_BUILDNUMBER>": bundleVersion,
                "<ABOUT_LASTREFRESHED>": "\(date)",
                "<ABOUT_EMAILCONTACT>": Common.email
            ]
        }
        return nil
    }
}
