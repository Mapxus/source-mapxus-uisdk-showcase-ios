//
//  Config.swift
//  UISDKKmpSample
//
//  Records default values for config (e.g. initialBounds).
//

import Foundation
import DropInUISDK

final class Config {

    static let shared = Config()

    var diConfig: DIConfigBuilder
  
    var diConfigDefault: DIConfigBuilder
  
    var configSet:Set<String>

    var appRoute:AppRoute
    
    var appRouteString:String
    
    var listener:String?

    private init() {
        self.diConfig = DIConfigBuilder()
        self.diConfigDefault = DIConfigBuilder()
        // let buildingFacilityInfo = FacilityInfo(id: "ed8353f3-6b85-45ad-86a1-fba7b324c80d", facilities: ["facility.mothersroom","facility.restroom.female"])
        // let floorFacilityInfo = FacilityInfo(id: "6f26a6c6-2164-450f-8d0b-4693fc31b2ba", facilities: ["facility.restroom.female","facility.mothersroom"])
        // let venueLevelFacilityInfo = VenueLevelFacilityInfo(buildings: [buildingFacilityInfo], floors: [floorFacilityInfo], sharedFloors: nil)
        // self.diConfig.venueLevelFacilityInfoConfig = [VenueLevelFacilityInfoConfig(venueId: "3cd9b17d-f3f4-4afd-ba34-5e3fad2518a6", venueLevelFacilityInfo: venueLevelFacilityInfo)]
        
        // let pagesVisibilityOverride = PagesVisibilityOverride(navigationPage: false)
        // let buildingPins = PinVisibilityConfig(fallbackVisibility: true, pagesVisibilityOverride: pagesVisibilityOverride)
        // self.diConfig.mapLabelsConfig = MapLabelsConfig(buildingPins: buildingPins)
        self.configSet = []
        self.appRoute = LandingPageRoute(venueIds:[])
        self.appRouteString = "LandingPageRoute"
        self.listener = nil
    }
    
    func saveChange(_ input: [String: Any?]) {
      for (key, value) in input {
        if isEqual(value, defaultValue(forKey: key)) {
          self.configSet.remove(key)
        } else {
          self.configSet.insert(key)
        }
      }
      print("configSet:",configSet)
    }

    /// 根据 key 获取 diConfigDefault 中对应属性的值
    func defaultValue(forKey key: String) -> Any? {
        (diConfigDefault as NSObject).value(forKey: key)
    }

    func configValue(forKey key: String) -> Any? {
        (diConfig as NSObject).value(forKey: key)
    }

    private func isEqual(_ a: Any?, _ b: Any?) -> Bool {
        switch (a, b) {
        case (nil, nil):
            return true
        case (nil, _), (_, nil):
            return false
        case let (x?, y?):
            if let nx = x as? NSObject, let ny = y as? NSObject {
                return nx.isEqual(ny)
            }
            return String(describing: x) == String(describing: y)
        }
    }
    
    func saveRouteChange(_ input: [String:AppRoute]){
        for (key, _) in input {
            self.appRouteString = key
        }
        print("appRoute:",appRouteString)
    }
    
    func saveListenerChange(_ input:String?){
        self.listener = input
        print("listener:",listener ?? "nil")
    }
}
