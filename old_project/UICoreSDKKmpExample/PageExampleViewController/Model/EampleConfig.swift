//
//  EampleConfig.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import Foundation


enum VenueType: String {
    case K11Musea = "K11 Musea"

    static func getVenueTypeIndex(_ type: VenueType?) -> Int? {
        var idx: Int?
        switch type {
        case .K11Musea:
            idx = 0
        case .none:
            break
        }
        return idx
    }
}

enum Journeys: String {
    case FullUserJourneys = "Full Journey"
    case OnlyVenue = "Only Venue page"
    case OnlyPOI = "Only POI page"
    case OnlyNavigation = "Only Navigation"
    case OnlyLandingPage = "LandingPage"

    static func getJourneysIdx(_ type: Journeys?) -> Int? {
        var idx: Int?
        switch type {
        case .FullUserJourneys:
            idx = 0
        case .OnlyVenue:
            idx = 1
        case .OnlyPOI:
            idx = 2
        case .OnlyNavigation:
            idx = 3
        case .OnlyLandingPage:
            idx = 4
        case .none:
            break
        }
        return idx
    }
}

enum CustomisedContentType: String {
    case Yes = "Yes"
    case NotForNow = "No（Default）"

    static func getTypeIdx(_ type: CustomisedContentType?) -> Int? {
        var idx: Int?
        switch type {
        case .Yes:
            idx = 0
        case .NotForNow:
            idx = 1
        case .none:
            break
        }
        return idx
    }
}

enum MapStyle: String {
    case Drop_in_ui_25d = "drop_in_ui_v2_25d"
    case Drop_in_ui = "drop_in_ui_v2"
    case Taikwun_v1 = "taiKwun_v1"  // test环境：taiKwun_v3

    static func getTypeIdx(_ type: MapStyle?) -> Int? {
        var idx: Int?
        switch type {
        case .Drop_in_ui_25d:
            idx = 1
        case .Drop_in_ui:
            idx = 0
        case .Taikwun_v1:
            idx = 2
        case .none:
            break
        }
        return idx
    }
}

enum ShowCaseLanguage: String {
    case System = "System Language"
    case English = "English"
    case Traditional = "Traditional"
    case Simplified = "Simplified"
    case Japanese = "Japanese"

    static func getTypeIdx(_ type: ShowCaseLanguage?) -> Int? {
        var idx: Int?
        switch type {
        case .System:
            idx = 0
        case .English:
            idx = 1
        case .Traditional:
            idx = 2
        case .Simplified:
            idx = 3
        case .Japanese:
            idx = 4
        case .none:
            break
        }
        return idx
    }
}

enum ShareTypeDisplay: String  {
    case None = "none"
    case InfoLocation = "info location"
    case Both = "both"
    static func getTypeIdx(_ type: ShareTypeDisplay) -> Int {
        switch type {
        case .None:
            return 0
        case .InfoLocation:
            return 1
        case .Both:
            return 2
        }
    }
}

enum FloorChange: String {
    case IndividualBuilding = "Individual building（默認）"
    case VenueOrdinal = "VenueOrdinal"

    static func getTypeIdx(_ type: FloorChange?) -> Int? {
        var idx: Int?
        switch type {
        case .IndividualBuilding:
            idx = 0
        case .VenueOrdinal:
            idx = 1
        case .none:
            break
        }
        return idx
    }
}


struct EampleConfig {
    static let venyeTypes = [
        VenueType.K11Musea,
    ]

    static let journeyTypes = [Journeys.FullUserJourneys,
                               Journeys.OnlyVenue,
                               Journeys.OnlyPOI,
                               Journeys.OnlyNavigation,
                               Journeys.OnlyLandingPage,
    ]

    static let customisedContentTypes = [CustomisedContentType.Yes,
                                         CustomisedContentType.NotForNow]

    static let mapStyles = [
        MapStyle.Drop_in_ui,
        MapStyle.Drop_in_ui_25d,
        MapStyle.Taikwun_v1,
    ]

    static let languageTypes = [ShowCaseLanguage.System,
                                ShowCaseLanguage.English,
                                ShowCaseLanguage.Traditional,
                                ShowCaseLanguage.Simplified,
                                ShowCaseLanguage.Japanese
    ]
    
    static let shareDisplayModes = [
        ShareTypeDisplay.None,
        ShareTypeDisplay.InfoLocation,
        ShareTypeDisplay.Both
    ]

    static let floorchange = [FloorChange.IndividualBuilding,
                              FloorChange.VenueOrdinal]

    /// 当心，没做数组越界判断
    /// - Parameter idx: <#idx description#>
    /// - Returns: <#description#>
    static func getVenueId(with vType: VenueType) -> String {
        var venueId = ""
        switch vType {
        case .K11Musea:
            venueId = "3cd9b17d-f3f4-4afd-ba34-5e3fad2518a6"
        }

        return venueId
    }


    /// <#Description#>
    /// - Returns: <#description#>
    static func getPoiIds(with vType: VenueType) -> (String, String, String) {
        var poiId = "7349406"
        var start_poiId = "7349406"
        var end_poiId = "7349470"

        switch vType {
        case .K11Musea:
            poiId = "2093364"
            start_poiId = "2093364"
            end_poiId = "7349470"

        default:
            break
        }
        return (poiId, start_poiId, end_poiId)
    }
}
