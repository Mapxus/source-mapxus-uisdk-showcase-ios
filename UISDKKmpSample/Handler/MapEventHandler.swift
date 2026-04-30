//
//  MapEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class MapEventHandler: BaseHandler, MapEventListener {
    func useCustomVenuePage() -> Bool { return true }
    func onVenueSelected(venueId: String) {
        showAlert(title: "MapEvent Listener", message: "onVenueSelected(venueId: \(venueId))")
    }

    func useCustomBuildingPage() -> Bool { return true }
    func onBuildingSelected(buildingId: String) {
        showAlert(title: "MapEvent Listener", message: "onBuildingSelected(buildingId: \(buildingId))")
    }

    func useCustomPoiPage() -> Bool { return true }
    func onPoiSelected(poiId: String) {
        showAlert(title: "MapEvent Listener", message: "onPoiSelected(poiId: \(poiId))")
    }

    func useCustomEventPage() -> Bool { return true }
    func onEventSelected(eventId: String) {
        showAlert(title: "MapEvent Listener", message: "onEventSelected(eventId: \(eventId))")
    }

    func useCustomLocationPage() -> Bool { return true }
    func onLocationSelected(coordinate: Coordinate) {
        showAlert(title: "MapEvent Listener", message: "onLocationSelected(coordinate: \(coordinate))")
    }
}
