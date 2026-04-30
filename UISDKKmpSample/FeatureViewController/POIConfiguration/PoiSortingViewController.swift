//
//  PoiSortingViewController.swift
//  UISDKKmpSample
//
//  poiSorting 功能详情页
//  Name: poiSorting
//  Type: PoiSortingStrategy
//  Default: PoiSortingStrategy.byNameAlphabetically
//  Description: Sorting strategy for POIs displayed on category pages.
//  Determines the order in which users browse and find relevant points.
//  Default is [PoiSortingStrategy.ByNameAlphabetically].
//

import UIKit
import SnapKit
import DropInUISDK

final class PoiSortingViewController: BaseFeatureViewController {

    private let segmentedControl = UISegmentedControl()

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
        if let index = allCases.firstIndex(of: current) {
            segmentedControl.selectedSegmentIndex = index
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
    }

    override func saveBarButtonTapped() {
        let index = segmentedControl.selectedSegmentIndex
        guard index >= 0, index < allCases.count else { return }
        let value = allCases[index]
        Config.shared.diConfig.poiSorting = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current poiSorting from Config, falling back to .byNameAlphabetically.
    private func currentPoiSorting() -> PoiSortingStrategy {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let strategy = raw as? PoiSortingStrategy { return strategy }
        if let objcStrategy = raw as? __PoiSortingStrategy { return objcStrategy.toSwiftEnum() }
        return .byNameAlphabetically
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "poiSorting :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label

        segmentedControl.removeAllSegments()
        for (index, strategy) in allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: strategy.name, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.apportionsSegmentWidthsByContent = true

        container.addSubview(label)
        container.addSubview(segmentedControl)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container
    }
}
