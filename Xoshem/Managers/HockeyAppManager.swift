//
//  HockeyAppManager.swift
//  Xoshem
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 Fuchs. All rights reserved.
//

import Foundation
import HockeySDK

class HockeyAppManager : NSObject {
    
    /// A singleton instance of GoogleManager.
    static let instance = HockeyAppManager()
    
    override private init() {
        super.init()
    }
    
    deinit {
    }
    
    func configure() {
        // Initialize sign-in
        BITHockeyManager.shared().configure(withIdentifier: "251f463dea784742887085836e10039a")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().crashManager.crashManagerStatus = .autoSend
        BITHockeyManager.shared().logLevel = .debug
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
}

