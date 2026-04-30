//
//  KeywordSearchEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class KeywordSearchEventHandler: BaseHandler, KeywordSearchEventListener {
    func useCustomPoiPageForSearchResult() -> Bool { return true }
    func onSearchResultPoiSelected(poiId: String) {
        showAlert(title: "KeywordSearchEvent Listener", message: "onSearchResultPoiSelected(poiId: \(poiId))")
    }

    func useCustomEventPageForSearchResult() -> Bool { return true }
    func onSearchResultEventSelected(eventId: String) {
        showAlert(title: "KeywordSearchEvent Listener", message: "onSearchResultEventSelected(eventId: \(eventId))")
    }

    func useCustomCategoryPageForSearchResult() -> Bool { return true }
    func onSearchResultCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
        showAlert(title: "KeywordSearchEvent Listener", message: "onSearchResultCategorySelected(categoryKey: \(categoryKey), categoryName: \(categoryName), venueId: \(venueId ?? "nil"), buildingId: \(buildingId ?? "nil"))")
    }
}
