//
//  FeatureConstants.swift
//  UISDKKmpSample
//
//  分类与功能常量
//

import Foundation
import UIKit

enum FeatureConstants {

    /// 分类列表（侧边栏 Table Cell 标题）
    static let categoryList: [String] = [
        "🌍 Map Basics",
        "🎨 UI Appearance & Theming",
        "📍 POI Configuration",
        "🏢 Venue Settings",
        "🧭 Navigation & Routing",
        "🌐 Localization & Language",
        "🔍 Search & Filtering",
        "🔗 Legal & Attribution",
        "📱 UI Components & Behavior",
        "🧭 Route Paths",
        "🔍 Data Search",
        "📡 Listener",
    ]

    /// 功能列表（分类标题 -> 功能名称数组）
    static let featureList: [String: [String]] = [
        "🌍 Map Basics": ["initialBounds", "mapBoundsRestriction", "initialMapBearing", "mapStyle", "mapStyleDark", "initialMapPitch", "selectedBuildingBorderStyle", "floorSwitchScope"],
        "🎨 UI Appearance & Theming": ["appearanceMode", "colors", "shapes", "materialResourcePath"],
        "📍 POI Configuration": ["fixedDisplayCategories", "poiDetailSections", "recommendedCategories", "recommendedPoiIds", "poiSorting", "categoryListConfig"],
        "🏢 Venue Settings": ["isBuildingListVisible", "buildingSectionTitle", "venueHighlightedShopTitle", "floorSelectorCategories", "venueDefaultSharedFloorIds", "sharedFloorsUnifiedNames", "venueAnchorPoiConfigs", "venueLevelFacilityInfoConfig"],
        "🧭 Navigation & Routing": ["navigationModes", "publicTransportModes", "maximumRoutePlanningDistance", "navigationRoadSnapStrength", "noRouteAvailableTitle", "noRouteAvailableMessage"],
        "🌐 Localization & Language": ["language", "settingsLanguageOptions", "publicHolidayDisplayName", "gpsModeDisplayName", "closeButtonTitle", "sendLogButtonTitle", "eventModuleTitle", "eventOverviewTitle", "toolTipsConfig"],
        "🔍 Search & Filtering": ["globalFilterModes", "globalFilterTagIds", "filterChipsConfig"],
        "🔗 Legal & Attribution": ["copyrightConfig", "attributionConfig", "isLegalLinksVisible"],
        "📱 UI Components & Behavior": ["isShoplusButtonVisible", "isVenueBackButtonVisible", "shareDisplayMode", "mapLabelsConfig"],
        "🧭 Route Paths": ["LandingPageRoute", "VenueDetailRoute", "BuildingDetailRoute", "PoiDetailRoute", "EventDetailRoute", "NavigationRoute"],
        "🔍 Data Search": ["searchPoiByBounds", "searchPoiById", "searchVenuesByName", "searchVenuesNearby", "searchVenuesByIds"],
        "📡 Listener": ["setToolTipsListener", "setLandingPageEventListener", "setVenueEventListener", "setBuildingEventListener", "setPoiEventListener", "setCategorySearchEventListener", "setEventListener", "setKeywordSearchEventListener", "setMapEventListener", "setNavigationEventListener", "setRoutePlanningEventListener", "setShareEventListener", "setMenuEventListener", "setDataTrackingListener"],
    ]

    /// 根据功能名称获取所属分类标题。例如 `category(forFeature: "isBuildingListVisible")` 返回 `"🏢 Venue Settings"`。
    static func category(forFeature feature: String) -> String? {
        for (categoryTitle, features) in featureList {
            if features.contains(feature) {
                return categoryTitle
            }
        }
        return nil
    }

