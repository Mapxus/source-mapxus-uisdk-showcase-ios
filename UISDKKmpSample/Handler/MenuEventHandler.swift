//
//  MenuEventHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class MenuEventHandler: BaseHandler, MenuEventListener {
    func onClose() {
        showAlert(title: "MenuEvent Listener", message: "onClose")
    }

    func onLanguageSelected(language: Language) {
        showAlert(title: "MenuEvent Listener", message: "onLanguageSelected(language: \(language))")
    }
}
