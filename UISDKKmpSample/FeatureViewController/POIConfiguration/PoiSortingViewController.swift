//
//  PoiSortingViewController.swift
//  UISDKKmpSample
//
//  poiSorting feature detail page
//  Name: poiSorting
//  Type: PoiSortingStrategy
//  Default: PoiSortingStrategy.byDefault
//  Description: Sorting strategy for POIs displayed on category pages.
//  Determines the order in which users browse and find relevant points.
//  Default is [PoiSortingStrategy.byDefault].
//

import UIKit
import SnapKit
import DropInUISDK

final class PoiSortingViewController: BaseFeatureViewController {

    /// View and selection indicator for a single option
    private struct OptionRow {
        let container: UIView
        let checkmark: UIImageView
    }

    private var optionRows: [OptionRow] = []
    private var selectedIndex: Int = 0

    private var allCases: [PoiSortingStrategy] { PoiSortingStrategy.allCases }

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
        content.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        scrollView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        addDescriptionContent(to: content)

        // poiSorting selector
        let row = inputRowView()
        addParameterSection(to: content, views: row)

        let current = currentPoiSorting()
        selectedIndex = allCases.firstIndex(of: current) ?? 0
        updateSelectionUI()
    }

    override func saveBarButtonTapped() {
        guard selectedIndex >= 0, selectedIndex < allCases.count else { return }
        let value = allCases[selectedIndex]
        Config.shared.diConfig.poiSorting = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current poiSorting from Config, falling back to .byDefault.
    private func currentPoiSorting() -> PoiSortingStrategy {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let strategy = raw as? PoiSortingStrategy { return strategy }
        if let objcStrategy = raw as? __PoiSortingStrategy { return objcStrategy.toSwiftEnum() }
        return .byDefault
    }

    private func inputRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.alignment = .fill

        let label = UILabel()
        label.text = "poiSorting :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)

        let optionsStack = UIStackView()
        optionsStack.axis = .vertical
        optionsStack.spacing = 8
        optionsStack.alignment = .fill

        optionRows = []
        for (index, strategy) in allCases.enumerated() {
            let row = makeOptionRow(title: strategy.name, index: index)
            optionsStack.addArrangedSubview(row.container)
            optionRows.append(row)
        }
        container.addArrangedSubview(optionsStack)
        return container
    }

    /// Creates a tappable option row with the name on the left and a checkmark on the right
    private func makeOptionRow(title: String, index: Int) -> OptionRow {
        let row = UIView()
        row.backgroundColor = .tertiarySystemFill
        row.layer.cornerRadius = 8
        row.tag = index
        row.isUserInteractionEnabled = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .systemBlue
        checkmark.contentMode = .scaleAspectFit
        checkmark.setContentHuggingPriority(.required, for: .horizontal)
        checkmark.setContentCompressionResistancePriority(.required, for: .horizontal)

        row.addSubview(titleLabel)
        row.addSubview(checkmark)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(12)
        }
        checkmark.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
        row.addGestureRecognizer(tap)
        return OptionRow(container: row, checkmark: checkmark)
    }

    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        selectedIndex = index
        updateSelectionUI()
    }

    /// Refreshes each option selection style based on selectedIndex
    private func updateSelectionUI() {
        for (index, row) in optionRows.enumerated() {
            let isSelected = index == selectedIndex
            row.checkmark.isHidden = !isSelected
            row.container.backgroundColor = isSelected
                ? UIColor.systemBlue.withAlphaComponent(0.12)
                : .tertiarySystemFill
        }
    }
}
