//
//  FilterChipsConfigViewController.swift
//  UISDKKmpSample
//
//  filterChipsConfig feature detail page
//  Name: filterChipsConfig
//  Type: FilterChipsConfig?
//  Default: nil
//  Description: Configuration for the filter chips component.
//

import UIKit
import SnapKit
import DropInUISDK

// MARK: - File-private helpers

private let kDKRegionCodes: [String] = ["HK", "MO", "TW", "SG", "SA"]

private func dkRegion(forCode code: String) -> Region? {
    let upper = code.uppercased()
    let candidates: [String]
    switch upper {
    case "HK": candidates = ["HONG_KONG", "HONGKONG"]
    case "MO": candidates = ["MACAU"]
    case "TW": candidates = ["TAIWAN"]
    case "SG": candidates = ["SINGAPORE"]
    case "SA": candidates = ["SAUDI_ARABIA", "SAUDIARABIA"]
    default: return nil
    }
    return Region.allCases.first {
        candidates.contains($0.name.uppercased().replacingOccurrences(of: " ", with: "_"))
    }
}

private func dkSearchRange(named name: String) -> SearchRange? {
    SearchRange.allCases.first { $0.name.uppercased() == name.uppercased() }
}

private func dkSearchEventType(named name: String) -> SearchEventType? {
    SearchEventType.allCases.first { $0.name.uppercased() == name.uppercased() }
}

// MARK: -

final class FilterChipsConfigViewController: BaseFeatureViewController {

    // MARK: - Reusable: DefaultKeysEditorView

    private final class DefaultKeysEditorView: UIView {
        private let enableSegment = UISegmentedControl(items: ["nil", "DefaultKeys"])
        private let modeSegment = UISegmentedControl(items: ["Range", "Region+Event", "VenueId"])
        private let rangeSegment: UISegmentedControl
        private let rangeItems: [String]
        private let regionSegment = UISegmentedControl(items: ["nil", "HK", "MO", "TW", "SG", "SA"])
        private let eventTypeSegment = UISegmentedControl(items: ["ALL_EVENTS", "OUTDOOR_EVENTS"])
        private let venueIdField = UITextField()

