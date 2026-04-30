//
//  DataTrackingHandler.swift
//  UICoreSDKKmpExample
//
//  Created by guochenghao on 2025/11/24.
//

import UIKit
import DropInUISDK

class DataTrackingHandler: DataTrackingListener {
    func onDirectionButtonClicked(data: EntityClickData) {
        var type: String = ""
        switch data.type {
        case .poi:
            type = "poi"
            
        case .building:
            type = "building"

        case .event:
            type = "event"

        case .custom:
            type = "custom"
       
        }
        let message = """
            click DirectionButton
            type = \(type)
            id = \(String(describing: data.id))
            name = \(String(describing: data.name))
        """
        UIViewController.topViewController()?.showAlert(title: "", message: message)
    }
    
    func onEndOfRouteCardShown() {
        let message = """
            onEndOfRouteCardShown
        """
        UIViewController.topViewController()?.showAlert(title: "", message: message)
    }
    
    func onStartNavigationClicked(data: EntityClickData) {
        var type: String = ""
        switch data.type {
        case .poi:
            type = "poi"
            
        case .building:
            type = "building"

        case .event:
            type = "event"

        case .custom:
            type = "custom"
       
        }
        let message = """
            click StartNavigation
            type = \(type)
            id = \(String(describing: data.id))
            name = \(String(describing: data.name))
        """
        UIViewController.topViewController()?.showAlert(title: "", message: message)
    }
    
}
