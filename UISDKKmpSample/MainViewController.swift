//
//  MainViewController.swift
//  UISDKKmpSample
//

import UIKit
import SnapKit
import DropInUISDK

/// First-line title plus a second line wrapped in a view, offset by about two tabs on the left
private final class ConfigSetCell: UITableViewCell {
    static let id = "ConfigSetCell"
    private let titleLabel = UILabel()
    private let detailWrapperView = UIView()
    private let detailLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailWrapperView)
        detailWrapperView.addSubview(detailLabel)

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView.layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(contentView.layoutMarginsGuide)
        }
        let tabOffset: CGFloat = 24
        detailWrapperView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(contentView.layoutMarginsGuide).offset(tabOffset)
            make.trailing.bottom.equalTo(contentView.layoutMarginsGuide)
        }
        detailLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
}

final class MainViewController: UIViewController {

    private let menuTitles = FeatureConstants.categoryList

    private var currentIndex: Int = 0 {
        didSet { updateUI() }
    }

    private var pendingPushIndex: Int?

    /// List read from Config.configSet and sorted alphabetically; refreshed whenever returning from a route
    private var configSetItems: [String] = []

    private let diConfigTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "DIConfig"
        l.font = .preferredFont(forTextStyle: .headline)
        l.textColor = .secondaryLabel
        return l
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(ConfigSetCell.self, forCellReuseIdentifier: ConfigSetCell.id)
        return t
    }()

    private let configHintLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .footnote)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let listenerContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        return sv
    }()

    /// configHintLabel → listenerContainer (listener visible)
    private var configHintToListenerConstraint: Constraint?
    /// configHintLabel → appRouteTitleLabel (listener hidden)
    private var configHintToAppRouteConstraint: Constraint?

    private let listenerTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Listener"
        l.font = .preferredFont(forTextStyle: .headline)
        l.textColor = .secondaryLabel
        return l
    }()

    private let listenerCell: ConfigSetCell = {
        let cell = ConfigSetCell(style: .default, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    private let listenerHintLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.text = "DISdk supports setting multiple Listeners, but this Sample only sets one at a time."
        return l
    }()

    private let appRouteTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "AppRoute"
        l.font = .preferredFont(forTextStyle: .headline)
        l.textColor = .secondaryLabel
        return l
    }()

    private let appRouteCell: ConfigSetCell = {
        let cell = ConfigSetCell(style: .default, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    private let openMapButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Open Map", for: .normal)
        b.titleLabel?.font = .preferredFont(forTextStyle: .body)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mapxus UISDK"
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = "Back"

        definesPresentationContext = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Features",
            style: .plain,
            target: self,
            action: #selector(showMenu)
        )

        // Listener container: collapses entirely when hidden
        let listenerTitleWrapper = UIView()
        listenerTitleWrapper.addSubview(listenerTitleLabel)
        listenerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        listenerCell.snp.makeConstraints { make in
            make.height.equalTo(64)
        }
        let listenerHintWrapper = UIView()
        listenerHintWrapper.addSubview(listenerHintLabel)
        listenerHintLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        listenerContainer.addArrangedSubview(listenerTitleWrapper)
        listenerContainer.addArrangedSubview(listenerCell)
        listenerContainer.addArrangedSubview(listenerHintWrapper)

        view.addSubview(diConfigTitleLabel)
        view.addSubview(tableView)
        view.addSubview(configHintLabel)
        view.addSubview(listenerContainer)
        view.addSubview(appRouteTitleLabel)
        view.addSubview(appRouteCell)
        view.addSubview(openMapButton)

        tableView.dataSource = self
        tableView.delegate = self
        diConfigTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(diConfigTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(configHintLabel.snp.top).offset(-12)
        }
        configHintLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            configHintToListenerConstraint = make.bottom.equalTo(listenerContainer.snp.top).constraint
            configHintToAppRouteConstraint = make.bottom.equalTo(appRouteTitleLabel.snp.top).offset(-16).constraint
        }
        listenerContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(appRouteTitleLabel.snp.top).offset(-16)
        }
        appRouteTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(appRouteCell.snp.top).offset(-8)
        }
        appRouteCell.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(64)
            make.bottom.equalTo(openMapButton.snp.top).offset(-24)
        }
        openMapButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        openMapButton.addTarget(self, action: #selector(openMapTapped), for: .touchUpInside)

        let listenerTap = UITapGestureRecognizer(target: self, action: #selector(listenerTapped))
        listenerCell.addGestureRecognizer(listenerTap)

        let appRouteTap = UITapGestureRecognizer(target: self, action: #selector(appRouteTapped))
        appRouteCell.addGestureRecognizer(appRouteTap)

        refreshConfigSetItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshConfigSetItems()
    }

    @objc private func openMapTapped() {
        navigationController?.pushViewController(MapViewController(), animated: true)
    }

    @objc private func listenerTapped() {
        navigationController?.pushViewController(FeatureListViewController(categoryTitle: "📡 Listener"), animated: true)
    }

    @objc private func appRouteTapped() {
        navigationController?.pushViewController(FeatureListViewController(categoryTitle: "🧭 Route Paths"), animated: true)
    }
    
    /// Reads Config.configSet, sorts alphabetically, updates configSetItems, and refreshes the tableView and prompt text
    private func refreshConfigSetItems() {
        configSetItems = Config.shared.configSet.sorted(by: { $0.compare($1, options: .caseInsensitive) == .orderedAscending })
        tableView.reloadData()
        let hasListener = Config.shared.listener != nil
        listenerContainer.isHidden = !hasListener
        configHintToListenerConstraint?.isActive = hasListener
        configHintToAppRouteConstraint?.isActive = !hasListener
        if hasListener {
            listenerCell.configure(title: "Current Listener :", detail: Config.shared.listener!)
        }
        appRouteCell.configure(title: "Current Route :", detail: Config.shared.appRouteString)
        configHintLabel.text = Config.shared.configSet.isEmpty
            ? "All configurations use DIConfig defaults."
            : "Other configurations use DIConfig defaults."
    }

    /// Reads object values by keys using KVC and formats them as "key:value, key:value"; skips empty strings when skipEmptyStrings is true
    private func formatKeyValues(_ obj: NSObject, keys: [String], skipEmptyStrings: Bool = false) -> String {
        var parts: [String] = []
        for k in keys {
            guard let v = obj.value(forKey: k) else { continue }
            if skipEmptyStrings, let s = v as? String, s.isEmpty { continue }
            let str: String
            if let n = v as? NSNumber {
                str = n.stringValue
            } else if let s = v as? String {
                str = s
            } else {
                str = String(describing: v)
            }
            parts.append("\(k):\(str)")
        }
        return parts.joined(separator: ", ")
    }

    /// Display values for primitive, enum, and class types; [SharedFloorsUnifiedName]? / [VenueAnchorPoiConfig]? are currently "TODO"
    private func detailText(forKey key: String) -> String {
        let value = Config.shared.configValue(forKey: key)
        let dataType = FeatureInfoTable.load()?.item(forKey: key)?.dataType ?? ""

        if value == nil || value is NSNull {
            return "nil"
        }

        switch dataType {
        case "Double", "Double?":
            if let n = value as? NSNumber { return n.stringValue }
            if let obj = value as? NSObject,
               let d = obj.value(forKey: "doubleValue") as? Double {
                return String(d)
            }
            return "nil"
        case "Boolean":
            if let n = value as? NSNumber { return n.boolValue ? "true" : "false" }
            return ""
        case "String":
            if let s = value as? String { return s }
            return "nil"
        case "[String]?":
            if let arr = value as? [String] {
                return arr.isEmpty ? "[]" : arr.joined(separator: ", ")
            }
            if let nsArr = value as? NSArray {
                let arr = nsArr.compactMap { $0 as? String }
                return arr.isEmpty ? "[]" : arr.joined(separator: ", ")
            }
            return "nil"
        case "AppearanceMode", "PoiSortingStrategy", "Language", "ShareDisplayMode", "FloorSwitchScope":
            if let obj = value as? NSObject, let name = obj.value(forKey: "name") as? String {
                return name
            }
            return "nil"
        case "[PoiDetailSection]":
            if let nsArr = value as? NSArray {
                let names = nsArr.compactMap { ($0 as? NSObject)?.value(forKey: "name") as? String }
                return names.isEmpty ? "[]" : names.joined(separator: ", ")
            }
            return "nil"
        case "[NavigationMode]":
            if let modes = value as? [NavigationMode] {
                if modes.isEmpty { return "[]" }
                return modes.map { $0.name }.joined(separator: ", ")
            }
            return "nil"
        case "[PublicTransportMode]":
            if let modes = value as? [PublicTransportMode] {
                if modes.isEmpty { return "[]" }
                return modes.map { $0.name }.joined(separator: ", ")
            }
            return "nil"
        case "[GlobalFilterMode]?":
            if let modes = value as? [GlobalFilterMode] {
                if modes.isEmpty { return "[]" }
                return modes.map { $0.name }.joined(separator: ", ")
            }
            return "nil"
        case "[Language]?":
            if let langs = value as? [Language] {
                return langs.isEmpty ? "[]" : langs.map { $0.name }.joined(separator: ", ")
            }
            if let nsArr = value as? NSArray {
                let names = nsArr.compactMap { item -> String? in
                    if let lang = item as? Language { return lang.name }
                    if let obj = item as? NSObject, let name = obj.value(forKey: "name") as? String { return name }
                    return nil
                }
                return names.isEmpty ? "[]" : names.joined(separator: ", ")
            }
            return "nil"
        case "Bounds?":
            guard let obj = value as? NSObject else { return "TODO" }
            return formatKeyValues(obj, keys: ["maxLat", "maxLon", "minLat", "minLon"])
        case "BorderStyle?":
            guard let obj = value as? NSObject else { return "nil" }
            if let opacity = obj.value(forKey: "lineOpacity") as? NSObject,
               let d = opacity.value(forKey: "doubleValue") as? Double {
                return "lineOpacity: \(d)"
            }
            return "BorderStyle(lineOpacity: nil)"
        case "MapLabelsConfig?":
            guard let obj = value as? NSObject else { return "nil" }
            var parts: [String] = []
            if let pins = obj.value(forKey: "buildingPins") as? NSObject {
                let fallback = (pins.value(forKey: "fallbackVisibility") as? NSNumber)?.boolValue ?? false
                var pinParts: [String] = ["fallbackVisibility:\(fallback ? "true" : "false")"]
                if let pages = pins.value(forKey: "pagesVisibilityOverride") as? NSObject {
                    if let navPage = pages.value(forKey: "navigationPage") as? NSNumber {
                        pinParts.append("pagesVisibilityOverride:{navigationPage:\(navPage.boolValue ? "true" : "false")}")
                    } else {
                        pinParts.append("pagesVisibilityOverride:{navigationPage:nil}")
                    }
                } else {
                    pinParts.append("pagesVisibilityOverride:nil")
                }
                parts.append("buildingPins:{\(pinParts.joined(separator: ", "))}")
            } else {
                parts.append("buildingPins:nil")
            }
            return parts.joined(separator: "\n")
        case "DIColors?":
            guard let obj = value as? NSObject else { return "TODO" }
            let colorKeys = [
                "brandPrimaryColor",
                "primaryContentColor",
                "brandSecondaryColor",
                "secondaryContentColor",
                "accentColor"
            ]
            return formatKeyValues(obj, keys: colorKeys, skipEmptyStrings: true)
        case "DIShapes":
            guard let obj = value as? NSObject else { return "TODO" }
            return formatKeyValues(obj, keys: ["buttonShapeCornerSize", "imageShapeCornerSize", "searchBarShapeCornerSize", "bottomSheetShapeCornerSize", "popupCardShapeCornerSize"])
        case "StringsWithLanguage?", "StringsWithLanguage":
            guard let obj = value as? NSObject else { return "TODO" }
            let langKeys = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
            return formatKeyValues(obj, keys: langKeys, skipEmptyStrings: true)
        case "ToolTipsConfig?":
            guard let obj = value as? NSObject else { return "TODO" }
            let isEnabled = (obj.value(forKey: "isEnabled") as? NSNumber)?.boolValue ?? false
            let langKeys = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
            var parts: [String] = ["isEnabled:\(isEnabled ? "true" : "false")"]
            if let title = obj.value(forKey: "title") as? NSObject {
                let t = formatKeyValues(title, keys: langKeys, skipEmptyStrings: true)
                if !t.isEmpty { parts.append("title:{\(t)}") }
            }
            if let content = obj.value(forKey: "content") as? NSObject {
                let c = formatKeyValues(content, keys: langKeys, skipEmptyStrings: true)
                if !c.isEmpty { parts.append("content:{\(c)}") }
            }
            if let html = obj.value(forKey: "htmlContent") as? NSObject {
                let h = formatKeyValues(html, keys: langKeys, skipEmptyStrings: true)
                if !h.isEmpty { parts.append("htmlContent:{\(h)}") }
            }
            return parts.joined(separator: "\n")
        case "[SharedFloorsUnifiedName]?":
            // Supports [SharedFloorsUnifiedName] or NSArray<SharedFloorsUnifiedName>
            let objects: [NSObject]
            if let arr = value as? [NSObject] {
                objects = arr
            } else if let nsArr = value as? NSArray {
                objects = nsArr.compactMap { $0 as? NSObject }
            } else {
                return "nil"
            }
            let sorted = objects.sorted { a, b in
                let va = (a.value(forKey: "venueId") as? String) ?? ""
                let vb = (b.value(forKey: "venueId") as? String) ?? ""
                return va.localizedCaseInsensitiveCompare(vb) == .orderedAscending
            }
            if sorted.isEmpty {
                return "[]"
            }
            let langKeysForUnified = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
            let blocks: [String] = sorted.map { obj in
                let venueId = (obj.value(forKey: "venueId") as? String) ?? ""
                let unified = obj.value(forKey: "unifiedName") as? NSObject
                var lines: [String] = []
                lines.append("venueId:\(venueId)")
                if let unified = unified {
                    for key in langKeysForUnified {
                        guard let v = unified.value(forKey: key) as? String, !v.isEmpty else { continue }
                        lines.append("\t\(key):\(v)")
                    }
                }
                return lines.joined(separator: "\n")
            }
            return blocks.joined(separator: "\n\n")
        case "[VenueAnchorPoiConfig]?":
            // Supports [VenueAnchorPoiConfig] or NSArray<VenueAnchorPoiConfig>
            let objects: [NSObject]
            if let arr = value as? [NSObject] {
                objects = arr
            } else if let nsArr = value as? NSArray {
                objects = nsArr.compactMap { $0 as? NSObject }
            } else {
                return "nil"
            }
            let sortedConfigs = objects.sorted { a, b in
                let va = (a.value(forKey: "venueId") as? String) ?? ""
                let vb = (b.value(forKey: "venueId") as? String) ?? ""
                return va.localizedCaseInsensitiveCompare(vb) == .orderedAscending
            }
            if sortedConfigs.isEmpty {
                return "[]"
            }
            let configBlocks: [String] = sortedConfigs.map { obj in
                let venueId = (obj.value(forKey: "venueId") as? String) ?? ""
                var poiIds: [String] = []
                if let arr = obj.value(forKey: "poiIds") as? [String] {
                    poiIds = arr
                } else if let nsArr = obj.value(forKey: "poiIds") as? NSArray {
                    poiIds = nsArr.compactMap { $0 as? String }
                }
                let poiIdsText = "[\(poiIds.joined(separator: ","))]"
                return "venueId:\(venueId)\n\tpoiIds:\(poiIdsText)"
            }
            return configBlocks.joined(separator: "\n\n")
        case "[VenueLevelFacilityInfoConfig]?":
            let objects: [NSObject]
            if let arr = value as? [NSObject] {
                objects = arr
            } else if let nsArr = value as? NSArray {
                objects = nsArr.compactMap { $0 as? NSObject }
            } else {
                return "nil"
            }
            if objects.isEmpty { return "[]" }
            let blocks: [String] = objects.map { obj in
                let venueId = (obj.value(forKey: "venueId") as? String) ?? ""
                var lines: [String] = ["venueId:\(venueId)"]
                func facilityLines(_ key: String) -> String {
                    guard let arr = (obj.value(forKey: "venueLevelFacilityInfo") as? NSObject)?.value(forKey: key) else { return "nil" }
                    let items: [NSObject]
                    if let a = arr as? [NSObject] { items = a }
                    else if let n = arr as? NSArray { items = n.compactMap { $0 as? NSObject } }
                    else { return "nil" }
                    if items.isEmpty { return "[]" }
                    let parts = items.map { item -> String in
                        let id = (item.value(forKey: "id") as? String) ?? ""
                        let facs: [String]
                        if let a = item.value(forKey: "facilities") as? [String] { facs = a }
                        else if let n = item.value(forKey: "facilities") as? NSArray { facs = n.compactMap { $0 as? String } }
                        else { facs = [] }
                        return "\(id):[\(facs.joined(separator: ","))]"
                    }
                    return parts.joined(separator: ";")
                }
                lines.append("  buildings:\(facilityLines("buildings"))")
                lines.append("  floors:\(facilityLines("floors"))")
                lines.append("  sharedFloors:\(facilityLines("sharedFloors"))")
                return lines.joined(separator: "\n")
            }
            return blocks.joined(separator: "\n\n")
        case "AttributionConfig?":
            guard let obj = value as? NSObject else { return "nil" }
            var parts: [String] = []
            if let text = obj.value(forKey: "text") as? String {
                parts.append("text:\(text)")
            } else {
                parts.append("text:nil")
            }
            if let url = obj.value(forKey: "url") as? String {
                parts.append("url:\(url)")
            } else {
                parts.append("url:nil")
            }
            return parts.joined(separator: "\n")
        case "CopyrightConfig?":
            guard let obj = value as? NSObject else { return "nil" }
            var parts: [String] = []
            if let alpha = obj.value(forKey: "alpha") as? NSNumber {
                parts.append("alpha:\(alpha.stringValue)")
            }
            if let url = obj.value(forKey: "imageUrl") as? String {
                parts.append("imageUrl:\(url)")
            }
            if let w = obj.value(forKey: "imageWidth") as? NSNumber {
                parts.append("imageWidth:\(w.stringValue)")
            }
            if let h = obj.value(forKey: "imageHeight") as? NSNumber {
                parts.append("imageHeight:\(h.stringValue)")
            }
            return parts.joined(separator: "\n")
        case "FilterChipsConfig?":
            guard let obj = value as? NSObject else { return "nil" }
            var lines: [String] = []

            let isDisabled = (obj.value(forKey: "isDisabled") as? NSNumber)?.boolValue ?? false
            lines.append("isDisabled:\(isDisabled ? "true" : "false")")

            // regions
            if let regionsVal = obj.value(forKey: "regions") {
                let names: [String]
                if let arr = regionsVal as? [NSObject] {
                    names = arr.compactMap { $0.value(forKey: "name") as? String }
                } else if let nsArr = regionsVal as? NSArray {
                    names = nsArr.compactMap { ($0 as? NSObject)?.value(forKey: "name") as? String }
                } else {
                    names = []
                }
                lines.append("regions:[\(names.joined(separator: ","))]")
            }

            if obj.value(forKey: "globalEventCardKeys") != nil {
                lines.append("globalEventCardKeys:(unreadable)")
            }
            if obj.value(forKey: "venueEventCardKeys") != nil {
                lines.append("venueEventCardKeys:(unreadable)")
            }
            if obj.value(forKey: "flatMenuConfig") != nil {
                lines.append("flatMenuConfig:(unreadable)")
            }
            if obj.value(forKey: "hierarchicalMenuConfig") != nil {
                lines.append("hierarchicalMenuConfig:(unreadable)")
            }

            return lines.joined(separator: "\n")
        default:
            if let arr = value as? [String] {
                return arr.isEmpty ? "[]" : arr.joined(separator: ", ")
            }
            if let s = value as? String { return s }
            if let n = value as? NSNumber {
                if dataType == "Boolean" { return n.boolValue ? "true" : "false" }
                return n.stringValue
            }
            return ""
        }
    }

    private func updateUI() {}

    @objc private func showMenu() {
        // Present from the navigation controller so the overlay can cover the navigation bar; Main view sits below the nav bar
        let presenting = navigationController ?? self
        CategoryListViewController.present(
            on: presenting,
            delegate: self,
            titles: menuTitles,
            defaultSelect: currentIndex
        )
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configSetItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConfigSetCell.id, for: indexPath) as! ConfigSetCell
        let name = configSetItems[indexPath.row]
        cell.configure(title: name + " : ", detail: detailText(forKey: name))

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 15)
        deleteButton.tag = indexPath.row
        deleteButton.addTarget(self, action: #selector(configCellDeleteTapped(_:)), for: .touchUpInside)
        deleteButton.sizeToFit()
        cell.accessoryView = deleteButton

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let featureName = configSetItems[indexPath.row]
        guard let vc = FeatureConstants.viewController(forFeature: featureName) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func configCellDeleteTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0, index < configSetItems.count else { return }
        let key = configSetItems[index]

        // Restores the default value by writing back to diConfig and updating configSet through saveChange
        let defaultValue = Config.shared.defaultValue(forKey: key)
        (Config.shared.diConfig as NSObject).setValue(defaultValue, forKey: key)
        Config.shared.saveChange([key: defaultValue])

        // Refreshes the list
        refreshConfigSetItems()
    }
}

extension MainViewController: CategoryListViewControllerDelegate {
    func categoryListViewController(_ menu: CategoryListViewController, didSelect index: Int) {
        currentIndex = index
        pendingPushIndex = index
    }

    func categoryListViewControllerDidDismiss(_ menu: CategoryListViewController) {
        guard let index = pendingPushIndex else { return }
        pendingPushIndex = nil
        let title = menuTitles.indices.contains(index) ? menuTitles[index] : "Detail"
        navigationController?.pushViewController(FeatureListViewController(categoryTitle: title), animated: true)
    }
}
