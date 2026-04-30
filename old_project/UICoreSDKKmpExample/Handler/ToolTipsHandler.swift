//
//  ToolTipsHandler.swift
//  UICoreSDKKmpExample
//
//  Created by guochenghao on 2025/6/5.
//

import UIKit
import DropInUISDK

class ToolTipsHandler: ToolTipsListener {
  func onToolTipsSequenceCompleted() {
    let message = """
      Tool Tips Sequence Completed 
    """
    UIViewController.topViewController()?.showAlert(title: "", message: message)
  }
}
