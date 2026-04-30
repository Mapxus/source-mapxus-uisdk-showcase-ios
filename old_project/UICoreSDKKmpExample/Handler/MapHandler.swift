//
//  MapHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class MapHandler: MapEventListener {
  func onLocationSelected(coordinate: Coordinate) {
    let message = """
        click location on map
        lat = \(coordinate.latitude),
        lon = \(coordinate.longitude)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomLocationPage() -> Bool {
    true
  }
  
  func onVenueSelected(venueId: String) {
    let message = """
        venue click on map
        venueId = \(venueId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomVenuePage() -> Bool {
    true
  }
  
  func onBuildingSelected(buildingId: String) {
    let message = """
        building click on map
        buildingId = \(buildingId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomBuildingPage() -> Bool {
    true
  }
  
  func onPoiSelected(poiId: String) {
    let message = """
    click poi on map
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomPoiPage() -> Bool {
    true
  }
  
  func onEventSelected(eventId: String) {
    let message = """
        event click on map
        eventId = \(eventId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomEventPage() -> Bool {
    true
  }
    
}
