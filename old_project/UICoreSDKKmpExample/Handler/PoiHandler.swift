//
//  PoiHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class PoiHandler: PoiEventListener {
  func onClose() {
    let message = """
        poi close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
  func onEventSelected(eventId: String) {
    let message = """
        eventId = \(eventId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomEventPage() -> Bool {
    true
  }
  
  func onDirectionRequested(destination: NavigationPoint) {
    let message = """
        direct on poi page
        lat = \(destination.latitude)
        lon = \(destination.longitude)
        buildingId = \(destination.buildingId ?? "")
        shareFloorId = \(destination.sharedFloorId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomDirectionPage() -> Bool {
    true
  }
    
}
