//
//  NavigationHandler.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/13.
//

import UIKit
import Foundation
import DropInUISDK

class NavigationHandler: NavigationEventListener {
  func onNavigationCompleted() {
    let message = """
        navigation end 
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onNavigationStarted() {
    let message = """
        navigation start 
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func onClose() {
    let message = """
        navigation on close
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
  
  func useCustomCloseAction() -> Bool {
    true
  }
  
}
