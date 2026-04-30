//
//  ShareHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class ShareHandler: ShareEventListener {
  
  func onShareBuilding(buildingInfo: BuildingInfo?, link: String?) {
    let message = """
            buildingId = \(buildingInfo?.buildingId),
            link = \(link),
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onShareEvent(eventInfo: EventInfo?, link: String?) {
    let message = """
            eventId = \(eventInfo?.eventId),
            event name = \(eventInfo?.eventName),
            link = \(link),
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onShareLocation(locationInfo: LocationInfo?, link: String?) {
    let message = """
            venueId = \(locationInfo?.venueId),
            lat = \(locationInfo?.latitude),
            lon = \(locationInfo?.longitude)
            link = \(link),
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSharePoi(poiInfo: PoiInfo?, link: String?) {
    let message = """
            poiId = \(poiInfo?.poiId),
            poiName = \(poiInfo?.poiName),
            shareFloorId = \(poiInfo?.sharedFloorId ?? ""),
            shareFloorName = \(poiInfo?.sharedFloorName ?? ""),
            link = \(link),
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onShareVenue(venueInfo: VenueInfo?, link: String?) {
    let message = """
            venueId = \(venueInfo?.venueId),
            venue name = \(venueInfo?.venueName),
            link = \(link),
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onClose(param: Any?) {
    let message = """
            close
        """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
}
