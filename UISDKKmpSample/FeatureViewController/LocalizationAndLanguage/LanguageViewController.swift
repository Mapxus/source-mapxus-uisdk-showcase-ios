//
//  LanguageViewController.swift
//  UISDKKmpSample
//
//  language 功能详情页
//  Name: language
//  Type: Language
//  Default: SystemLanguage
//  Description: Specifies the language used for the user interface. Defaults to the system language.
//

import UIKit
import SnapKit
import DropInUISDK

final class LanguageViewController: BaseFeatureViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var tableContainer: UIView?
    private var tableHeightConstraint: Constraint?

    /// 可用选项（排除已弃用的 TraditionalChineseHK）
    private var allCases: [Language] {
        Language.allCases.filter { $0.name != "TraditionalChineseHK" }
    }
    private var selectedIndex: Int = 0

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

        let label = UILabel()
        label.text = "language :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        content.addArrangedSubview(label)

        let container = buildTableContainer()
        tableContainer = container
        content.addArrangedSubview(container)

        let current = currentLanguage()
        if let index = allCases.firstIndex(of: current) {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentHeight = tableView.contentSize.height
        if contentHeight > 0 {
            tableHeightConstraint?.update(offset: contentHeight)
        }
    }

    override func saveBarButtonTapped() {
        guard selectedIndex >= 0, selectedIndex < allCases.count else { return }
        let value = allCases[selectedIndex]
        Config.shared.diConfig.language = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current language from Config, falling back to .systemLanguage.
    private func currentLanguage() -> Language {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let lang = raw as? Language { return lang }
        if let objcLang = raw as? __Language { return objcLang.toSwiftEnum() }
        return .systemLanguage
    }

    private func buildTableContainer() -> UIView {
        let container = UIView()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 44
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        let headerHeight: CGFloat = 0.01
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: headerHeight))

        container.addSubview(tableView)
        let rowHeight: CGFloat = 44
        let sectionHeaderFooter: CGFloat = 0.01
        let estimatedHeight = headerHeight + sectionHeaderFooter * 2 + CGFloat(allCases.count) * rowHeight
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            tableHeightConstraint = make.height.equalTo(estimatedHeight).constraint
        }
        return container
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension LanguageViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = allCases[indexPath.row].name
        cell.textLabel?.textColor = .label
        cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let oldIndex = selectedIndex
        selectedIndex = indexPath.row
        if oldIndex != selectedIndex {
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}
