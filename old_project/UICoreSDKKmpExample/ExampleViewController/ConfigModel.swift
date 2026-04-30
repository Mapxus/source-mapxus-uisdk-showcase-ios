//
//  ConfigModel.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/15.
//

import Foundation
import DropInUISDK
import AFNetworking

struct ConfigModel {
    
    // normal theme
    static func normalTheme() -> DIColors {
        let colors = DIColorsBuilder().build()
        return colors
    }
    
    static func designSystem() -> DIColors {
        let builder = DIColorsBuilder()
        builder.brandPrimaryColor = "#2C3E50"
        builder.primaryContentColor = "#ECF0F1"
        builder.brandSecondaryColor = "#F39C12"
        builder.secondaryContentColor = "#2C3E50"
        builder.accentColor = "#E74C3C"
        
        return builder.build()
    }
    
    // dark theme
    static func darkTheme() -> DIColors {
        let colorsBuilder = DIColorsBuilder()
        
        colorsBuilder.backgroundColor = "#000000"
        colorsBuilder.defaultTextColor = "#ffffff"
        colorsBuilder.titleColor = "#ffffff"
        colorsBuilder.subtitleColor = "#ffffff"
        colorsBuilder.brandPrimaryColor = "#ab12ff"
        colorsBuilder.brandPrimaryDisabledColor = "#4d4d4d"
        colorsBuilder.primaryContentColor = "#000000"
        colorsBuilder.primaryDisabledContentColor = "#969696"
        colorsBuilder.primaryBorderColor = "#ab12ff"
        colorsBuilder.primaryDisabledBorderColor = "#4d4d4d"
        colorsBuilder.brandSecondaryColor = "#e8cfff"
        colorsBuilder.brandSecondaryDisabledColor = "#4d4d4d"
        colorsBuilder.secondaryContentColor = "#ab12ff"
        colorsBuilder.secondaryDisabledContentColor = "#969696"
        colorsBuilder.secondaryBorderColor = "#e8cfff"
        colorsBuilder.secondaryDisabledBorderColor = "#4d4d4d"
        
        colorsBuilder.searchButtonBackgroundColor = "#4d4d4d"
        colorsBuilder.searchButtonContentColor = "#969696"
        colorsBuilder.searchButtonBorderColor = "#4d4d4d"
        
        colorsBuilder.selectedTagBackgroundColor = "#ab12ff"
        colorsBuilder.unselectedTagBackgroundColor = "#4d4d4d"
        colorsBuilder.selectedTagTextColor = "#000000"
        colorsBuilder.unselectedTagTextColor = "#e3e3e3"
        
        colorsBuilder.inputPlaceholderColor = "#BFBFBF"
        colorsBuilder.inputFieldTextColor = "#ffffff"
        colorsBuilder.inputFieldBackgroundColor = "#666666"
        colorsBuilder.inputFieldBorderColor = "#666666"
        colorsBuilder.inputFieldFocusBorderColor = "#969696"
        colorsBuilder.inputFieldIconColor = "#c9c9c9"
        
        colorsBuilder.floorSelectorButtonBackgroundColor = "#000000"
        colorsBuilder.floorSelectorButtonTextColor = "#ffffff"
        colorsBuilder.floorSelectorItemBackgroundColor = "#000000"
        colorsBuilder.activeFloorSelectorItemBackgroundColor = "#ab12ff"
        colorsBuilder.floorSelectorItemTextColor = "#e3e3e3"
        
        colorsBuilder.badgeColor = "#ffffff"
        
        colorsBuilder.buildingSelectorTextColor = "#ffffff"
        colorsBuilder.statusOpenColor = "#52C41A"
        colorsBuilder.statusClosedColor = "#F5222D"
        colorsBuilder.statusUpcomingColor = "#008ACD"
        colorsBuilder.statusOngoingColor = "#008ACD"
        colorsBuilder.lineDividerColor = "#666666"
        colorsBuilder.detailViewIconColor = "#ffffff"
        colorsBuilder.indoorRouteLineColor = "#49b1d3"
        colorsBuilder.outdoorRouteLineColor = "#49b1d3"
        colorsBuilder.dashedRouteLineColor = "#49b1d3"
        colorsBuilder.navigationQrCodeColor = "#2073EC"
        colorsBuilder.navigationCardMarkerIconColor = "#2073EC"
        colorsBuilder.navigationStepBackgroundColor = "#D9D9D9"
        colorsBuilder.completedNavigationStepBackgroundColor = "#EDF1FF"
        colorsBuilder.activeNavigationStepBackgroundColor = "#2073EC"
        colorsBuilder.floorSelectorBackgroundGradient = nil
        colorsBuilder.linkTextColor = "#8C8C8C"
        colorsBuilder.horizontalLineDividerColor = "#0000019" // 注意：可能需要修正为正确的颜色值
        colorsBuilder.loadingMarkerBackgroundColor = "#2073EC"
        colorsBuilder.loadingTurnBackgroundColor = "#EDF1FF"
        colorsBuilder.shareButtonIconColor = "#2073EC"
        colorsBuilder.shareButtonBackgroundColor = "#EDF1FF"
        colorsBuilder.shareButtonBorderColor = "#EDF1FF"
        colorsBuilder.shareListButtonBackgroundColor = "#EDF1FF"
        colorsBuilder.shouldRevertImageBackgroundColor = true
        colorsBuilder.landingCardTextColor = "#FFFFFF"
        
        return colorsBuilder.build()
    }
    
}

class NetworkMonitoring: NSObject {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(observeNetworkChanged), name: .AFNetworkingReachabilityDidChange, object: nil)
    }
    
    func startMonitoring() {
        AFNetworkReachabilityManager.shared().startMonitoring()
    }
    
    
    @objc func observeNetworkChanged(notification: Notification) {
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
    
}
