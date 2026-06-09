//
//  FloorSwitchScopeViewController.swift
//  UISDKKmpSample
//
//  floorSwitchScope 功能详情页
//  Name: floorSwitchScope
//  Type: FloorSwitchScope
//  Default: FloorSwitchScope.venue
//  Description: Defines the scope of the floor switch behavior.
//  FloorSwitchScope.VENUE restricts floor switching to the current venue.
//  FloorSwitchScope.GLOBAL allows floor switching across all venues.
//  Default is FloorSwitchScope.VENUE.
//

import UIKit
import SnapKit
import DropInUISDK

final class FloorSwitchScopeViewController: BaseFeatureViewController {

    private let segmentedControl = UISegmentedControl()

    private var allCases: [FloorSwitchScope] { FloorSwitchScope.allCases }

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

        // floorSwitchScope selector
        let row = inputRowView()
        addParameterSection(to: content, views: row)

        let current = currentFloorSwitchScope()
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
        Config.shared.diConfig.floorSwitchScope = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current floorSwitchScope from Config, falling back to .venue.
    private func currentFloorSwitchScope() -> FloorSwitchScope {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let scope = raw as? FloorSwitchScope { return scope }
        return .venue
    }

    private func inputRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "floorSwitchScope :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)

        segmentedControl.removeAllSegments()
        for (index, scope) in allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: scope.name, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0

        let segmentWrapper = UIView()
        segmentWrapper.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        container.addArrangedSubview(segmentWrapper)
        return container
    }
}
