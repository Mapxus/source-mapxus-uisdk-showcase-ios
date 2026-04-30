//
//  RoutePlanningEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class RoutePlanningEventHandler: BaseHandler, RoutePlanningEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "RoutePlanningEvent Listener", message: "onClose")
    }
}
