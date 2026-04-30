//
//  FeatureInfo.swift
//  UISDKKmpSample
//
//  功能描述表，从 JSON 读取并展示
//

import Foundation

struct FeatureInfoItem: Decodable {
    let name: String
    let dataType: String
    let defaultValue: String
    let description: String
    let parameters: String?
    let returnType: String?
    let listenerName: String?
    let methods: [String]?
}

struct FeatureInfoTable: Decodable {
    private let features: [String: FeatureInfoItem]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        features = try container.decode([String: FeatureInfoItem].self)
    }

    func item(forKey key: String) -> FeatureInfoItem? {
        features[key]
    }

    static func load() -> FeatureInfoTable? {
        guard let url = Bundle.main.url(forResource: "FeatureInfo", withExtension: "json", subdirectory: "Resources")
            ?? Bundle.main.url(forResource: "FeatureInfo", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(FeatureInfoTable.self, from: data)
    }
}
