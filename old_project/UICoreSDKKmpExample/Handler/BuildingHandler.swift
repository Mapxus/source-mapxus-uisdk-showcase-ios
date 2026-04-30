//
//  BuildingHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import Foundation
import DropInUISDK
import UIKit

class BuildingHandler: BuildingEventListener {
  func onClose() {
    let message = """
        building on close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
  func onPoiSelected(poiId: String) {
    let message = """
        on poi Click
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
    let message = """
        on Category Click
        categoryKey = \(categoryKey)
        categoryName = \(categoryName)
        venueId = \(venueId ?? "")
        buildingId = \(buildingId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onKeywordSearchRequested(venueId: String) {
    let message = """
        on keyword search click
        venueId = \(venueId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onDirectionRequested(destination: NavigationPoint) {
    let message = """
        on Direction Click
        lat = \(destination.latitude)
        lon = \(destination.longitude)
        buildingId = \(destination.buildingId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomPoiPage() -> Bool {
    true
  }
  
  func useCustomClose() -> Bool {
    true
  }
  
  func useCustomCategoryPage() -> Bool {
    true
  }
  
  func useCustomDirectionPage() -> Bool {
    true
  }
  
  func useCustomEventPage() -> Bool {
    true
  }
  
  func useCustomKeywordSearch() -> Bool {
    true
  }
  
}