        init(title: String, rangeItems: [String]) {
            self.rangeItems = rangeItems.map { $0.uppercased() }
            rangeSegment = UISegmentedControl(items: rangeItems)
            super.init(frame: .zero)
            setupUI(title: title)
            enableSegment.addTarget(self, action: #selector(enableChanged), for: .valueChanged)
            modeSegment.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        }

        required init?(coder: NSCoder) { fatalError() }

        private func setupUI(title: String) {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 10
            stack.alignment = .fill
            addSubview(stack)
            stack.snp.makeConstraints { $0.edges.equalToSuperview() }

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.textColor = .secondaryLabel

            enableSegment.selectedSegmentIndex = 0
            modeSegment.isHidden = true
            rangeSegment.selectedSegmentIndex = 0
            rangeSegment.isHidden = true
            regionSegment.selectedSegmentIndex = 0
            regionSegment.isHidden = true
            eventTypeSegment.selectedSegmentIndex = 0
            eventTypeSegment.isHidden = true
            venueIdField.borderStyle = .roundedRect
            venueIdField.placeholder = "venueId"
            venueIdField.autocorrectionType = .no
            venueIdField.isHidden = true

            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(enableSegment)
            stack.addArrangedSubview(modeSegment)
            stack.addArrangedSubview(rangeSegment)
            stack.addArrangedSubview(regionSegment)
            stack.addArrangedSubview(eventTypeSegment)
            stack.addArrangedSubview(venueIdField)
        }

        @objc private func enableChanged() { updateVisibility() }
        @objc private func modeChanged() { updateVisibility() }

        private func updateVisibility() {
            let isEnabled = enableSegment.selectedSegmentIndex == 1
            modeSegment.isHidden = !isEnabled
            guard isEnabled else {
                rangeSegment.isHidden = true
                regionSegment.isHidden = true
                eventTypeSegment.isHidden = true
                venueIdField.isHidden = true
                return
            }
            let mode = modeSegment.selectedSegmentIndex
            rangeSegment.isHidden = (mode != 0)
            regionSegment.isHidden = (mode != 1)
            eventTypeSegment.isHidden = (mode != 1)
            venueIdField.isHidden = (mode != 2)
        }

        func parse() -> DefaultKeys? {
            guard enableSegment.selectedSegmentIndex == 1 else { return nil }
            switch modeSegment.selectedSegmentIndex {
            case 0:
                let name = rangeItems[rangeSegment.selectedSegmentIndex]
                guard let range = dkSearchRange(named: name) else { return nil }
                return DefaultKeys.companion.build(range: range)
            case 1:
                let idx = regionSegment.selectedSegmentIndex
                let region: Region? = idx == 0 ? nil : dkRegion(forCode: kDKRegionCodes[idx - 1])
                guard let eventType = dkSearchEventType(named: eventTypeSegment.selectedSegmentIndex == 0 ? "ALL_EVENTS" : "OUTDOOR_EVENTS") else { return nil }
                return DefaultKeys.companion.build(region: region, eventType: eventType)
            case 2:
                let venueId = (venueIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !venueId.isEmpty else { return nil }
                return DefaultKeys.companion.build(venueId: venueId)
            default:
                return nil
            }
        }

        func prefill(keys: DefaultKeys) {
            resetToNil()
        }

        func resetToNil() {
            enableSegment.selectedSegmentIndex = 0
            updateVisibility()
        }
    }

    // MARK: - Reusable: MenuConfigEditorView

    private final class MenuConfigEditorView: UIView {
        private let enableSegment = UISegmentedControl(items: ["nil", "MenuConfig"])
        private let optionsContainer = UIStackView()
        private let globalSwitch = UISwitch()
        private let nearbySwitch = UISwitch()
        private let allEventsSwitch = UISwitch()
        private let outdoorEventsSwitch = UISwitch()

        init(title: String) {
            super.init(frame: .zero)
            setupUI(title: title)
            enableSegment.addTarget(self, action: #selector(enableChanged), for: .valueChanged)
        }

        required init?(coder: NSCoder) { fatalError() }

        private func makeSwitchRow(label: String, toggle: UISwitch) -> UIView {
            let row = UIView()
            row.snp.makeConstraints { $0.height.greaterThanOrEqualTo(36) }
            let lbl = UILabel()
            lbl.text = label
            lbl.font = .systemFont(ofSize: 14)
            lbl.textColor = .label
            row.addSubview(lbl)
            row.addSubview(toggle)
            lbl.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(toggle.snp.leading).offset(-12)
            }
            toggle.snp.makeConstraints { make in
                make.centerY.trailing.equalToSuperview()
            }
            return row
        }

        private func makeSectionLabel(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = .systemFont(ofSize: 12, weight: .semibold)
            l.textColor = .secondaryLabel
            return l
        }

        private func setupUI(title: String) {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .fill
            addSubview(stack)
            stack.snp.makeConstraints { $0.edges.equalToSuperview() }

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.textColor = .secondaryLabel

            enableSegment.selectedSegmentIndex = 0

            optionsContainer.axis = .vertical
            optionsContainer.spacing = 0
            optionsContainer.alignment = .fill
            optionsContainer.isHidden = true

            optionsContainer.addArrangedSubview(makeSectionLabel("root"))
            optionsContainer.addArrangedSubview(makeSwitchRow(label: "GLOBAL", toggle: globalSwitch))
            optionsContainer.addArrangedSubview(makeSwitchRow(label: "NEARBY", toggle: nearbySwitch))
            optionsContainer.addArrangedSubview(makeSectionLabel("additional"))
            optionsContainer.addArrangedSubview(makeSwitchRow(label: "ALL_EVENTS", toggle: allEventsSwitch))
            optionsContainer.addArrangedSubview(makeSwitchRow(label: "OUTDOOR_EVENTS", toggle: outdoorEventsSwitch))

            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(enableSegment)
            stack.addArrangedSubview(optionsContainer)
        }

        @objc private func enableChanged() { updateVisibility() }

        private func updateVisibility() {
            optionsContainer.isHidden = enableSegment.selectedSegmentIndex != 1
        }

        func parse() -> MenuConfig? {
            guard enableSegment.selectedSegmentIndex == 1 else { return nil }
            var root: [SearchRange] = []
            if globalSwitch.isOn, let r = dkSearchRange(named: "GLOBAL") { root.append(r) }
            if nearbySwitch.isOn, let r = dkSearchRange(named: "NEARBY") { root.append(r) }
            guard !root.isEmpty else { return nil }
            var additional: [SearchEventType] = []
            if allEventsSwitch.isOn, let t = dkSearchEventType(named: "ALL_EVENTS") { additional.append(t) }
            if outdoorEventsSwitch.isOn, let t = dkSearchEventType(named: "OUTDOOR_EVENTS") { additional.append(t) }
            guard !additional.isEmpty else { return nil }
            return MenuConfig.companion.build(root: root, additional: additional)
        }

        func prefill(menu: MenuConfig) {
            resetToNil()  // root/additional properties are not exposed and cannot be read
        }

        func resetToNil() {
            enableSegment.selectedSegmentIndex = 0
            globalSwitch.isOn = false
            nearbySwitch.isOn = false
            allEventsSwitch.isOn = false
            outdoorEventsSwitch.isOn = false
            updateVisibility()
        }

    }

    // MARK: - Properties

    private let configSegmentControl = UISegmentedControl(items: ["nil", "FilterChipsConfig"])
    private weak var formContainer: UIView?

    private let isDisabledSwitch = UISwitch()

    private let regionsSegmentControl = UISegmentedControl(items: ["nil", "[Region]"])
    private let regionsOptionsContainer = UIStackView()
    private var regionSwitches: [Region: UISwitch] = [:]

    private let globalKeysEditor = DefaultKeysEditorView(
        title: "globalEventCardKeys (DefaultKeys)",
        rangeItems: ["GLOBAL", "NEARBY"]
    )
    private let venueKeysEditor = DefaultKeysEditorView(
        title: "venueEventCardKeys (DefaultKeys)",
        rangeItems: ["CURRENT_VENUE"]
    )
    private let flatMenuEditor = MenuConfigEditorView(title: "flatMenuConfig (MenuConfig)")
    private let hierarchicalMenuEditor = MenuConfigEditorView(title: "hierarchicalMenuConfig (MenuConfig)")

    // MARK: - Init

    required init(featureName: String) {
        super.init(featureName: featureName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 20
        content.alignment = .fill
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        scrollView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        addDescriptionContent(to: content)

        let selectorRow = selectorRowView()
        let spacer = spacerView(height: 8)
        let form = buildFormContainer()
        form.isHidden = true
        formContainer = form
        addParameterSection(to: content, views: selectorRow, spacer, form)

        configSegmentControl.addTarget(self, action: #selector(configSegmentChanged), for: .valueChanged)
        regionsSegmentControl.addTarget(self, action: #selector(regionsSegmentChanged), for: .valueChanged)
        loadCurrentValue()
    }

    override func saveBarButtonTapped() {
        if configSegmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.filterChipsConfig = nil
            Config.shared.saveChange([featureName: nil])
            super.saveBarButtonTapped()
            return
        }

        let config = FilterChipsConfig(
            isDisabled: isDisabledSwitch.isOn,
            regions: parseRegionsOrNil(),
            globalEventCardKeys: globalKeysEditor.parse(),
            venueEventCardKeys: venueKeysEditor.parse(),
            flatMenuConfig: flatMenuEditor.parse(),
            hierarchicalMenuConfig: hierarchicalMenuEditor.parse()
        )
        Config.shared.diConfig.filterChipsConfig = config
        Config.shared.saveChange([featureName: config])
        super.saveBarButtonTapped()
    }

    // MARK: - Load

    private func loadCurrentValue() {
        guard let cfg = Config.shared.configValue(forKey: featureName) as? FilterChipsConfig else {
            configSegmentControl.selectedSegmentIndex = 0
            configSegmentChanged()
            return
        }

        configSegmentControl.selectedSegmentIndex = 1
        isDisabledSwitch.isOn = cfg.isDisabled

        if let regions = cfg.regions {
            regionsSegmentControl.selectedSegmentIndex = 1
            for region in Array(Region.allCases) {
                regionSwitches[region]?.isOn = regions.contains(region)
            }
        } else {
            regionsSegmentControl.selectedSegmentIndex = 0
            for region in Array(Region.allCases) {
                regionSwitches[region]?.isOn = false
            }
        }
        regionsSegmentChanged()

        if let keys = cfg.globalEventCardKeys { globalKeysEditor.prefill(keys: keys) } else { globalKeysEditor.resetToNil() }
        if let keys = cfg.venueEventCardKeys { venueKeysEditor.prefill(keys: keys) } else { venueKeysEditor.resetToNil() }
        if let menu = cfg.flatMenuConfig { flatMenuEditor.prefill(menu: menu) } else { flatMenuEditor.resetToNil() }
        if let menu = cfg.hierarchicalMenuConfig { hierarchicalMenuEditor.prefill(menu: menu) } else { hierarchicalMenuEditor.resetToNil() }

        configSegmentChanged()
    }

    // MARK: - Visibility

    @objc private func configSegmentChanged() {
        let isCustom = configSegmentControl.selectedSegmentIndex == 1
        formContainer?.isHidden = !isCustom
        formContainer?.alpha = isCustom ? 1.0 : 0.4
        formContainer?.isUserInteractionEnabled = isCustom
    }

    @objc private func regionsSegmentChanged() {
        regionsOptionsContainer.isHidden = regionsSegmentControl.selectedSegmentIndex != 1
    }

    // MARK: - Parse helpers

    private func parseRegionsOrNil() -> [Region]? {
        guard regionsSegmentControl.selectedSegmentIndex == 1 else { return nil }
        return Array(Region.allCases).filter { regionSwitches[$0]?.isOn == true }
    }

    // MARK: - UI builders

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "filterChipsConfig :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(configSegmentControl)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(configSegmentControl.snp.leading).offset(-12)
        }
        configSegmentControl.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        configSegmentControl.selectedSegmentIndex = 0
        return container
    }

    private func buildFormContainer() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16
        container.alignment = .fill

        let disabledRow = UIStackView()
        disabledRow.axis = .horizontal
        disabledRow.alignment = .center
        disabledRow.distribution = .equalSpacing
        let disabledLabel = UILabel()
        disabledLabel.text = "isDisabled"
        disabledLabel.font = .systemFont(ofSize: 15, weight: .medium)
        disabledLabel.textColor = .label
        disabledRow.addArrangedSubview(disabledLabel)
        disabledRow.addArrangedSubview(isDisabledSwitch)
        container.addArrangedSubview(disabledRow)

        container.addArrangedSubview(regionsSection())
        container.addArrangedSubview(globalKeysEditor)
        container.addArrangedSubview(venueKeysEditor)
        container.addArrangedSubview(flatMenuEditor)
        container.addArrangedSubview(hierarchicalMenuEditor)

        return container
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { $0.height.equalTo(height) }
        return v
    }

    private func regionsSection() -> UIView {
        regionsSegmentControl.selectedSegmentIndex = 0
        regionsOptionsContainer.axis = .vertical
        regionsOptionsContainer.spacing = 8
        regionsOptionsContainer.alignment = .fill
        regionsOptionsContainer.isHidden = true

        regionSwitches = [:]
        for region in Array(Region.allCases) {
            let row = UIView()
            row.snp.makeConstraints { $0.height.greaterThanOrEqualTo(36) }
            let label = UILabel()
            label.text = region.name
            label.font = .systemFont(ofSize: 14)
            label.textColor = .label
            let toggle = UISwitch()
            regionSwitches[region] = toggle
            row.addSubview(label)
            row.addSubview(toggle)
            label.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(toggle.snp.leading).offset(-12)
            }
            toggle.snp.makeConstraints { make in
                make.centerY.trailing.equalToSuperview()
            }
            regionsOptionsContainer.addArrangedSubview(row)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Multi-select regions from Region.allCases (displayed by .name)."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "regions"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(regionsSegmentControl)
        container.addArrangedSubview(regionsOptionsContainer)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
