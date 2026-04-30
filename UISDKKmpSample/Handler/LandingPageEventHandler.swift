//
//  LandingPageEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class LandingPageEventHandler: BaseHandler, LandingPageEventListener {
    // GlobalSearchResultListener
    func useCustomVenuePageForSearchResult() -> Bool { return true }
    func onSearchResultVenueSelected(venueId: String) {
        showAlert(title: "LandingPageEvent Listener", message: "onSearchResultVenueSelected(venueId: \(venueId))")
    }

    func useCustomBuildingPageForSearchResult() -> Bool { return true }
    func onSearchResultBuildingSelected(buildingId: String) {
        showAlert(title: "LandingPageEvent Listener", message: "onSearchResultBuildingSelected(buildingId: \(buildingId))")
    }

    // KeywordSearchResultListener
    func useCustomPoiPageForSearchResult() -> Bool { return true }
    func onSearchResultPoiSelected(poiId: String) {
        showAlert(title: "LandingPageEvent Listener", message: "onSearchResultPoiSelected(poiId: \(poiId))")
    }

    func useCustomEventPageForSearchResult() -> Bool { return true }
    func onSearchResultEventSelected(eventId: String) {
        showAlert(title: "LandingPageEvent Listener", message: "onSearchResultEventSelected(eventId: \(eventId))")
    }

    func useCustomCategoryPageForSearchResult() -> Bool { return true }
    func onSearchResultCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
        showAlert(title: "LandingPageEvent Listener", message: "onSearchResultCategorySelected(categoryKey: \(categoryKey), categoryName: \(categoryName), venueId: \(venueId ?? "nil"), buildingId: \(buildingId ?? "nil"))")
    }

    // LandingPageEventListener own methods
    func useCustomVenuePageForCardSelected() -> Bool { return true }
    func onVenueCardSelected(venueId: String) {
        showAlert(title: "LandingPageEvent Listener", message: "onVenueCardSelected(venueId: \(venueId))")
    }
}
