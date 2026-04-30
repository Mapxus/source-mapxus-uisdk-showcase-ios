//
//  VenueAnchorPoiConfigsViewController.swift
//  UISDKKmpSample
//
//  venueAnchorPoiConfigs 功能详情页
//  Name: venueAnchorPoiConfigs
//  Type: [VenueAnchorPoiConfig]?
//  Default: nil
//  VenueAnchorPoiConfig (DropInUISDK): venueId: String, poiIds: [String]
//  Up to 10 entries; per entry up to 20 POI IDs.
//

import UIKit
import SnapKit
import DropInUISDK

final class VenueAnchorPoiConfigsViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[VenueAnchorPoiConfig]"])
    private let entriesStackView = UIStackView()
    private let addButton = UIButton(type: .system)
    private var listContainer: UIView?
    private var entryCards: [EntryCard] = []

    private static let maxEntryCount = 10
    private static let maxPoiIdsPerEntry = 20

    private enum EntriesValidationError: LocalizedError {
        case invalidEntry

        var errorDescription: String? {
            switch self {
            case .invalidEntry:
                return "Please fill venueId and at least one poiId (comma separated) for each entry."
            }
        }
    }

    struct EntryCard {
        let containerView: UIView
        let venueIdField: UITextField
        let poiIdsTextView: UITextView
    }

    required init(featureName: String) {
        super.init(featureName: featureName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

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
        let spacer = spacerView(height: 6)
        let listContainer = makeListContainer()
        self.listContainer = listContainer
        listContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, listContainer)

        let current = Config.shared.configValue(forKey: featureName) as? [VenueAnchorPoiConfig]
        // 注意：长度为 0 的数组依然视为「列表」而不是 nil
        if let configs = current {
            segmentControl.selectedSegmentIndex = 1
            listContainer.isHidden = false
            for config in configs.prefix(Self.maxEntryCount) {
                let card = addEntryCard()
                card.venueIdField.text = config.venueId
                card.poiIdsTextView.text = config.poiIds.joined(separator: ",")
            }
            updateAddButtonState()
        } else {
            segmentControl.selectedSegmentIndex = 0
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        addButton.addTarget(self, action: #selector(addEntryTapped), for: .touchUpInside)
        updateAddButtonState()
    }

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.venueAnchorPoiConfigs = nil
            Config.shared.saveChange([featureName: nil as [VenueAnchorPoiConfig]?])
        } else {
            let (error, configs) = validateAndBuild()
            if let error = error {
                let alert = UIAlertController(title: "Invalid", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            Config.shared.diConfig.venueAnchorPoiConfigs = configs
            Config.shared.saveChange([featureName: configs])
        }
        super.saveBarButtonTapped()
    }

    private func validateAndBuild() -> (error: Error?, configs: [VenueAnchorPoiConfig]?) {
        // segment 选中 nil，直接返回 nil
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }

        // 未添加任何 entry，视为空数组（长度 0 合法）
        guard !entryCards.isEmpty else {
            return (nil, [])
        }

        var configs: [VenueAnchorPoiConfig] = []

        for card in entryCards {
            let venueId = (card.venueIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let raw = (card.poiIdsTextView.text ?? "")
            let ids = raw
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let capped = Array(ids.prefix(Self.maxPoiIdsPerEntry))

            // 每个卡片必须同时填 venueId 和至少一个 poiId
            guard !venueId.isEmpty, !capped.isEmpty else {
                return (EntriesValidationError.invalidEntry, nil)
            }

            let config = VenueAnchorPoiConfig(venueId: venueId, poiIds: capped)
            configs.append(config)
        }

        return (nil, Array(configs.prefix(Self.maxEntryCount)))
    }

    @objc private func segmentChanged() {
        listContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    @objc private func addEntryTapped() {
        guard entryCards.count < Self.maxEntryCount else { return }
        _ = addEntryCard()
        updateAddButtonState()
    }

    private func removeEntryCard(_ card: EntryCard) {
        guard let idx = entryCards.firstIndex(where: { $0.containerView === card.containerView }) else { return }
        entryCards[idx].containerView.removeFromSuperview()
        entryCards.remove(at: idx)
        updateAddButtonState()
    }

    private func updateAddButtonState() {
        addButton.isEnabled = entryCards.count < Self.maxEntryCount
        addButton.setTitle("Add entry (\(entryCards.count)/\(Self.maxEntryCount))", for: .normal)
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in make.height.equalTo(height) }
        return v
    }

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "venueAnchorPoiConfigs :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)

        let segmentWrapper = UIView()
        segmentWrapper.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        container.addArrangedSubview(segmentWrapper)
        return container
    }

    private func makeListContainer() -> UIView {
        entriesStackView.axis = .vertical
        entriesStackView.spacing = 16
        entriesStackView.alignment = .fill

        addButton.setTitle("Add entry (0/\(Self.maxEntryCount))", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        let container = UIStackView(arrangedSubviews: [entriesStackView, addButton])
        container.axis = .vertical
        container.spacing = 16
        container.alignment = .fill
        return container
    }

    private func addEntryCard() -> EntryCard {
        let cardContainer = UIView()
        cardContainer.backgroundColor = .tertiarySystemGroupedBackground
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.masksToBounds = true

        let venueIdField = UITextField()
        venueIdField.placeholder = "venueId"
        venueIdField.borderStyle = .roundedRect
        venueIdField.font = .systemFont(ofSize: 15)
        venueIdField.autocorrectionType = .no
        venueIdField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let poiIdsTextView = UITextView()
        poiIdsTextView.font = .systemFont(ofSize: 15)
        poiIdsTextView.isScrollEnabled = false
        poiIdsTextView.layer.cornerRadius = 8
        poiIdsTextView.layer.masksToBounds = true
        poiIdsTextView.layer.borderWidth = 1
        poiIdsTextView.layer.borderColor = UIColor.separator.cgColor
        poiIdsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        poiIdsTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(60)
        }

        let removeButton = UIButton(type: .system)
        removeButton.setTitle("Remove", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 14)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)

        let headerRow = UIView()
        headerRow.addSubview(venueIdField)
        headerRow.addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        venueIdField.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(removeButton.snp.leading).offset(-12)
        }

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 12
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let venueLabel = UILabel()
        venueLabel.text = "venueId"
        venueLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        venueLabel.textColor = .secondaryLabel
        innerStack.addArrangedSubview(venueLabel)
        innerStack.addArrangedSubview(headerRow)

        let poiIdsLabel = UILabel()
        poiIdsLabel.text = "poiIds (up to \(Self.maxPoiIdsPerEntry), comma separated)"
        poiIdsLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        poiIdsLabel.textColor = .secondaryLabel
        innerStack.addArrangedSubview(poiIdsLabel)
        innerStack.addArrangedSubview(poiIdsTextView)

        cardContainer.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let card = EntryCard(
            containerView: cardContainer,
            venueIdField: venueIdField,
            poiIdsTextView: poiIdsTextView
        )
        removeButton.addAction(UIAction { [weak self] _ in
            self?.removeEntryCard(card)
        }, for: .touchUpInside)

        entryCards.append(card)
        entriesStackView.addArrangedSubview(cardContainer)
        return card
    }
}
