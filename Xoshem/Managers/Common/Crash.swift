//
//  Crash.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/5/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
#if os(iOS)
    import Fabric
    import Crashlytics
    import DigitsKit
#endif
import JFCore

class Crash {

    class func start() {
    #if os(iOS)
        Fabric.with([Crashlytics.self, Digits.self])
        Fabric.sharedSDK().debug = true
        let selector = #selector(logCustomEventWithName(_:customAttributes:))
        let cl : AnyClass = Answers.classForCoder()
        Analytics.configureWithAnalyticsTarget(cl, selector: selector)
    #endif
    }
    
    @objc class func logCustomEventWithName(event: String, customAttributes:[String : AnyObject]?) {
        assert(false, "not implemented")
    }
    
    func logUser(id: String, email: String, userName: String) {
    #if os(iOS)
        Crashlytics.sharedInstance().setUserIdentifier(id)
        Crashlytics.sharedInstance().setUserName(userName)
        Crashlytics.sharedInstance().setUserEmail(email)
    #endif
    }
    
    func crash() {
    #if os(iOS)
        Crashlytics.sharedInstance().crash()
    #endif
    }

}
