//
//  WebViewController.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/30/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import SCLAlertView
import JFCore

class WebViewController: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var web: UIWebView!
    var fileName : String?
    var tokens : [String : String]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let path = NSBundle.mainBundle().pathForResource(Localize.currentLanguage(), ofType: "lproj"),
            let bundle = NSBundle(path: path),
            let name = fileName
        {
            let url = NSURL(fileURLWithPath: bundle.bundlePath + "/" + name)
            var content = try! String(contentsOfURL: url)
            if let tokens = self.tokens {
                for (k,v) in tokens {
                    content = content.stringByReplacingOccurrencesOfString(k, withString: v)
                }
                web.loadHTMLString(content, baseURL: bundle.bundleURL)
            }
            else {
                let request = NSURLRequest(URL: url)
                web.loadRequest(request)
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            if let url = request.URL {
                UIApplication.sharedApplication().openURL(url)
                return false
            }
        }
        return true
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if let e = error {
            SCLAlertView().showError(Common.title.error, subTitle:e.description)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        Facade.instance.spinnerStart()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        Facade.instance.spinnerStop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(#function, line: #line)
    }
    
}
