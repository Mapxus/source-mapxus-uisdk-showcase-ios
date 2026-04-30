//
//  KeywordSearchHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class KeywordSearchHandler: KeywordSearchEventListener
{
  func onSearchResultCategorySelected(categoryKey: String, categoryName: String, venueId: String?, buildingId: String?) {
    let message = """
        click category on search page
        categoryKey = \(categoryKey)
        categoryName = \(categoryName)
        venueId = \(venueId ?? "")
        buildingId = \(buildingId ?? "")
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSearchResultEventSelected(eventId: String) {
    let message = """
        click event on search page
        eventId = \(eventId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onSearchResultPoiSelected(poiId: String) {
    let message = """
        click poi on search page
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
