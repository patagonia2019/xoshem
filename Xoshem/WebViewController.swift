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

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var web: UIWebView!
    var fileName : String?
    var tokens : [String : String]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
    func load() {
        if let path = Bundle.main.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path),
            let name = fileName
        {
            let url = URL(fileURLWithPath: bundle.bundlePath + "/" + name)
            var content = try! String(contentsOf: url, encoding: String.Encoding.utf8)
            if let tokens = tokens {
                for (k,v) in tokens {
                    content = content.replacingOccurrences(of: k, with: v)
                }
                web.loadHTMLString(content, baseURL: bundle.bundleURL)
            }
            else {
                let request = URLRequest(url: url)
                web.loadRequest(request)
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            if let url = request.url {
                UIApplication.shared.openURL(url)
                return false
            }
        }
        return true
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        showError(error: error)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    
    func showError(error : Error?, showMore: Bool = false) {
        let alert = SCLAlertView()
        alert.addButton(Common.title.Cancel) {
        }
        alert.addButton(Common.title.MoreInfo) {[weak self] in
            self?.showError(error: error, showMore: true)
        }
        alert.addButton(Common.title.Retry) { [weak self] in
            self?.load()
        }
        
        if let e : JFError = error as? JFError {
            alert.showError(e.title(), subTitle: showMore ? e.debugDescription : e.reason())
        } else if let ldesc = error?.localizedDescription {
            alert.showError(Common.title.error, subTitle: showMore ? error.debugDescription : ldesc)
        } else {
            alert.showError(Common.title.error, subTitle: error.debugDescription)
        }
    }
    
}
