//
//  MenuHandler.swift
//  UICoreSDKKmpExample
//
//  Created by guochenghao on 2025/9/25.
//

import Foundation
import DropInUISDK
import UIKit

class MenuHandler: MenuEventListener {
    
    
    func onClose() {
        let message = """
            menu on close
        """
        UIViewController.topViewController()?.showAlert(title: "", message: message)
    }
    
    func useCustomCloseAction() -> Bool {
        true
    }
}
