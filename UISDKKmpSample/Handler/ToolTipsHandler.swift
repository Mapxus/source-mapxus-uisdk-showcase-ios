//
//  ToolTipsHandler.swift
//  UISDKKmpSample
//

import DropInUISDK

class ToolTipsHandler: BaseHandler, ToolTipsListener {
    func onToolTipsSequenceCompleted() {
        showAlert(title: "ToolTips Listener", message: "onToolTipsSequenceCompleted")
    }
}
