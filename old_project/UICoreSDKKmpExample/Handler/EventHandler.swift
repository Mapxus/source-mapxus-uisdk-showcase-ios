//
//  EventHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class EventHandler: EventListener
{
  func onClose() {
    let message = """
        close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
  func onPoiSelected(poiId: String) {
    let message = """
        click poi on event page
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomPoiPage() -> Bool {
    true
  }
  
  func onDirectionRequested(destination: NavigationPoint) {
    let message = """
        direct on event page
        lat = \(destination.latitude)
        lon = \(destination.longitude)
        venueId = \(destination.venueId ?? "")
        buildingId = \(destination.buildingId ?? "")
        floorId = \(destination.floorId ?? "")
        shareFloorId = \(destination.sharedFloorId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomDirectionPage() -> Bool {
    true
  }

}
