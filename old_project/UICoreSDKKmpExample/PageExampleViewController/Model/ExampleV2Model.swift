//
//  ExampleV2Model.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import Foundation


enum ExampleType {
    case FirstPage
    case Venue
    case Journey
    case Listener
    case CustomisedContent
    case MapStyle
    case Theme
    case POIDetails
    case Language
    case FloorChange
    case ShareTypeDisplay
}

enum ExampleV2ItemType: String {
    case Photos = "Photos"
    case Description = "Description"
    case Address = "Address"
    case Phone = "Phone"
    case Website = "Website"
    case Email = "Email"
    case OpenHours = "Opening hours"
    case Business = "Business status"
    case ServiceHours = "Service hours"
    case SpecialHours = "Special hours"
    
    case ToolTips = "Tool Tips"
    case LandingPage = "Landing page"
    case VenuePage = "Venue page"
    case BuildingPage = "Building page"
    case PoiPage = "Poi page"
    case CategoryPage = "Category page"
    case KeywordSearchPage = "KeywordSearch page"
    case EventPage = "Event page"
    case Map = "Map"
    case Navigation = "Navigation page"
    case RoutePlanning = "RoutePlanning"
    case SharePage = "Share"
    case Menu = "Menu"
    case DataTracking = "DataTracking"
    
}

struct ExampleV2ModelItem {
    var subtitle: String
    var isSelect: Bool
    var type: ExampleV2ItemType
}

struct ExampleV2Model {
    var type: ExampleType
    var imagename: String
    var title: String
    var subtitle: String
    var titleAttri: String?
    var text: String?
    var child: [ExampleV2ModelItem]?
    
    init(type: ExampleType, imagename: String, title: String, subtitle: String, titleAttri: String? = nil, text: String? = nil, child: [ExampleV2ModelItem]? = nil) {
        self.type = type
        self.imagename = imagename
        self.title = title
        self.subtitle = subtitle
        self.titleAttri = titleAttri
        self.text = text
        self.child = child
    }
    
    static func exampleDatas(with firstPage: Bool = true) -> [ExampleV2Model] {
        var d: [ExampleV2Model] = []
        
        let f = ExampleV2Model(type: .FirstPage, imagename: "page",
                               title: NSLocalizedString("Building upon our in-house cutting-edge indoor navigation and positioning technology, Mapxus UI SDK gives you an intuitive, easy-to-use, highly customizable digital map for any venue. ", comment: ""),
                               subtitle: NSLocalizedString("Perfect for shopping malls, convention centers, stadiums, and beyond. Get started today on Android or iOS!\n\nLet’s begin by setting some parameters.", comment: ""),
                               text: NSLocalizedString("Mapxus UI SDK Demo App", comment: ""))
        
        let listener = ExampleV2Model(type: .Listener, imagename: "",
                                      title: NSLocalizedString("", comment: ""),
                                      subtitle: "",
                                      text: NSLocalizedString("Listener", comment: ""),
                                      child: ExampleV2Model.listeners())
        
        let theme = ExampleV2Model(type: .Theme, imagename: "theme",
                                   title: NSLocalizedString("There are 50+ parameters for you to customise the SDK, from text size, button colours to just a divider. For now, let’s narrow it down to Default or Black/Purple.", comment: ""),
                                   subtitle: NSLocalizedString("This feature gives you flexibility to control the look and feel of the SDK. The same style can be used in all Mapxus products.", comment: ""),
                                   text: NSLocalizedString("Theme", comment: ""))
        
        let language = ExampleV2Model(type: .Language, imagename: "language",
                                      title: NSLocalizedString("Our SDK supports 3 languages: English, Traditional Chinese, Simplified Chinese. More languages would be added in the future.", comment: ""),
                                      subtitle: NSLocalizedString("This feature enhances user experience while using the SDK.", comment: ""),
                                      text: NSLocalizedString("Language", comment: ""))
        
        let shareDisplay = ExampleV2Model(type: .ShareTypeDisplay, imagename: "share_display_model",
                                          title: "Share button display mode.",
                                          subtitle: "Determines how the share button behaves and what options are available when tapped.",
                                          text: NSLocalizedString("Share display model", comment: ""))
        
        if firstPage == true {
            d.append(f)
        }
        d.append(contentsOf: [theme, language, shareDisplay, listener])
        return d
    }
    
    static func childItem() -> [ExampleV2ModelItem] {
        var d: [ExampleV2ModelItem] = []
        
        let address = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop address", comment: ""), isSelect: true, type: .Address)
        let phone = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop phone number", comment: ""), isSelect: true, type: .Phone)
        let website = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop Website", comment: ""), isSelect: true, type: .Website)
        let email = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop email contact", comment: ""), isSelect: true, type: .Email)
        let hours = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop opening hours", comment: ""), isSelect: true, type: .OpenHours)
        let status = ExampleV2ModelItem(subtitle: NSLocalizedString("Shop operation status", comment: ""), isSelect: true, type: .Business)
        let service_hours = ExampleV2ModelItem(subtitle: NSLocalizedString("Services apart from the main service this shop also provides", comment: ""), isSelect: true, type: .ServiceHours)
        let special_hours = ExampleV2ModelItem(subtitle: NSLocalizedString("Opening hours deviated from regular hours", comment: ""), isSelect: true, type: .SpecialHours)
        
        d.append(contentsOf: [address, phone, website, email, hours, status, service_hours, special_hours])
        return d
    }
    
    static func listeners() -> [ExampleV2ModelItem] {
        var d: [ExampleV2ModelItem] = []
        let toolTips = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .ToolTips)
        let landingPage = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .LandingPage)
        let venue = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .VenuePage)
        let building = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .BuildingPage)
        let poi = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .PoiPage)
        let category = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .CategoryPage)
        let keywordSeach = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .KeywordSearchPage)
        let event = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .EventPage)
        let map = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .Map)
        let navigation = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .Navigation)
        let routePlanning = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .RoutePlanning)
        let share = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .SharePage)
        let menu = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .Menu)
        let dataTracking = ExampleV2ModelItem(subtitle: NSLocalizedString("", comment: ""), isSelect: false, type: .DataTracking)

        d.append(contentsOf: [
            toolTips,
            landingPage,
            venue,
            building,
            poi,
            category,
            keywordSeach,
            event,
            map,
            navigation,
            routePlanning,
            share,
            menu,
            dataTracking
        ])
        return d
    }
}
