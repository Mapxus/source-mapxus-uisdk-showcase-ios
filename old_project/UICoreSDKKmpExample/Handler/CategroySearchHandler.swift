//
//  CategroySearchHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class CategroySearchHandler: CategorySearchEventListener
{
  func onClose() {
    let message = """
        category on close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
  func onPoiSelected(poiId: String) {
    let message = """
        on category click poi
        poiId = \(poiId)
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomPoiPage() -> Bool {
    true
  }
}
