//
//  Common.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import Localize_Swift

let FacadeDidErrorNotification: NSNotification.Name = NSNotification.Name(rawValue: "FacadeDidErrorNotification")
let RequestDidStartNotification: NSNotification.Name = NSNotification.Name(rawValue: "RequestDidStartNotification")
let RequestDidStopNotification: NSNotification.Name = NSNotification.Name(rawValue: "RequestDidStopNotification")
let LocationDidUpdateNotification: NSNotification.Name = NSNotification.Name(rawValue: "LocationDidUpdateNotification")
let ForecastDidUpdateNotification: NSNotification.Name = NSNotification.Name(rawValue: "ForecastDidUpdateNotification")


/*
 *  Common
 *
 *  Discussion:
 *    Some common and global constants.
 */

/// An enumeration to specify codes for error conditions.
struct Common {
    internal enum ErrorCode: Int {
        case cdFetchCurrentPlacemarkIssue = 101
        case cdFetchRequest = 102
        case cdImportMenuArrayIssue = 103
        case cdSearchCurrentLocationIssue = 104
        case cdSearchLocationsIssue = 105
        case cdSearchObject = 106
        case cdSearchPlacemarksIssue = 107
        case cdUpdateForecastModelIssue = 108
        case cdUpdateForecastResultIssue = 109
        case cdUpdateForecastResultOnForecastModelIssue = 110
        case cdUpdateLocationIssue = 111
        case cdUpdateLocationOnPlacemarkIssue = 112
        case cdUpdateLocationOnPlacemarkSaveIssue = 113
        case cdUpdateMenuIssue = 114
        case cdUpdatePlacemarkIssue = 115
        case cdUpdatePlacemarkOnSpotIssue = 116
        case cdUpdateSpotIssue = 117
        case cdUpdateSpotsOwnersIssue = 118
        case cdUpdateTimeWeathertIssue = 119
        case appDidBecomeActiveError = 120
        case fetchHelpMenuIssue = 122
        case fetchRootMenuIssue = 123
        case forecastResultIssue = 124
        case importMenuArrayIssue = 125
        case updateForecastResultIssue = 126
        case updateForecastSpotsResultIssue = 127
        case updatePlacemarksLocationIssue = 128
        case updateSpotsOwnersIssue = 129
        case cdUpdateForecastIssue = 130
        case cdUpdateForecastCreateTimeWeatherIssue = 131
        case cdSearchCurrentForecastModelIssue = 132
        case temperatureByHourIssue = 133
        case cdSearchForecastWithIdentifierModelIssue = 134
        case queryLocationWithPlacemarkIssue = 135
        case fetchLocationIssue = 136
        case fetchPlacemarkIssue = 137
        case facadeRestartIssue = 138
        case firebaseSignInAnonymouslyWithCompletionIssue = 139
        case removeMenuIssue = 140
        case removeLocationIssue = 141
    }
    
    struct font {
        static let name : String = "Weather Icons Regular"
    }

    public struct Symbols {
        // Use https://erikflowers.github.io/weather-icons/
        enum FontWeather : Int {
            case wi_thermometer_exterior = 0xf053
            case wi_humidity = 0xf07a
            case wi_wind_direction = 0xf0b1
            case wi_windy = 0xf021
            case wi_strong_wind = 0xf050
            case wi_wind_beaufort_0 = 0xf0b7
            case wi_wind_beaufort_1 = 0xf0b9
            case wi_wind_beaufort_2 = 0xf0ba
            case wi_wind_beaufort_3 = 0xf0bb
            case wi_wind_beaufort_4 = 0xf0bc
            case wi_wind_beaufort_5 = 0xf0bd
            case wi_wind_beaufort_6 = 0xf0be
            case wi_wind_beaufort_7 = 0xf0bf
            case wi_wind_beaufort_8 = 0xf0b8
            case wi_wind_beaufort_9 = 0xf0c0
            case wi_wind_beaufort_10 = 0xf0c1
            case wi_wind_beaufort_11 = 0xf0c2
            case wi_wind_beaufort_12 = 0xf0c3
            case wi_flood = 0xf07c
            case wi_small_craft_advisory = 0xf0cc
            case wi_cloud = 0xf041
            case wi_rain = 0xf019
            case wi_barometer = 0xf079
            case wi_snowflake_cold = 0xf076
            case wi_time_1 = 0xf08a
            case wi_alien = 0xf075
            case wi_sunrise = 0xf051
            case wi_sunset = 0xf052
            case wi_gale_warning = 0xf0cd
            
        }
        public static func show(icon: FontWeather) -> Character {
            return Character(UnicodeScalar(icon.rawValue) ?? "?")
        }
    }


    static let email : String = "mobilepatagonia@gmail.com"
    struct animation {
        static let duration: Double = 2.0
    }
    
    struct cell {
        struct identifier {
            static let forecast = "ForecastLocationCollectionViewCell"
            static let forecastDayList1 = "ForecastDayListViewCell1"
            static let forecastDayList2 = "ForecastDayListViewCell2"
            static let forecastDayList3 = "ForecastDayListViewCell3"
            static let help : String = "HelpCell"
            static let menu : String = "MenuCell"
            static let option : String = "OptionCell"
            static let root : String = "RootCell"

        }
    }

    struct segue {
        static let about : String = "about"
        static let search : String = "search"
        static let forecastDetail : String = "forecastDetail"
        static let forecastDayList : String = "forecastDayList"
        static let web : String = "web"
    }

    struct image {
        static let background : String = "background"
    }
    
    struct title {
        static let About : String = "About".localized()
        static let Cancel : String = "Cancel".localized()
        static let copyright = "  Copyright © 2015-2017 Mobile Patagonia. All rights reserved.".localized()
        static let done : String = "DONE".localized()
        static let error : String = "Error".localized()
        static let errorOnDelete: String = "Error on delete".localized()
        static let errorOnImport: String = "Error on import".localized()
        static let errorOnSearch: String = "Error on search".localized()
        static let errorOnUpdate: String = "Error on update".localized()
        static let failed : String = "failed".localized()
        static let failedAtFetchForecasts : String = "Failed at fetch forecasts".localized()
        static let failedAtImportObjects : String = "Failed at import objects".localized()
        static let fetchForecast : String = "Fetch Forecast".localized()
        static let Forecast : String = "Forecast".localized()
        static let forecasts : String = "forecasts".localized()
        static let frequentlyAskedQuestions : String = "Frequently Asked Questions".localized()
        static let Help : String = "Help".localized()
        static let LocationNotAuthorized : String = "Location Not Authorized".localized()
        static let LocationUpdatedwith : String = "Location Updated with".localized()
        static let Locationfailed : String = "Location failed".localized()
        static let menu : String = "Menu".localized()
        static let MoreInfo : String = "MoreInfo".localized()
        static let Options : String = "Options".localized()
        static let PleaseAuthorize : String = "Please authorize".localized()
        static let Reload : String = "Reload".localized()
        static let Retry : String = "Retry".localized()
        static let Search : String = "Search".localized()
        static let Servicesfailed : String = "Services failed".localized()
        static let successGetting : String = "Success getting".localized()
        static let TermsAndConditions : String = "Terms and Conditions".localized()
        static let TermsOfUse : String = "Terms of Use".localized()
        static let Tutorial : String = "Tutorial".localized()
    }

}
