//
//  ShareEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class ShareEventHandler: BaseHandler, ShareEventListener {
    func onShareVenue(venueInfo: VenueInfo?, link: String?) {
        showAlert(title: "ShareEvent Listener", message: "onShareVenue(venueInfo: \(venueInfo?.venueId ?? "nil"), link: \(link ?? "nil"))")
    }

    func onShareBuilding(buildingInfo: BuildingInfo?, link: String?) {
        showAlert(title: "ShareEvent Listener", message: "onShareBuilding(buildingInfo: \(buildingInfo?.buildingId ?? "nil"), link: \(link ?? "nil"))")
    }

    func onShareEvent(eventInfo: EventInfo?, link: String?) {
        showAlert(title: "ShareEvent Listener", message: "onShareEvent(eventInfo: \(eventInfo?.eventId ?? "nil"), link: \(link ?? "nil"))")
    }

    func onSharePoi(poiInfo: PoiInfo?, link: String?) {
        showAlert(title: "ShareEvent Listener", message: "onSharePoi(poiInfo: \(poiInfo?.poiId ?? "nil"), link: \(link ?? "nil"))")
    }

    func onShareLocation(locationInfo: LocationInfo?, link: String?) {
        showAlert(title: "ShareEvent Listener", message: "onShareLocation(locationInfo: \(String(describing: locationInfo)), link: \(link ?? "nil"))")
    }
}
