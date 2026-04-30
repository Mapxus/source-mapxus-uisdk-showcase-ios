//
//  EventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class EventHandler: BaseHandler, EventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "Event Listener", message: "onClose")
    }

    func useCustomPoiPage() -> Bool { return true }
    func onPoiSelected(poiId: String) {
        showAlert(title: "Event Listener", message: "onPoiSelected(poiId: \(poiId))")
    }

    func useCustomDirectionPage() -> Bool { return true }
    func onDirectionRequested(destination: NavigationPoint) {
        showAlert(title: "Event Listener", message: "onDirectionRequested(destination: \(destination))")
    }
}
