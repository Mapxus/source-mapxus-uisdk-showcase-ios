//
//  PoiEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class PoiEventHandler: BaseHandler, PoiEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "PoiEvent Listener", message: "onClose")
    }

    func useCustomEventPage() -> Bool { return true }
    func onEventSelected(eventId: String) {
        showAlert(title: "PoiEvent Listener", message: "onEventSelected(eventId: \(eventId))")
    }

    func useCustomDirectionPage() -> Bool { return true }
    func onDirectionRequested(destination: NavigationPoint) {
        showAlert(title: "PoiEvent Listener", message: "onDirectionRequested(destination: \(destination))")
    }
}
