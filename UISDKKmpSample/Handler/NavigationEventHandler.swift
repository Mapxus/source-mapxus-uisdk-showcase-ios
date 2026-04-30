//
//  NavigationEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class NavigationEventHandler: BaseHandler, NavigationEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "NavigationEvent Listener", message: "onClose")
    }

    func onNavigationStarted() {
        showAlert(title: "NavigationEvent Listener", message: "onNavigationStarted")
    }

    func onNavigationCompleted() {
        showAlert(title: "NavigationEvent Listener", message: "onNavigationCompleted")
    }
}
