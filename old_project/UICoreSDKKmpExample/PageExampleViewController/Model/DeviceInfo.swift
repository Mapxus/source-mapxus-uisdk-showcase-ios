//
//  DeviceInfo.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

struct DeviceInfo {
    public static var isIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static var isIphoneXSeries: Bool {
        guard isIphone else { return false }
        // 获取当前窗口的安全区域
        let bottomInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
        return bottomInset > 0
    }

    static var topSafeArea: CGFloat {
        return isIphoneXSeries ? 44.0 : 20.0
    }

    static var bottomSafeArea: CGFloat {
        return isIphoneXSeries ? 34.0 : 0.0
    }
}
