//
//  MapxusMapView.swift
//  mapxus
//
//  Created by Thomas Cheng on 6/1/2023.
//

import UIKit
import DropInUISDK

/// Pure iOS wrapper around `DISdk` (no Flutter integration).
final class MapxusMapView: UIView {
    enum Target {
        case venue(mapId: String)
        case poi(mapId: String)
    }

    private var diConfigBuilder = DIConfigBuilder()
    private var sdk: DISdk?

    private var currentTarget: Target
    private var language: String

    init(
        frame: CGRect = .zero,
        target: Target,
        language: String = "system"
    ) {
        self.currentTarget = target
        self.language = language
        super.init(frame: frame)

        setupDIConfiguration()
        setupDropInView()
        startSDK()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showPoi(poiId: String) {
        currentTarget = .poi(mapId: poiId)
        startSDK()
    }

    func showVenue(venueId: String) {
        currentTarget = .venue(mapId: venueId)
        startSDK()
    }

    func setLanguage(_ language: String) {
        self.language = language
        setupDIConfiguration()
        setupDropInView()
        startSDK()
    }

    /// Release DropInUISDK resources.
    func cleanup() {
        sdk?.cleanup()
    }

    private func setupDropInView() {
        guard let newDropInView = sdk?.getView() else { return }

        subviews.forEach { $0.removeFromSuperview() }
        newDropInView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newDropInView)

        NSLayoutConstraint.activate([
            newDropInView.topAnchor.constraint(equalTo: topAnchor),
            newDropInView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newDropInView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newDropInView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func startSDK() {
        guard let sdk else { return }

        let route: AppRoute
        switch currentTarget {
        case .venue(let mapId):
            route = VenueDetailRoute.init(venueId: mapId)
        case .poi(let mapId):
            route = PoiDetailRoute.init(poiId: mapId)
        }

        sdk.start(route: route)
    }

    private func setupDIConfiguration() {
        // When language/DI changes, we recreate the SDK; cleanup the previous instance first.
        sdk?.cleanup()

        // Keep existing configuration values from the original wrapper.
        diConfigBuilder.language = transcodeLanguage(language: language)
        diConfigBuilder.materialResourcePath = "taikwun"
        diConfigBuilder.mapStyle = "taiKwun_v1"
        diConfigBuilder.navigationModes = [.foot, .wheelchair]
        diConfigBuilder.recommendedCategories = ["facility.attractions"]
        diConfigBuilder.initialMapBearing = 195.0
        diConfigBuilder.floorSelectorCategories = [
            "facility.toilet_facility",
            "facility.restroom",
            "facility.mothersroom",
            "facility.baby_changing",
            "facility.wheelchair_assist",
            "facility.fire_extinguisher",
            "facility.parking",
            "restaurants",
            "shopping",
            "arts_entertainment"
        ]

        diConfigBuilder.copyrightConfig = .init(
            alpha: 0,
            imageUrl: nil,
            imageWidth: 0,
            imageHeight: 0
        )

        diConfigBuilder.venueHighlightedShopTitle = StringsWithLanguage(
            default: "Venue",
            en: "Venue",
            ja: "Venue",
            ko: "Venue",
            zhHans: "場地",
            zhHant: "場地",
            zhHantTW: "场地",
            ar: "Venue"
        )

        diConfigBuilder.shapes = .init(
            buttonShapeCornerSize: 0,
            imageShapeCornerSize: 0,
            searchBarShapeCornerSize: 0,
            bottomSheetShapeCornerSize: 0,
            popupCardShapeCornerSize: 0
        )

        diConfigBuilder.mapBoundsRestriction = Bounds(
            maxLat: 22.285518,
            maxLon: 114.156516,
            minLat: 22.277113,
            minLon: 114.150958
        )

        diConfigBuilder.isShoplusButtonVisible = false
        diConfigBuilder.toolTipsConfig = .init(
            isEnabled: false,
            title: nil,
            content: nil,
            htmlContent: nil
        )

        let diColors = DIColors(
            brandPrimaryColor: "#ab12ff", // backgroundColor
            primaryContentColor: "#202123", // commonTextColor
            brandSecondaryColor: "#FFFFFF", // titleTextColor
            secondaryContentColor: "#ab12ff",
            accentColor: "FF0000", // subTextColor
            backgroundColor: "#000000", // primaryBgColor
            defaultTextColor: "#F5F5F5", // primaryBgDisableColor
            titleColor: "#FFFFFF", // primaryContentColor
            subtitleColor: "#BFBFBF", // primaryContentDisableColor
            brandPrimaryDisabledColor: "#Ab12ff", // Use same as brandPrimaryColor
            primaryDisabledContentColor: "#F5F5F5", // Use same as brandPrimaryDisabledColor
            primaryBorderColor: "#ab12ff", // secondaryBgColor
            primaryDisabledBorderColor: "#F5F5F5", // Use same as primaryBgDisableColor
            brandSecondaryDisabledColor: "#00FF00", // secondaryContentColor
            secondaryDisabledContentColor: "#BFBFBF", // Use same as primaryDisabledContentColor
            secondaryBorderColor: "#EDF1FF", // Use same as brandSecondaryColor
            secondaryDisabledBorderColor: "#F5F5F5", // Use same as brandSecondaryDisabledColor
            searchButtonBackgroundColor: "#F0F0F0", // searchBgColor
            searchButtonContentColor: "#8C8C8C", // searchContentColor
            searchButtonBorderColor: "#F0F0F0", // Use same as searchButtonBackgroundColor
            selectedTagBackgroundColor: "#ab12ff", // tagBgSelected
            unselectedTagBackgroundColor: "#F5F5F5", // tagBgUnselected
            selectedTagTextColor: "#FFFFFF", // tagContentSelected
            unselectedTagTextColor: "#595959", // tagContentUnselected
            inputPlaceholderColor: "#BFBFBF", // inputFieldPlaceholder
            inputFieldTextColor: "#1F1F1F", // inputFieldTextColor
            inputFieldBackgroundColor: "#F5F5F5", // inputFieldBgColor
            inputFieldBorderColor: "#BFBFBF", // inputFieldBorder
            inputFieldFocusBorderColor: "#F0F0F0", // inputFieldBorderUnfocused
            inputFieldIconColor: "#8C8C8C", // Use searchContentColor
            floorSelectorButtonBackgroundColor: "#074769", // floorBgSelected
            floorSelectorButtonTextColor: "#FFFFFF", // White text on dark background
            floorSelectorItemBackgroundColor: "#FFFFFF", // floorBgUnselected
            activeFloorSelectorItemBackgroundColor: "#ab12ff", // floorBgSelected
            floorSelectorItemTextColor: "#1F1F1F", // Use inputFieldTextColor
            badgeColor: "#FF4D4F", // badgeColor
            buildingSelectorTextColor: "#1F1F1F", // buildingSelectorTextColor
            statusOpenColor: "#52C41A", // openColor
            statusClosedColor: "#F5222D", // closeColor
            statusUpcomingColor: "#FFA500", // Orange for upcoming
            statusOngoingColor: "#52C41A", // Use same as statusOpenColor
            lineDividerColor: "#D9D9D9", // Light gray
            detailViewIconColor: "#8C8C8C", // Use searchContentColor
            indoorRouteLineColor: "#2073EC", // Use brandPrimaryColor
            outdoorRouteLineColor: "#2073EC", // Use brandPrimaryColor
            dashedRouteLineColor: "#2073EC", // Use brandPrimaryColor
            navigationQrCodeColor: "#000000", // Black
            navigationCardMarkerIconColor: "#FFFFFF", // White
            navigationStepBackgroundColor: "#F5F5F5", // Light background
            completedNavigationStepBackgroundColor: "#52C41A", // Green
            activeNavigationStepBackgroundColor: "#2073EC", // brandPrimaryColor
            floorSelectorBackgroundGradient: nil, // Optional parameter
            linkTextColor: "#2073EC", // Use brandPrimaryColor
            horizontalLineDividerColor: "#D9D9D9", // Same as lineDividerColor
            loadingMarkerBackgroundColor: "#F5F5F5", // Light background
            loadingTurnBackgroundColor: "#F5F5F5", // Light background
            shareButtonIconColor: "#FFFFFF", // White
            shareButtonBackgroundColor: "#2073EC", // brandPrimaryColor
            shareButtonBorderColor: "#2073EC", // Same as background
            shareListButtonBackgroundColor: "#F5F5F5", // Light background
            shouldRevertImageBackgroundColor: false, // Boolean value
            landingCardTextColor: "#1F1F1F" // Use inputFieldTextColor
        )

        diConfigBuilder.colors = diColors
        diConfigBuilder.appearanceMode = .dark
        diConfigBuilder.shareDisplayMode = ShareDisplayMode.none
        sdk = .init(diConfig: diConfigBuilder.build())
    }

    private func transcodeLanguage(language: String) -> Language {
        switch language {
        case "en":
            return .english
        case "zh":
            return .traditionalChineseHk
        case "cn":
            return .simplifiedChinese
        case "system":
            return .systemLanguage
        default:
            return .systemLanguage
        }
    }
}

