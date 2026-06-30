//
//  SharedFloorsUnifiedNamesViewController.swift
//  UISDKKmpSample
//
//  sharedFloorsUnifiedNames 功能详情页（方案 A：卡片列表，保存逻辑待实现）
//  Name: sharedFloorsUnifiedNames
//  Type: [SharedFloorsUnifiedName]?
//  Default: nil
//  Description: List of renamed shared floors unified names in a venue.
//  SharedFloorsUnifiedName (DropInUISDK): venueId: String, unifiedName: StringsWithLanguage
//

import UIKit
import SnapKit
import DropInUISDK

final class SharedFloorsUnifiedNamesViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[SharedFloorsUnifiedName]"])
    private let entriesStackView = UIStackView()
    private let addButton = UIButton(type: .system)
    private var listContainer: UIView?
    private var entryCards: [EntryCard] = []

    private static let maxEntryCount = 10
    private static let unifiedNameLabels = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]

    private enum EntriesValidationError: LocalizedError {
        case invalidEntry
        var errorDescription: String? {
            switch self {
            case .invalidEntry:
                return "Please fill venueId and at least one unified name for each entry."
            }
        }
    }

    /// 单条条目的视图与输入引用
    struct EntryCard {
        let containerView: UIView
        let venueIdField: UITextField
        let unifiedNameFields: [UITextField]
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

        // 从 diConfig 读取当前值并填充 UI
        let current = Config.shared.configValue(forKey: featureName) as? [SharedFloorsUnifiedName]
            ?? (Config.shared.configValue(forKey: featureName) as? NSArray)?
            .compactMap { $0 as? SharedFloorsUnifiedName }
        // 注意：长度为 0 的数组依然视为「列表」而不是 nil
        if let configs = current {
            segmentControl.selectedSegmentIndex = 1
            listContainer.isHidden = false
            for config in configs.prefix(Self.maxEntryCount) {
                let card = addEntryCard()
                card.venueIdField.text = config.venueId
                let un = config.unifiedName
                let kvcKeys = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
                let unObj = un as NSObject?
                for (index, key) in kvcKeys.enumerated() where index < card.unifiedNameFields.count {
                    card.unifiedNameFields[index].text = unObj?.value(forKey: key) as? String
                }
            }
            updateAddButtonState()
        } else {
            segmentControl.selectedSegmentIndex = 0
            listContainer.isHidden = true
        }

        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        addButton.addTarget(self, action: #selector(addEntryTapped), for: .touchUpInside)
        updateAddButtonState()
    }

    override func saveBarButtonTapped() {
        let (error, items) = validateAndBuild()
        if let error = error {
            let alert = UIAlertController(title: "Invalid", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.sharedFloorsUnifiedNames = nil
            Config.shared.saveChange([featureName: nil as [SharedFloorsUnifiedName]?])
        } else if let items = items {
            Config.shared.diConfig.sharedFloorsUnifiedNames = items
            Config.shared.saveChange([featureName: items])
        }

        super.saveBarButtonTapped()
    }

    /// 校验并构建 SharedFloorsUnifiedName 数组。
    /// - 当 segment 为 nil 时返回 (nil, nil)
    /// - 当 segment 为列表且未添加任何 entry 时返回 (nil, [])
    /// - 当存在 entry 且任意一条 venueId 为空或所有 unifiedName 为空时返回错误
    private func validateAndBuild() -> (error: Error?, items: [SharedFloorsUnifiedName]?) {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }

        // 未添加任何 entry，视为空数组
        guard !entryCards.isEmpty else {
            return (nil, [])
        }

        var results: [SharedFloorsUnifiedName] = []

        for card in entryCards {
            let venueId = (card.venueIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let nameValues = card.unifiedNameFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }

            let hasUnifiedName = nameValues.contains { !$0.isEmpty }

            // 每个 entry 必须有 venueId 且至少一个 unifiedName 非空
            guard !venueId.isEmpty, hasUnifiedName else {
                return (EntriesValidationError.invalidEntry, nil)
            }

            let optValues = nameValues.map { s in s.isEmpty ? nil : s }
            let strings = StringsWithLanguage(
                default: optValues[0],
                en: optValues[1],
                ja: optValues[2],
                ko: optValues[3],
                zhHans: optValues[4],
                zhHant: optValues[5],
                zhHantTW: optValues[6],
                ar: optValues[7],
                fr: optValues[8],
                it: optValues[9]
            )
            let item = SharedFloorsUnifiedName(venueId: venueId, unifiedName: strings)
            results.append(item)
        }

        return (nil, Array(results.prefix(Self.maxEntryCount)))
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
        label.text = "sharedFloorsUnifiedNames :"
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

        var unifiedNameFields: [UITextField] = []
        for _ in Self.unifiedNameLabels {
            let f = UITextField()
            f.placeholder = "nil"
            f.borderStyle = .roundedRect
            f.font = .systemFont(ofSize: 15)
            f.autocorrectionType = .no
            unifiedNameFields.append(f)
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

        let unifiedLabel = UILabel()
        unifiedLabel.text = "unifiedName (StringsWithLanguage)"
        unifiedLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        unifiedLabel.textColor = .secondaryLabel
        innerStack.addArrangedSubview(unifiedLabel)

        let stringsStack = UIStackView()
        stringsStack.axis = .vertical
        stringsStack.spacing = 17
        stringsStack.alignment = .fill
        for (idx, labelText) in Self.unifiedNameLabels.enumerated() {
            let row = inputRowView(label: "\(labelText):", textField: unifiedNameFields[idx])
            stringsStack.addArrangedSubview(row)
        }
        innerStack.addArrangedSubview(stringsStack)

        cardContainer.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let card = EntryCard(
            containerView: cardContainer,
            venueIdField: venueIdField,
            unifiedNameFields: unifiedNameFields
        )
        removeButton.addAction(UIAction { [weak self] _ in
            self?.removeEntryCard(card)
        }, for: .touchUpInside)

        entryCards.append(card)
        entriesStackView.addArrangedSubview(cardContainer)
        return card
    }

    private func inputRowView(label text: String, textField field: UITextField) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(field)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(field.snp.leading).offset(-8)
        }
        field.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }
        return container
    }
}
