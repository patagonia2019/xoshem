//
//  Auth.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/5/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

#if os(iOS)
    import DigitsKit
#endif

class Auth {
    
    #if os(watchOS)
    func login() {
    }
    #else
    var session: DGTSession!

    func loginWithView(view:UIView, blockWithError:(error: Error) -> Void, blockWithSuccess:() -> Void) {
        let authButton = DGTAuthenticateButton(authenticationCompletion: { [weak self]  (session: DGTSession?, error: NSError?) in
            if let e = error {
                let myerror = Error(code: Common.ErrorCode.FacadeRestartIssue.rawValue,
                    desc: "Failed at authenticate using Digits",
                    reason: "Error on start Facade",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: e)
                Analytics.logError(myerror)
                blockWithError(error: myerror)
            }
            else if let s = session {
                guard let strong = self else {
                    return
                }

                strong.session = s
                // TODO: associate the session userID with your user model
                NSLog("Phone number: \(s.phoneNumber)")
                NSLog("user id: \(s.userID)")
                NSLog("email address: \(s.emailAddress)")
                NSLog("email address is verified: \(s.emailAddressIsVerified)")
                NSLog("auth token: \(s.authToken)")
                NSLog("auth token secret: \(s.authTokenSecret)")
                blockWithSuccess()
            } else {
                NSLog("Some other authentication error")
            }
        })
        authButton.center = view.center
        view.addSubview(authButton)
    }
    
    func userId() -> String? {
        return self.session.userID
    }
    
    func emailAddress() -> String? {
        return self.session.emailAddress
    }
    
    #endif
    
    func start() {
        #if os(iOS)
        Digits.sharedInstance().startWithConsumerKey("your_key", consumerSecret: "your_secret")
        #endif
    }
}
