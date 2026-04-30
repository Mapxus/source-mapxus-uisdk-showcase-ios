//
//  RoutePlanningHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class RoutePlanningHandler: RoutePlanningEventListener
{
  func onClose() {
    let message = """
        route planning on close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
}
