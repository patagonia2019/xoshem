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

    func loginWithView(_ view:UIView, blockWithError:@escaping (_ error: Error) -> Void, blockWithSuccess:@escaping () -> Void) {
        let authButton = DGTAuthenticateButton(authenticationCompletion: { [weak self]  (session: DGTSession?, error: NSError?) in
            if let e = error {
                let myerror = JFError(code: Common.ErrorCode.facadeRestartIssue.rawValue,
                    desc: "Failed at authenticate using Digits",
                    reason: "Error on start Facade",
                    suggestion: "\(#function)", path: "\(#file)", line: "\(#line)", underError: e)
                Analytics.logError(error: myerror)
                blockWithError(myerror)
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
        } as! DGTAuthenticationCompletion)
        authButton?.center = view.center
        view.addSubview(authButton!)
    }
    
    func userId() -> String? {
        return session.userID
    }
    
    func emailAddress() -> String? {
        return session.emailAddress
    }
    
    #endif
    
    func start() {
        #if os(iOS)
        Digits.sharedInstance().start(withConsumerKey: "your_key", consumerSecret: "your_secret")
        #endif
    }
}
