//
//  GlobalFilterModesViewController.swift
//  UISDKKmpSample
//
//  globalFilterModes feature detail page
//  Name: globalFilterModes
//  Type: [GlobalFilterMode]?
//  Default: nil
//  Description: The list of enabled global filter modes available in the map UI.
//  This determines which GlobalFilterMode options are shown to the user in the UI.
//  By default, it is null. You can set it to include any combination of modes, e.g. SEARCH, EVENTS, SETTINGS.
//  The list can be reassigned to customize which modes are available or to change their order.
//

import UIKit
import SnapKit
import DropInUISDK

final class GlobalFilterModesViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[GlobalFilterMode]"])
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var tableContainer: UIView?
    private var tableHeightConstraint: Constraint?

    private var selectedModes: [GlobalFilterMode] = []
    private var availableModes: [GlobalFilterMode] = []

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
        let current = Config.shared.configValue(forKey: featureName) as? [GlobalFilterMode]
        let isNil = current == nil

        if let list = current {
            selectedModes = list
            let allModes = Array(GlobalFilterMode.allCases)
            availableModes = allModes.filter { !list.contains($0) }
        } else {
            selectedModes = []
            availableModes = Array(GlobalFilterMode.allCases)
        }

        segmentControl.selectedSegmentIndex = isNil ? 0 : 1
        tableContainer?.isHidden = isNil
        reloadTable()
    }

    // MARK: - Save

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.globalFilterModes = nil
            Config.shared.saveChange([featureName: nil])
        } else {
            Config.shared.diConfig.globalFilterModes = selectedModes
            Config.shared.saveChange([featureName: selectedModes])
        }
        super.saveBarButtonTapped()
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let isList = segmentControl.selectedSegmentIndex == 1
        if !isList {
            selectedModes = []
            availableModes = Array(GlobalFilterMode.allCases)
            reloadTable()
        }
        tableContainer?.isHidden = !isList
    }

    // MARK: - UI

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "globalFilterModes :"
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
    private static let tableSectionTopGap: CGFloat = 22

    private func reloadTable() {
        let itemCount = selectedModes.count + availableModes.count
        let height = CGFloat(itemCount) * Self.tableRowHeight + 2 * (Self.tableSectionHeaderHeight + Self.tableSectionTopGap)
        tableHeightConstraint?.update(offset: max(height, Self.tableRowHeight))
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension GlobalFilterModesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        TableSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section)! {
        case .selected:  return selectedModes.count
        case .available: return availableModes.count
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
        let mode: GlobalFilterMode
        switch TableSection(rawValue: indexPath.section)! {
        case .selected:
            mode = selectedModes[indexPath.row]
            cell.textLabel?.textColor = .label
            cell.showsReorderControl = true
        case .available:
            mode = availableModes[indexPath.row]
            cell.textLabel?.textColor = .secondaryLabel
            cell.showsReorderControl = false
        }
        cell.textLabel?.text = mode.name
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        TableSection(rawValue: indexPath.section) == .selected
    }

    func tableView(_ tableView: UITableView, moveRowAt source: IndexPath, to destination: IndexPath) {
        guard TableSection(rawValue: source.section) == .selected,
              TableSection(rawValue: destination.section) == .selected else { return }
        let item = selectedModes.remove(at: source.row)
        selectedModes.insert(item, at: destination.row)
        reloadTable()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              TableSection(rawValue: indexPath.section) == .selected else { return }
        let removed = selectedModes.remove(at: indexPath.row)
        availableModes.append(removed)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        let newRow = availableModes.count - 1
        tableView.insertRows(at: [IndexPath(row: newRow, section: TableSection.available.rawValue)], with: .automatic)
        tableView.endUpdates()
        reloadTable()
    }
}

// MARK: - UITableViewDelegate

extension GlobalFilterModesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard TableSection(rawValue: indexPath.section) == .available else { return }
        let added = availableModes.remove(at: indexPath.row)
        selectedModes.append(added)
        let newRow = selectedModes.count - 1
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
            return IndexPath(row: max(selectedModes.count - 1, 0), section: TableSection.selected.rawValue)
        }
        return proposed
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        header.textLabel?.textColor = .secondaryLabel
    }
}
