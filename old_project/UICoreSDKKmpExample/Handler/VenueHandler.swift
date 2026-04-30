//
//  VenueHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class VenueHandler: VenueEventListener {
  func onClose() {
    let message = """
        venue on close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
  func onBuildingSelected(buildingId: String) {
    let message = """
        on building click
        buildingId = \(buildingId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomBuildingPage() -> Bool {
    true
  }
  
  func onPoiSelected(poiId: String) {
    let message = """
        on poi click
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomPoiPage() -> Bool {
    true
  }
  
  func onCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
    let message = """
        on category click
        categoryKey = \(categoryKey)
        categoryName = \(categoryName)
        venueId = \(venueId ?? "")
        buildingId = \(buildingId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCategoryPage() -> Bool {
    true
  }
  
  func onKeywordSearchRequested(venueId: String) {
    let message = """
        on keyword search click
        venueId = \(venueId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomKeywordSearch() -> Bool {
    true
  }
}
