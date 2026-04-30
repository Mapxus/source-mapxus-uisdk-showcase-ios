//
//  DataTrackingHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class DataTrackingHandler: BaseHandler, DataTrackingListener {
    func onDirectionButtonClicked(data: EntityClickData) {
        showAlert(title: "DataTracking Listener", message: "onDirectionButtonClicked(data: \(data))")
    }

    func onStartNavigationClicked(data: EntityClickData) {
        showAlert(title: "DataTracking Listener", message: "onStartNavigationClicked(data: \(data))")
    }

    func onEndOfRouteCardShown() {
        showAlert(title: "DataTracking Listener", message: "onEndOfRouteCardShown")
    }
}
