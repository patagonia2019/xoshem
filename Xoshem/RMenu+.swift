//
//  RMenu+SwiftIconFont.swift
//  Xoshem
//
//  Created by Javier Fuchs on 10/3/16.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import SwiftIconFont
import RealmSwift
import JFCore

extension RMenu {
    
    class func fetchRoot() throws -> Results<RMenu>? {
        let realm = try Realm()
        var objects = realm.objects(RMenu.self).filter("parentId = 0")
        if objects.count == 0 {
            try RMenu.create()
            objects = realm.objects(RMenu.self).filter("parentId = 0")
        }
        return objects
    }
    
    class func fetchHelp() throws -> Results<RMenu>? {
        let realm = try Realm()
        var objects = realm.objects(RMenu.self).filter("parentId = 4")
        if objects.count == 0 {
            try RMenu.create()
            objects = realm.objects(RMenu.self).filter("parentId = 4")
        }
        return objects
    }

    var iconFont: Fonts? {
        switch iconList {
        case "FontAwesome":
            return .FontAwesome
        case "open-iconic":
            return .Iconic
        case "Ionicons":
            return .Ionicon
        case "octicons":
            return .Octicon
        case "themify":
            return .Themify
        case "map-icons":
            return .MapIcon
        case "MaterialIcons-Regular":
            return .MaterialIcon
        default:
            return nil
        }
    }
    
    
    class func create() throws {
        
        let menuArray : [[String: AnyObject]] = [
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(1) as AnyObject,
                "name": Common.title.Forecast as AnyObject,
                "icon": "1468046481_cloud-weather-forecast-cloudy-outline-stroke" as AnyObject,
                "iconList": "themify" as AnyObject,
                "iconName": "cloud" as AnyObject,
                "edit": Bool(true) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(2) as AnyObject,
                "name": Common.title.Search as AnyObject,
                "icon": "1468046237_common-search-lookup-glyph" as AnyObject,
                "iconList": "FontAwesome" as AnyObject,
                "iconName": "search" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(3) as AnyObject,
                "name": Common.title.Options as AnyObject,
                "icon": "1468046524_editor-setting-gear-outline-stroke" as AnyObject,
                "iconList": "FontAwesome" as AnyObject,
                "iconName": "gear" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(0) as AnyObject,
                "id": Int(4) as AnyObject,
                "name": Common.title.Help as AnyObject,
                "icon": "1468046356_circle-help-question-mark-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "help-circled" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(1) as AnyObject,
                "name": Common.title.frequentlyAskedQuestions as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.faq as AnyObject,
                "icon": "1468046956_common-bookmark-book-open-glyph" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "ios-book-outline" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(2) as AnyObject,
                "name": Common.title.Tutorial as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tutorial as AnyObject,
                "icon": "1475082499_device-board-presentation-content-chart-outline-stroke" as AnyObject,
                "iconList": "octicons" as AnyObject,
                "iconName": "device-desktop" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(3) as AnyObject,
                "name": Common.title.TermsOfUse as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tou as AnyObject,
                "icon": "1468046901_editor-books-library-collection-glyph" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "bowtie" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(4) as AnyObject,
                "name": Common.title.TermsAndConditions as AnyObject,
                "segue": Common.segue.web as AnyObject,
                "file": Common.file.tac as AnyObject,
                "icon": "1468046859_business-tie-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "bowtie" as AnyObject,
                "edit": Bool(false) as AnyObject
            ],
            [
                "parentId": Int(4) as AnyObject,
                "id": Int(5) as AnyObject,
                "name": "\(Common.title.About) \(JFCore.Common.app)" as AnyObject,
                "segue": Common.segue.about as AnyObject,
                "file": Common.file.about as AnyObject,
                "icon": "1468046733_circle-info-more-information-detail-outline-stroke" as AnyObject,
                "iconList": "Ionicons" as AnyObject,
                "iconName": "ios-information-outline" as AnyObject,
                "edit": Bool(false) as AnyObject
            ]
        ]
        
        /*
         Create a context on a private queue to:
         - Fetch existing menus to compare with incoming data.
         - Create new menus as required.
         */
        
        do {
            let realm = try Realm()
            try realm.write {
                for menu in menuArray {
                    realm.create(RMenu.self, value: menu)
                }
            }
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.importMenuArrayIssue.rawValue,
                                  desc: Common.title.errorOnImport,
                                  reason: "Error on CDMenu",
                                  suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
    
    class func removeAll() throws {
        do {
            let realm = try Realm()
            let objects = realm.objects(RMenu.self)
            if objects.count > 0 {
                try realm.write {
                    realm.delete(objects)
                }
            }
        }
        catch {
            let myerror = JFError(code: Common.ErrorCode.cdRemoveMenuIssue.rawValue,
                                  desc: Common.title.errorOnDelete,
                                  reason: "Failed at fetch menu and remove",
                                  suggestion: "\(#file):\(#line):\(#column):\(#function)", underError: error as NSError)
            Analytics.logError(error: myerror)
            throw myerror
        }
    }
    
}
