//
//  VenueLevelFacilityInfoConfigViewController.swift
//  UISDKKmpSample
//
//  venueLevelFacilityInfoConfig 功能详情页
//  Name: venueLevelFacilityInfoConfig
//  Type: [VenueLevelFacilityInfoConfig]?
//  Default: nil
//  Description: Custom facility information configuration for venues. Each entry specifies facility groups (buildings, floors, and shared floors) for a given venue. When null, no custom facility info configuration is applied.
//

import UIKit
import SnapKit
import DropInUISDK

final class VenueLevelFacilityInfoConfigViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[VenueLevelFacilityInfoConfig]"])
    private let entriesStackView = UIStackView()
    private let addEntryButton = UIButton(type: .system)
    private var listContainer: UIView?
    private var entryCards: [EntryCard] = []

    private static let maxEntryCount = 10

    // MARK: - Entry Card model

    struct FacilityGroupCard {
        let container: UIView
        /// Each row: (idField, facilitiesTextView)
        var rows: [FacilityRowCard]
        let addRowButton: UIButton
        let rowsStack: UIStackView
    }

    struct FacilityRowCard {
        let container: UIView
        let idField: UITextField
        let facilitiesTextView: UITextView
    }

    struct EntryCard {
        let container: UIView
        let venueIdField: UITextField
        var buildingsGroup: FacilityGroupCard
        var floorsGroup: FacilityGroupCard
        var sharedFloorsGroup: FacilityGroupCard
    }

    // MARK: - Init

    required init(featureName: String) {
        super.init(featureName: featureName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad

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
        let spacer = makeSpacerView(height: 6)
        let list = makeListContainerView()
        listContainer = list
        list.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, list)

        // Restore saved value
        let current = Config.shared.configValue(forKey: featureName) as? [VenueLevelFacilityInfoConfig]
        if let configs = current {
            segmentControl.selectedSegmentIndex = 1
            listContainer?.isHidden = false
            for config in configs.prefix(Self.maxEntryCount) {
                let card = addEntryCard()
                card.venueIdField.text = config.venueId
                let info = config.venueLevelFacilityInfo
                restoreFacilityGroup(card.buildingsGroup, from: info.buildings)
                restoreFacilityGroup(card.floorsGroup, from: info.floors)
                restoreFacilityGroup(card.sharedFloorsGroup, from: info.sharedFloors)
            }
            updateAddEntryButtonState()
        } else {
            segmentControl.selectedSegmentIndex = 0
        }

        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        addEntryButton.addTarget(self, action: #selector(addEntryTapped), for: .touchUpInside)
        updateAddEntryButtonState()
    }

    private func restoreFacilityGroup(_ group: FacilityGroupCard, from items: [FacilityInfo]?) {
        guard let items = items, !items.isEmpty else { return }
        for item in items {
            let row = addFacilityRow(to: group)
            row.idField.text = item.id
            row.facilitiesTextView.text = item.facilities.joined(separator: ",")
        }
    }

    // MARK: - Save

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.venueLevelFacilityInfoConfig = nil
            Config.shared.saveChange([featureName: nil as [VenueLevelFacilityInfoConfig]?])
        } else {
            var configs: [VenueLevelFacilityInfoConfig] = []
            for card in entryCards {
                let venueId = (card.venueIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                guard !venueId.isEmpty else { continue }
                let buildings = buildFacilityInfoList(from: card.buildingsGroup)
                let floors = buildFacilityInfoList(from: card.floorsGroup)
                let sharedFloors = buildFacilityInfoList(from: card.sharedFloorsGroup)
                let info = VenueLevelFacilityInfo(
                    buildings: buildings.isEmpty ? nil : buildings,
                    floors: floors.isEmpty ? nil : floors,
                    sharedFloors: sharedFloors.isEmpty ? nil : sharedFloors
                )
                configs.append(VenueLevelFacilityInfoConfig(venueId: venueId, venueLevelFacilityInfo: info))
            }
            Config.shared.diConfig.venueLevelFacilityInfoConfig = configs
            Config.shared.saveChange([featureName: configs])
        }
        super.saveBarButtonTapped()
    }

    private func buildFacilityInfoList(from group: FacilityGroupCard) -> [FacilityInfo] {
        return group.rows.compactMap { row in
            let id = (row.idField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty else { return nil }
            let raw = (row.facilitiesTextView.text ?? "")
            let facilities = raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            return FacilityInfo(id: id, facilities: facilities)
        }
    }

    // MARK: - Selectors

    @objc private func segmentChanged() {
        listContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    @objc private func addEntryTapped() {
        guard entryCards.count < Self.maxEntryCount else { return }
        _ = addEntryCard()
        updateAddEntryButtonState()
    }

    // MARK: - Entry card management

    @discardableResult
    private func addEntryCard() -> EntryCard {
        let cardContainer = UIView()
        cardContainer.backgroundColor = .tertiarySystemGroupedBackground
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.masksToBounds = true

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 12
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // venueId header row
        let venueIdField = UITextField()
        venueIdField.placeholder = "venueId"
        venueIdField.borderStyle = .roundedRect
        venueIdField.font = .systemFont(ofSize: 15)
        venueIdField.autocorrectionType = .no

        let removeButton = UIButton(type: .system)
        removeButton.setTitle("Remove", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 14)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let headerRow = UIView()
        headerRow.addSubview(venueIdField)
        headerRow.addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        venueIdField.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(removeButton.snp.leading).offset(-8)
        }

        let venueIdLabel = UILabel()
        venueIdLabel.text = "venueId"
        venueIdLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        venueIdLabel.textColor = .secondaryLabel
        innerStack.addArrangedSubview(venueIdLabel)
        innerStack.addArrangedSubview(headerRow)

        // Three facility groups
        let buildingsGroup = makeFacilityGroupView(title: "buildings")
        let floorsGroup = makeFacilityGroupView(title: "floors")
        let sharedFloorsGroup = makeFacilityGroupView(title: "sharedFloors")
        innerStack.addArrangedSubview(buildingsGroup.container)
        innerStack.addArrangedSubview(floorsGroup.container)
        innerStack.addArrangedSubview(sharedFloorsGroup.container)

        cardContainer.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let card = EntryCard(
            container: cardContainer,
            venueIdField: venueIdField,
            buildingsGroup: buildingsGroup,
            floorsGroup: floorsGroup,
            sharedFloorsGroup: sharedFloorsGroup
        )
        removeButton.addAction(UIAction { [weak self] _ in
            self?.removeEntryCard(card)
        }, for: .touchUpInside)

        entryCards.append(card)
        entriesStackView.addArrangedSubview(cardContainer)
        return card
    }

    private func removeEntryCard(_ card: EntryCard) {
        guard let idx = entryCards.firstIndex(where: { $0.container === card.container }) else { return }
        entryCards[idx].container.removeFromSuperview()
        entryCards.remove(at: idx)
        updateAddEntryButtonState()
    }

    private func updateAddEntryButtonState() {
        addEntryButton.isEnabled = entryCards.count < Self.maxEntryCount
        addEntryButton.setTitle("Add venue entry (\(entryCards.count)/\(Self.maxEntryCount))", for: .normal)
    }

    // MARK: - Facility group

    private func makeFacilityGroupView(title: String) -> FacilityGroupCard {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        container.addArrangedSubview(titleLabel)

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 6
        rowsStack.alignment = .fill
        container.addArrangedSubview(rowsStack)

        let addRowButton = UIButton(type: .system)
        addRowButton.setTitle("Add \(title) row", for: .normal)
        addRowButton.titleLabel?.font = .systemFont(ofSize: 13)
        container.addArrangedSubview(addRowButton)

        let card = FacilityGroupCard(
            container: container,
            rows: [],
            addRowButton: addRowButton,
            rowsStack: rowsStack
        )

        addRowButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            _ = self.addFacilityRow(to: card)
        }, for: .touchUpInside)

        return card
    }

    @discardableResult
    private func addFacilityRow(to group: FacilityGroupCard) -> FacilityRowCard {
        let rowContainer = UIView()
        rowContainer.backgroundColor = .quaternarySystemFill
        rowContainer.layer.cornerRadius = 8
        rowContainer.layer.masksToBounds = true

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 6
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        let idField = UITextField()
        idField.placeholder = "id (e.g. venueId or buildingId)"
        idField.borderStyle = .roundedRect
        idField.font = .systemFont(ofSize: 13)
        idField.autocorrectionType = .no

        let facilitiesTextView = UITextView()
        facilitiesTextView.font = .systemFont(ofSize: 13)
        facilitiesTextView.isScrollEnabled = false
        facilitiesTextView.layer.cornerRadius = 6
        facilitiesTextView.layer.masksToBounds = true
        facilitiesTextView.layer.borderWidth = 1
        facilitiesTextView.layer.borderColor = UIColor.separator.cgColor
        facilitiesTextView.textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        facilitiesTextView.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(44) }

        let removeRowButton = UIButton(type: .system)
        removeRowButton.setTitle("Remove row", for: .normal)
        removeRowButton.titleLabel?.font = .systemFont(ofSize: 12)

        let idRow = UIView()
        idRow.addSubview(idField)
        idRow.addSubview(removeRowButton)
        removeRowButton.snp.makeConstraints { make in make.top.bottom.trailing.equalToSuperview() }
        idField.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(removeRowButton.snp.leading).offset(-6)
        }

        let facilitiesLabel = UILabel()
        facilitiesLabel.text = "facilities (comma-separated)"
        facilitiesLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        facilitiesLabel.textColor = .tertiaryLabel

        innerStack.addArrangedSubview(idRow)
        innerStack.addArrangedSubview(facilitiesLabel)
        innerStack.addArrangedSubview(facilitiesTextView)

        rowContainer.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let row = FacilityRowCard(container: rowContainer, idField: idField, facilitiesTextView: facilitiesTextView)

        removeRowButton.addAction(UIAction { [weak self, weak rowContainer] _ in
            guard let self = self, let rowContainer = rowContainer else { return }
            // Find the group by matching rowsStack
            for i in self.entryCards.indices {
                for groupKeyPath in [\EntryCard.buildingsGroup, \.floorsGroup, \.sharedFloorsGroup] {
                    var g = self.entryCards[i][keyPath: groupKeyPath]
                    if let rowIdx = g.rows.firstIndex(where: { $0.container === rowContainer }) {
                        g.rows[rowIdx].container.removeFromSuperview()
                        g.rows.remove(at: rowIdx)
                    }
                }
            }
        }, for: .touchUpInside)

        group.rowsStack.addArrangedSubview(rowContainer)

        // Mutate through entryCards to append if this group belongs to an existing card
        for i in entryCards.indices {
            if entryCards[i].buildingsGroup.rowsStack === group.rowsStack {
                entryCards[i].buildingsGroup.rows.append(row)
                return row
            } else if entryCards[i].floorsGroup.rowsStack === group.rowsStack {
                entryCards[i].floorsGroup.rows.append(row)
                return row
            } else if entryCards[i].sharedFloorsGroup.rowsStack === group.rowsStack {
                entryCards[i].sharedFloorsGroup.rows.append(row)
                return row
            }
        }
        // For groups not yet in entryCards (being built), caller manages rows themselves
        return row
    }

    // MARK: - Helpers

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill
        let label = UILabel()
        label.text = "venueLevelFacilityInfoConfig :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        container.addArrangedSubview(label)
        container.addArrangedSubview(segmentControl)
        return container
    }

    private func makeListContainerView() -> UIView {
        entriesStackView.axis = .vertical
        entriesStackView.spacing = 16
        entriesStackView.alignment = .fill
        addEntryButton.setTitle("Add venue entry (0/\(Self.maxEntryCount))", for: .normal)
        addEntryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        let container = UIStackView(arrangedSubviews: [entriesStackView, addEntryButton])
        container.axis = .vertical
        container.spacing = 16
        container.alignment = .fill
        return container
    }

    private func makeSpacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in make.height.equalTo(height) }
        return v
    }
}
