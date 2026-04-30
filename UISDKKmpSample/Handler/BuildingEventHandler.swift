//
//  BuildingEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class BuildingEventHandler: BaseHandler, BuildingEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "BuildingEvent Listener", message: "onClose")
    }

    func useCustomPoiPage() -> Bool { return true }
    func onPoiSelected(poiId: String) {
        showAlert(title: "BuildingEvent Listener", message: "onPoiSelected(poiId: \(poiId))")
    }

    func useCustomCategoryPage() -> Bool { return true }
    func onCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
        showAlert(title: "BuildingEvent Listener", message: "onCategorySelected(categoryKey: \(categoryKey), categoryName: \(categoryName), venueId: \(venueId ?? "nil"), buildingId: \(buildingId ?? "nil"))")
    }

    func useCustomKeywordSearch() -> Bool { return true }
    func onKeywordSearchRequested(venueId: String) {
        showAlert(title: "BuildingEvent Listener", message: "onKeywordSearchRequested(venueId: \(venueId))")
    }

    func useCustomDirectionPage() -> Bool { return true }
    func onDirectionRequested(destination: NavigationPoint) {
        showAlert(title: "BuildingEvent Listener", message: "onDirectionRequested(destination: \(destination))")
    }
}
