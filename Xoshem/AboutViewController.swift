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
        self.title = Common.title.About
        super.viewDidLoad()
        let dic = NSProcessInfo.processInfo().environment
        if let tokens = self.aboutTokens() {
            self.tokens = tokens
        }

    }
    
    func aboutTokens() -> [String : String]? {
        if let info = NSBundle.mainBundle().infoDictionary,
           let bundleName = info["CFBundleName"] as? String,
           let bundleShortVersion = info["CFBundleShortVersionString"] as? String,
           let bundleVersion = info["CFBundleVersion"] as? String,
           let date = Facade.instance.lastRefreshDate ?? "-"
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
