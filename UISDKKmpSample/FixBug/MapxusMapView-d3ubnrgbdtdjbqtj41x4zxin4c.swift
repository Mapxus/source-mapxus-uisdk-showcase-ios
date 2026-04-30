////
////  MapxusMapView.swift
////  mapxus
////
////  Created by Thomas Cheng on 6/1/2023.
////
//
//import Flutter
//import UIKit
//import DropInUISDK
//
//class MapxusMapViewFactory: NSObject, FlutterPlatformViewFactory {
//   private var messenger: FlutterBinaryMessenger
//   init(messenger: FlutterBinaryMessenger) {
//       self.messenger = messenger
//       super.init()
//   }
//
//   func create(
//       withFrame frame: CGRect,
//       viewIdentifier viewId: Int64,
//       arguments args: Any?
//   ) -> FlutterPlatformView {
//       return MapxusMapView(
//           frame: frame,
//           viewIdentifier: viewId,
//           arguments: args,
//           binaryMessenger: messenger)
//   }
//   
//   public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
//         return FlutterStandardMessageCodec.sharedInstance()
//   }
//}
//
//class MapxusMapView: NSObject {
//   var diConfigBuilder = DIConfigBuilder()
//   private var sdk: DISdk?
//   private var dropInView: UIView?
//
//   private var width = 0
//   private var height: Int = 0
//   private var iosBottomSheetMiddleDisplayRatio: Double = 1/3
//   private var iosBottomSheetMinDisplayRatio: Double = 1/6
//   private var type = "venue"
//   private var mapId = ""
//   private var language = "system"
//   private let displayView: UIView = UIView()
//   
//   let messenger: FlutterBinaryMessenger
//   let channel: FlutterMethodChannel
//
//   init(
//       frame: CGRect,
//       viewIdentifier viewId: Int64,
//       arguments args: Any?,
//       binaryMessenger messenger: FlutterBinaryMessenger?
//   ) {
//       if let argumentsDictionary = args as? Dictionary<String, Any> {
//           print("😕argumentsDictionary:$\(argumentsDictionary)")
//           width = argumentsDictionary["width"] as! Int
//           height = argumentsDictionary["height"] as! Int
//           iosBottomSheetMiddleDisplayRatio = argumentsDictionary["iosBottomSheetMiddleDisplayRatio"] as! Double
//           iosBottomSheetMinDisplayRatio = argumentsDictionary["iosBottomSheetMinDisplayRatio"] as! Double
//           type = argumentsDictionary["type"] as! String
//           mapId = argumentsDictionary["mapId"] as! String
//           language = argumentsDictionary["language"] as! String
//       }
//   
//       self.messenger = messenger!
//       channel = FlutterMethodChannel(name: "mapxus_\(viewId)", binaryMessenger: messenger!)
//       
//       super.init()
//       self.setupDIConfiguration()
//       self.setupDropInView()
//       self.startSDK()
//       self.setupFlutterChannel()
//   }
//   
//   private func setupDropInView() {
//       dropInView = sdk?.getView()
//       displayView.subviews.forEach { $0.removeFromSuperview() }
//       
//       guard let dropInView = dropInView else { return }
//       dropInView.translatesAutoresizingMaskIntoConstraints = false
//       displayView.addSubview(dropInView)
//       
//       NSLayoutConstraint.activate([
//           dropInView.topAnchor.constraint(equalTo: displayView.topAnchor),
//           dropInView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor),
//           dropInView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor),
//           dropInView.bottomAnchor.constraint(equalTo: displayView.bottomAnchor)
//       ])
//   }
//   
//   private func startSDK() {
//       let route: AppRoute
//       if self.type == "venue" {
//           route = VenueDetailRoute.init(venueId: mapId)
//       } else {
//           route = PoiDetailRoute.init(poiId: mapId)
//       }
//       sdk?.start(route: route)
//   }
//   
//   private func setupDIConfiguration() {
//       //Missing Property
//       //pod/venueID
//       //permanentlyCategory
//       //
//       diConfigBuilder.language = self.transcodeLanguage(language: language)
//       diConfigBuilder.materialResourcePath = "taikwun"
//       diConfigBuilder.mapStyle = "taiKwun_v1"
//       diConfigBuilder.navigationModes = [.foot, .wheelchair]
//       diConfigBuilder.recommendedCategories = ["facility.attractions"]
//       diConfigBuilder.initialMapBearing = 195.0
//       diConfigBuilder.floorSelectorCategories = ["facility.toilet_facility",
//                                                  "facility.restroom",
//                                                  "facility.mothersroom",
//                                                  "facility.baby_changing",
//                                                  "facility.wheelchair_assist",
//                                                  "facility.fire_extinguisher",
//                                                  "facility.parking",
//                                                  "restaurants",
//                                                  "shopping",
//                                                  "arts_entertainment"]
//       
//       diConfigBuilder.copyrightConfig = .init(alpha: 0,
//                                               imageUrl: nil,
//                                               imageWidth: 0,
//                                               imageHeight: 0)
//       
//       diConfigBuilder.venueHighlightedShopTitle = StringsWithLanguage(default: "Venue",
//                                                                       en: "Venue",
//                                                                       ja: "Venue",
//                                                                       ko: "Venue",
//                                                                       zhHans: "場地",
//                                                                       zhHant: "場地",
//                                                                       zhHantTW: "场地",
//                                                                       ar: "Venue")
//       
//       diConfigBuilder.shapes = .init(buttonShapeCornerSize: 0,
//                                      imageShapeCornerSize: 0,
//                                      searchBarShapeCornerSize: 0,
//                                      bottomSheetShapeCornerSize: 0,
//                                      popupCardShapeCornerSize: 0)
//       
//       diConfigBuilder.mapBoundsRestriction = Bounds(maxLat: 22.285518,
//                                                     maxLon: 114.156516,
//                                                     minLat: 22.277113,
//                                                     minLon: 114.150958)
//       
//       diConfigBuilder.isShoplusButtonVisible = false
//       diConfigBuilder.toolTipsConfig = .init(isEnabled: false, title: nil, content: nil, htmlContent: nil)
//
//       let diColors = DIColors(
//           brandPrimaryColor: "#ab12ff", // backgroundColor
//           primaryContentColor: "#202123", // commonTextColor
//           brandSecondaryColor: "#FFFFFF", // titleTextColor
//           secondaryContentColor: "#ab12ff",
//           accentColor: "FF0000", // subTextColor
//           backgroundColor: "#000000", // primaryBgColor
//           defaultTextColor: "#F5F5F5", // primaryBgDisableColor
//           titleColor: "#FFFFFF", // primaryContentColor
//           subtitleColor: "#BFBFBF", // primaryContentDisableColor
//           brandPrimaryDisabledColor: "#Ab12ff", // Use same as brandPrimaryColor
//           primaryDisabledContentColor: "#F5F5F5", // Use same as brandPrimaryDisabledColor
//           primaryBorderColor: "#ab12ff", // secondaryBgColor
//           primaryDisabledBorderColor: "#F5F5F5", // Use same as primaryBgDisableColor
//           brandSecondaryDisabledColor: "#00FF00", // secondaryContentColor
//           secondaryDisabledContentColor: "#BFBFBF", // Use same as primaryDisabledContentColor
//           secondaryBorderColor: "#EDF1FF", // Use same as brandSecondaryColor
//           secondaryDisabledBorderColor: "#F5F5F5", // Use same as brandSecondaryDisabledColor
//           searchButtonBackgroundColor: "#F0F0F0", // searchBgColor
//           searchButtonContentColor: "#8C8C8C", // searchContentColor
//           searchButtonBorderColor: "#F0F0F0", // Use same as searchButtonBackgroundColor
//           selectedTagBackgroundColor: "#ab12ff", // tagBgSelected
//           unselectedTagBackgroundColor: "#F5F5F5", // tagBgUnselected
//           selectedTagTextColor: "#FFFFFF", // tagContentSelected
//           unselectedTagTextColor: "#595959", // tagContentUnselected
//           inputPlaceholderColor: "#BFBFBF", // inputFieldPlaceholder
//           inputFieldTextColor: "#1F1F1F", // inputFieldTextColor
//           inputFieldBackgroundColor: "#F5F5F5", // inputFieldBgColor
//           inputFieldBorderColor: "#BFBFBF", // inputFieldBorder
//           inputFieldFocusBorderColor: "#F0F0F0", // inputFieldBorderUnfocused
//           inputFieldIconColor: "#8C8C8C", // Use searchContentColor
//           floorSelectorButtonBackgroundColor: "#074769", // floorBgSelected
//           floorSelectorButtonTextColor: "#FFFFFF", // White text on dark background
//           floorSelectorItemBackgroundColor: "#FFFFFF", // floorBgUnselected
//           activeFloorSelectorItemBackgroundColor: "#ab12ff", // floorBgSelected
//           floorSelectorItemTextColor: "#1F1F1F", // Use inputFieldTextColor
//           badgeColor: "#FF4D4F", // badgeColor
//           buildingSelectorTextColor: "#1F1F1F", // buildingSelectorTextColor
//           statusOpenColor: "#52C41A", // openColor
//           statusClosedColor: "#F5222D", // closeColor
//           statusUpcomingColor: "#FFA500", // Orange for upcoming
//           statusOngoingColor: "#52C41A", // Use same as statusOpenColor
//           lineDividerColor: "#D9D9D9", // Light gray
//           detailViewIconColor: "#8C8C8C", // Use searchContentColor
//           indoorRouteLineColor: "#2073EC", // Use brandPrimaryColor
//           outdoorRouteLineColor: "#2073EC", // Use brandPrimaryColor
//           dashedRouteLineColor: "#2073EC", // Use brandPrimaryColor
//           navigationQrCodeColor: "#000000", // Black
//           navigationCardMarkerIconColor: "#FFFFFF", // White
//           navigationStepBackgroundColor: "#F5F5F5", // Light background
//           completedNavigationStepBackgroundColor: "#52C41A", // Green
//           activeNavigationStepBackgroundColor: "#2073EC", // brandPrimaryColor
//           floorSelectorBackgroundGradient: nil, // Optional parameter
//           linkTextColor: "#2073EC", // Use brandPrimaryColor
//           horizontalLineDividerColor: "#D9D9D9", // Same as lineDividerColor
//           loadingMarkerBackgroundColor: "#F5F5F5", // Light background
//           loadingTurnBackgroundColor: "#F5F5F5", // Light background
//           shareButtonIconColor: "#FFFFFF", // White
//           shareButtonBackgroundColor: "#2073EC", // brandPrimaryColor
//           shareButtonBorderColor: "#2073EC", // Same as background
//           shareListButtonBackgroundColor: "#F5F5F5", // Light background
//           shouldRevertImageBackgroundColor: false, // Boolean value
//           landingCardTextColor: "#1F1F1F" // Use inputFieldTextColor
//       )
//       
//       diConfigBuilder.colors = diColors
//       diConfigBuilder.appearanceMode = .dark
//       diConfigBuilder.shareDisplayMode = ShareDisplayMode.none
//       sdk = .init(diConfig: diConfigBuilder.build())
//       
//   }
//   
//   private func transcodeLanguage(language: String) -> Language {
//       switch (language) {
//           case "en":
//           return .english
//           case "zh":
//           return .traditionalChineseHk
//           case "cn":
//           return .simplifiedChinese
//           case "system":
//               fallthrough
//           default:
//           return .systemLanguage
//       }
//   }
//       
//   private func setupFlutterChannel() {
//       channel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
//           switch call.method {
//           case "showPoi":
//               guard let args = call.arguments as? [String: Any],
//                     let poiId = args["mapId"] as? String else {
//                   result(FlutterError(code: "-1", message: "Error", details: "Error"))
//                   return
//               }
//               
//               let route = PoiDetailRoute.init(poiId: poiId)
//               self.sdk?.start(route: route)
//               result("1")
//           case "showVenue":
//               guard let args = call.arguments as? [String: Any],
//                     let venueId = args["mapId"] as? String else {
//                   result(FlutterError(code: "-1", message: "Error", details: "Error"))
//                   return
//               }
//
//               let route = VenueDetailRoute.init(venueId: venueId)
//               self.sdk?.start(route: route)
//               result("1")
//           case "changeLanguage":
//               guard let args = call.arguments as? [String: Any],
//                     let currentLanguage = args["language"] as? String else {
//                   result(FlutterError(code: "-1", message: "Error", details: "Error"))
//                   return
//               }
//               
//               self.language = currentLanguage
//               self.setupDIConfiguration()
//               self.setupDropInView()
//               self.startSDK()
//               result("1")
//           default:
//               result(FlutterMethodNotImplemented)
//           }
//         })
//   }
//}
//
//extension MapxusMapView: FlutterPlatformView {
//   func view() -> UIView {
//       return self.displayView
//   }
//   
//   public func sendFromNative(_ action: String) {
//       channel.invokeMethod(action, arguments: "")
//   }
//}