    /// 功能名称 -> 详情页 ViewController 类型映射（新增功能页时在此登记即可）
    private static let featureViewControllerTypes: [String: BaseFeatureViewController.Type] = [
        "initialBounds": InitialBoundsViewController.self,
        "mapBoundsRestriction": MapBoundsRestrictionViewController.self,
        "initialMapBearing": InitialMapBearingViewController.self,
        "initialMapPitch": InitialMapPitchViewController.self,
        "mapStyle": MapStyleViewController.self,
        "mapStyleDark": MapStyleDarkViewController.self,
        "appearanceMode": AppearanceModeViewController.self,
        "colors": ColorsViewController.self,
        "shapes": ShapesViewController.self,
        "materialResourcePath": MaterialResourcePathViewController.self,
        "fixedDisplayCategories": FixedDisplayCategoriesViewController.self,
        "recommendedCategories": RecommendedCategoriesViewController.self,
        "recommendedPoiIds": RecommendedPoiIdsViewController.self,
        "poiSorting": PoiSortingViewController.self,
        "categoryListConfig": CategoryListConfigViewController.self,
        "poiDetailSections": PoiDetailSectionsViewController.self,
        "isBuildingListVisible": IsBuildingListVisibleViewController.self,
        "buildingSectionTitle": BuildingSectionTitleViewController.self,
        "venueHighlightedShopTitle": VenueHighlightedShopTitleViewController.self,
        "floorSelectorCategories": FloorSelectorCategoriesViewController.self,
        "venueDefaultSharedFloorIds": VenueDefaultSharedFloorIdsViewController.self,
        "sharedFloorsUnifiedNames": SharedFloorsUnifiedNamesViewController.self,
        "venueAnchorPoiConfigs": VenueAnchorPoiConfigsViewController.self,
        "venueLevelFacilityInfoConfig": VenueLevelFacilityInfoConfigViewController.self,
        "navigationModes": NavigationModesViewController.self,
        "publicTransportModes": PublicTransportModesViewController.self,
        "maximumRoutePlanningDistance": MaximumRoutePlanningDistanceViewController.self,
        "navigationRoadSnapStrength": NavigationRoadSnapStrengthViewController.self,
        "noRouteAvailableTitle": NoRouteAvailableTitleViewController.self,
        "noRouteAvailableMessage": NoRouteAvailableMessageViewController.self,
        "language": LanguageViewController.self,
        "settingsLanguageOptions": SettingsLanguageOptionsViewController.self,
        "publicHolidayDisplayName": PublicHolidayDisplayNameViewController.self,
        "gpsModeDisplayName": GpsModeDisplayNameViewController.self,
        "closeButtonTitle": CloseButtonTitleViewController.self,
        "sendLogButtonTitle": SendLogButtonTitleViewController.self,
        "eventModuleTitle": EventModuleTitleViewController.self,
        "eventOverviewTitle": EventOverviewTitleViewController.self,
        "toolTipsConfig": ToolTipsConfigViewController.self,
        "globalFilterModes": GlobalFilterModesViewController.self,
        "globalFilterTagIds": GlobalFilterTagIdsViewController.self,
        "filterChipsConfig": FilterChipsConfigViewController.self,
        "copyrightConfig": CopyrightConfigViewController.self,
        "attributionConfig": AttributionConfigViewController.self,
        "isLegalLinksVisible": IsLegalLinksVisibleViewController.self,
        "isShoplusButtonVisible": IsShoplusButtonVisibleViewController.self,
        "isVenueBackButtonVisible": IsVenueBackButtonVisibleViewController.self,
        "shareDisplayMode": ShareDisplayModeViewController.self,
        "mapLabelsConfig": MapLabelsConfigViewController.self,
        "selectedBuildingBorderStyle": SelectedBuildingBorderStyleViewController.self,
        "floorSwitchScope": FloorSwitchScopeViewController.self,
        "LandingPageRoute": LandingPageRouteViewController.self,
        "VenueDetailRoute": VenueDetailRouteViewController.self,
        "BuildingDetailRoute": BuildingDetailRouteViewController.self,
        "PoiDetailRoute": PoiDetailRouteViewController.self,
        "EventDetailRoute": EventDetailRouteViewController.self,
        "NavigationRoute": NavigationRouteViewController.self,
        "searchPoiByBounds": SearchPoiByBoundsViewController.self,
        "searchPoiById": SearchPoiByIdViewController.self,
        "searchVenuesByName": SearchVenuesByNameViewController.self,
        "searchVenuesNearby": SearchVenuesNearbyViewController.self,
        "searchVenuesByIds": SearchVenuesByIdsViewController.self,
        "setToolTipsListener": ToolTipsListenerViewController.self,
        "setLandingPageEventListener": LandingPageEventListenerViewController.self,
        "setVenueEventListener": VenueEventListenerViewController.self,
        "setBuildingEventListener": BuildingEventListenerViewController.self,
        "setPoiEventListener": PoiEventListenerViewController.self,
        "setCategorySearchEventListener": CategorySearchEventListenerViewController.self,
        "setEventListener": EventListenerViewController.self,
        "setKeywordSearchEventListener": KeywordSearchEventListenerViewController.self,
        "setMapEventListener": MapEventListenerViewController.self,
        "setNavigationEventListener": NavigationEventListenerViewController.self,
        "setRoutePlanningEventListener": RoutePlanningEventListenerViewController.self,
        "setShareEventListener": ShareEventListenerViewController.self,
        "setMenuEventListener": MenuEventListenerViewController.self,
        "setDataTrackingListener": DataTrackingListenerViewController.self,
    ]

    /// 根据功能名称创建对应的详情页；无映射时返回 nil。
    static func viewController(forFeature featureName: String) -> BaseFeatureViewController? {
        featureViewControllerTypes[featureName]?.init(featureName: featureName)
    }
}
