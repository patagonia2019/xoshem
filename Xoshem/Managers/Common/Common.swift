//
//  Common.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.
//

import Foundation
import Localize_Swift

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
        case cdRemoveMenuIssue = 140
    }

    struct notification {
        static let editing : String = "notification.editing"
        struct location {
            static let saved : String = "notification.location.saved"
        }
        struct forecast {
            static let updated : String = "notification.forecast.updated"
        }
        struct spinner {
            static let start : String = "notification.spinner.start"
            static let stop : String = "notification.spinner.stop"
        }
    }


    static let kJFGroup : String = "group.fuchs.schuf.Xoshem"
    static let email : String = "xoshem.fuchs@gmail.com"
    struct animation {
        static let duration: Double = 2.0
    }
    
    struct cell {
        struct identifier {
            static let forecast = "ForecastLocationCollectionViewCell"
            static let forecastDayList = "ForecastDayListViewCell"
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
    
    struct file {
        static let faq : String = "FAQ.html"
        static let tou : String = "TermsOfUse.html"
        static let tac : String = "TermsAndConditions.html"
        static let tutorial : String = "Tutorial.html"
        static let about : String = "About.html"
    }

    struct title {
        static let About : String = "About".localized()
        static let Cancel : String = "Cancel".localized()
        static let copyright = "  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.".localized()
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
