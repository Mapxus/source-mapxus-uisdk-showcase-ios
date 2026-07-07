//
//  SettingsLanguageOptionsViewController.swift
//  UISDKKmpSample
//
//  settingsLanguageOptions feature detail page
//  Name: settingsLanguageOptions
//  Type: [Language]?
//  Default: nil
//  Description: List of supported UI languages for the Settings page.
//  This defines which language options are available for the user to choose from.
//  Can be null if no custom language options are specified.
//

import UIKit
import SnapKit
import DropInUISDK

final class SettingsLanguageOptionsViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "Custom"])
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var tableContainer: UIView?
    private var tableHeightConstraint: Constraint?

    private var selectedLanguages: [Language] = []
    private var availableLanguages: [Language] = []

    private var allLanguages: [Language] {
        Language.allCases.filter { $0.name != "TraditionalChineseHK" }
    }

    private enum TableSection: Int, CaseIterable {
        case selected = 0
        case available = 1
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
        let container = buildTableContainer()
        tableContainer = container
        addParameterSection(to: content, views: selectorRow, container)

        loadCurrentValue()
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    // MARK: - Load

    private func loadCurrentValue() {
        let raw = Config.shared.configValue(forKey: featureName)
        let current: [Language]?
        if let arr = raw as? [Language] {
            current = arr
        } else if let nsArr = raw as? NSArray {
            current = nsArr.compactMap { $0 as? Language }
        } else {
            current = nil
        }

        if let current = current {
            // Custom, even an empty array is treated as Custom
            segmentControl.selectedSegmentIndex = 1
            tableContainer?.isHidden = false
            tableContainer?.isUserInteractionEnabled = true
            tableContainer?.alpha = 1.0

            selectedLanguages = current.filter { $0.name != "TraditionalChineseHK" }
            availableLanguages = allLanguages.filter { !selectedLanguages.contains($0) }
        } else {
            // nil: do not show the TableView
            segmentControl.selectedSegmentIndex = 0
            tableContainer?.isHidden = true

            selectedLanguages = []
            availableLanguages = allLanguages
        }

        reloadTable()
    }

    // MARK: - Save

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.settingsLanguageOptions = nil
            Config.shared.saveChange([featureName: nil as [Language]?])
        } else {
            Config.shared.diConfig.settingsLanguageOptions = selectedLanguages
            Config.shared.saveChange([featureName: selectedLanguages])
        }
        super.saveBarButtonTapped()
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let isCustom = segmentControl.selectedSegmentIndex == 1
        tableContainer?.isHidden = !isCustom
        if isCustom {
            // When switching from nil to Custom, start with an empty list by default
            if selectedLanguages.isEmpty {
                availableLanguages = allLanguages
            }
            reloadTable()
        }
    }

    // MARK: - UI

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "settingsLanguageOptions :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(segmentControl)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(segmentControl.snp.leading).offset(-12)
        }
        segmentControl.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        return container
    }

    private func buildTableContainer() -> UIView {
        let container = UIView()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.setEditing(true, animated: false)
        tableView.allowsSelectionDuringEditing = true
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = Self.tableRowHeight
        tableView.sectionHeaderHeight = Self.tableSectionHeaderHeight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        container.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            tableHeightConstraint = make.height.equalTo(0).constraint
        }
        return container
    }

    private static let tableRowHeight: CGFloat = 44
    private static let tableSectionHeaderHeight: CGFloat = 28
    /// Fixed spacing above each section for the UITableView plain style
    private static let tableSectionTopGap: CGFloat = 22

    private func reloadTable() {
        let itemCount = selectedLanguages.count + availableLanguages.count
        let height = CGFloat(itemCount) * Self.tableRowHeight + 2 * (Self.tableSectionHeaderHeight + Self.tableSectionTopGap)
        tableHeightConstraint?.update(offset: max(height, Self.tableRowHeight))
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension SettingsLanguageOptionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        TableSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section)! {
        case .selected:  return selectedLanguages.count
        case .available: return availableLanguages.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch TableSection(rawValue: section)! {
        case .selected:  return "Selected  (drag ≡ to reorder, swipe to remove)"
        case .available: return "Available  (tap to add)"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let lang: Language
        switch TableSection(rawValue: indexPath.section)! {
        case .selected:
            lang = selectedLanguages[indexPath.row]
            cell.textLabel?.textColor = .label
            cell.showsReorderControl = true
        case .available:
            lang = availableLanguages[indexPath.row]
            cell.textLabel?.textColor = .secondaryLabel
            cell.showsReorderControl = false
        }
        cell.textLabel?.text = lang.name
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        TableSection(rawValue: indexPath.section) == .selected
    }

    func tableView(_ tableView: UITableView, moveRowAt source: IndexPath, to destination: IndexPath) {
        guard TableSection(rawValue: source.section) == .selected,
              TableSection(rawValue: destination.section) == .selected else { return }
        let item = selectedLanguages.remove(at: source.row)
        selectedLanguages.insert(item, at: destination.row)
        reloadTable()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              TableSection(rawValue: indexPath.section) == .selected else { return }
        let removed = selectedLanguages.remove(at: indexPath.row)
        availableLanguages.append(removed)
        availableLanguages.sort { a, b in
            let ia = allLanguages.firstIndex(of: a) ?? Int.max
            let ib = allLanguages.firstIndex(of: b) ?? Int.max
            return ia < ib
        }
        let newRow = availableLanguages.firstIndex(of: removed) ?? (availableLanguages.count - 1)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.insertRows(at: [IndexPath(row: newRow, section: TableSection.available.rawValue)], with: .automatic)
        tableView.endUpdates()
        reloadTable()
    }
}

// MARK: - UITableViewDelegate

extension SettingsLanguageOptionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard TableSection(rawValue: indexPath.section) == .available else { return }
        let added = availableLanguages.remove(at: indexPath.row)
        selectedLanguages.append(added)
        let newRow = selectedLanguages.count - 1
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.insertRows(at: [IndexPath(row: newRow, section: TableSection.selected.rawValue)], with: .automatic)
        tableView.endUpdates()
        reloadTable()
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        TableSection(rawValue: indexPath.section) == .selected ? .delete : .none
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposed: IndexPath) -> IndexPath {
        guard TableSection(rawValue: proposed.section) == .selected else {
            return IndexPath(row: max(selectedLanguages.count - 1, 0), section: TableSection.selected.rawValue)
        }
        return proposed
    }
}

