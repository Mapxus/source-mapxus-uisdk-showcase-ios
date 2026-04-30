//
//  CategorySearchEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class CategorySearchEventHandler: BaseHandler, CategorySearchEventListener {
    func useCustomCloseAction() -> Bool { return true }
    func onClose() {
        showAlert(title: "CategorySearchEvent Listener", message: "onClose")
    }

    func useCustomPoiPage() -> Bool { return true }
    func onPoiSelected(poiId: String) {
        showAlert(title: "CategorySearchEvent Listener", message: "onPoiSelected(poiId: \(poiId))")
    }
}
