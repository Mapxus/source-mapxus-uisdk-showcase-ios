//
//  VenueEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class VenueEventHandler: BaseHandler, VenueEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "VenueEvent Listener", message: "onClose")
    }

    func useCustomBuildingPage() -> Bool { return true }
    func onBuildingSelected(buildingId: String) {
        showAlert(title: "VenueEvent Listener", message: "onBuildingSelected(buildingId: \(buildingId))")
    }

    func useCustomPoiPage() -> Bool { return true }
    func onPoiSelected(poiId: String) {
        showAlert(title: "VenueEvent Listener", message: "onPoiSelected(poiId: \(poiId))")
    }

    func useCustomCategoryPage() -> Bool { return true }
    func onCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
        showAlert(title: "VenueEvent Listener", message: "onCategorySelected(categoryKey: \(categoryKey), categoryName: \(categoryName), venueId: \(venueId ?? "nil"), buildingId: \(buildingId ?? "nil"))")
    }

    func useCustomKeywordSearch() -> Bool { return true }
    func onKeywordSearchRequested(venueId: String) {
        showAlert(title: "VenueEvent Listener", message: "onKeywordSearchRequested(venueId: \(venueId))")
    }
}
