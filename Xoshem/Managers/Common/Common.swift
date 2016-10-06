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
        case CDFetchCurrentPlacemarkIssue = 101
        case CDFetchRequest = 102
        case CDImportMenuArrayIssue = 103
        case CDSearchCurrentLocationIssue = 104
        case CDSearchLocationsIssue = 105
        case CDSearchObject = 106
        case CDSearchPlacemarksIssue = 107
        case CDUpdateForecastModelIssue = 108
        case CDUpdateForecastResultIssue = 109
        case CDUpdateForecastResultOnForecastModelIssue = 110
        case CDUpdateLocationIssue = 111
        case CDUpdateLocationOnPlacemarkIssue = 112
        case CDUpdateLocationOnPlacemarkSaveIssue = 113
        case CDUpdateMenuIssue = 114
        case CDUpdatePlacemarkIssue = 115
        case CDUpdatePlacemarkOnSpotIssue = 116
        case CDUpdateSpotIssue = 117
        case CDUpdateSpotsOwnersIssue = 118
        case CDUpdateTimeWeathertIssue = 119
        case AppDidBecomeActiveError = 120
        case FetchHelpMenuIssue = 122
        case FetchRootMenuIssue = 123
        case ForecastResultIssue = 124
        case ImportMenuArrayIssue = 125
        case UpdateForecastResultIssue = 126
        case UpdateForecastSpotsResultIssue = 127
        case UpdatePlacemarksLocationIssue = 128
        case UpdateSpotsOwnersIssue = 129
        case CDUpdateForecastIssue = 130
        case CDUpdateForecastCreateTimeWeatherIssue = 131
        case CDSearchCurrentForecastModelIssue = 132
        case TemperatureByHourIssue = 133
        case CDSearchForecastWithIdentifierModelIssue = 134
        case QueryLocationWithPlacemarkIssue = 135
        case FetchLocationIssue = 136
        case FetchPlacemarkIssue = 137
        case FacadeRestartIssue = 138
        case FirebaseSignInAnonymouslyWithCompletionIssue = 139
        case CDRemoveMenuIssue = 140
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
        static let About : String = "About".Localized()
        static let Cancel : String = "Cancel".Localized()
        static let copyright = "  Copyright © 2015-2016 Mobile Patagonia. All rights reserved.".Localized()
        static let done : String = "DONE".Localized()
        static let error : String = "Error".Localized()
        static let errorOnDelete: String = "Error on delete".Localized()
        static let errorOnImport: String = "Error on import".Localized()
        static let errorOnSearch: String = "Error on search".Localized()
        static let errorOnUpdate: String = "Error on update".Localized()
        static let failed : String = "failed".Localized()
        static let failedAtFetchForecasts : String = "Failed at fetch forecasts".Localized()
        static let failedAtImportObjects : String = "Failed at import objects".Localized()
        static let fetchForecast : String = "Fetch Forecast".Localized()
        static let Forecast : String = "Forecast".Localized()
        static let forecasts : String = "forecasts".Localized()
        static let frequentlyAskedQuestions : String = "Frequently Asked Questions".Localized()
        static let Help : String = "Help".Localized()
        static let LocationNotAuthorized : String = "Location Not Authorized".Localized()
        static let LocationUpdatedwith : String = "Location Updated with".Localized()
        static let Locationfailed : String = "Location failed".Localized()
        static let menu : String = "Menu".Localized()
        static let Options : String = "Options".Localized()
        static let PleaseAuthorize : String = "Please authorize".Localized()
        static let Reload : String = "Reload".Localized()
        static let Retry : String = "Retry".Localized()
        static let Search : String = "Search".Localized()
        static let Servicesfailed : String = "Services failed".Localized()
        static let successGetting : String = "Success getting".Localized()
        static let TermsAndConditions : String = "Terms and Conditions".Localized()
        static let TermsOfUse : String = "Terms of Use".Localized()
        static let Tutorial : String = "Tutorial".Localized()
    }

}
