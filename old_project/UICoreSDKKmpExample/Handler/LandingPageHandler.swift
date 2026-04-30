//
//  LandingPageHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class LandingPageHandler: LandingPageEventListener {
  func onVenueCardSelected(venueId: String) {
    let message = """
        on venue card click
        venueId = \(venueId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomVenuePageForCardSelected() -> Bool {
    true
  }
  
  func onSearchResultBuildingSelected(buildingId: String) {
    let message = """
        on building click
        buildingId = \(buildingId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSearchResultVenueSelected(venueId: String) {
    let message = """
        on venue click
        venueId = \(venueId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomBuildingPageForSearchResult() -> Bool {
    true
  }
  
  func useCustomVenuePageForSearchResult() -> Bool {
    true
  }
  
  func onSearchResultCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
    let message = """
        click category on landing page
        categoryKey = \(categoryKey)
        categoryName = \(categoryName)
        venueId = \(venueId ?? "")
        buildingId = \(buildingId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSearchResultEventSelected(eventId: String) {
    let message = """
        eventId = \(eventId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSearchResultPoiSelected(poiId: String) {
    let message = """
        on poi click
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCategoryPageForSearchResult() -> Bool {
    true
  }
  
  func useCustomEventPageForSearchResult() -> Bool {
    true
  }
  
  func useCustomPoiPageForSearchResult() -> Bool {
    true
  }
    
}
