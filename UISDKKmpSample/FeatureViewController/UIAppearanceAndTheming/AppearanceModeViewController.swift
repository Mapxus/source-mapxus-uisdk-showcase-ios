//
//  AppearanceModeViewController.swift
//  UISDKKmpSample
//
//  appearanceMode 功能详情页
//  Name: appearanceMode
//  Type: AppearanceMode
//  Default: AppearanceMode.light
//  Description: Controls the appearance mode and the formula method used for UI color scheme calculation.
//  This setting determines how the colors are computed based on the baseline values specified in [colors].
//  Supports both light and dark theme calculations.
//  Default is [AppearanceMode.LIGHT].
//

import UIKit
import SnapKit
import DropInUISDK

final class AppearanceModeViewController: BaseFeatureViewController {

    private let segmentedControl = UISegmentedControl()

    private var allCases: [AppearanceMode] { AppearanceMode.allCases }

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

        // appearanceMode selector
        let row = inputRowView()
        addParameterSection(to: content, views: row)

        let current = currentAppearanceMode()
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
        Config.shared.diConfig.appearanceMode = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current appearanceMode from Config, falling back to .light.
    private func currentAppearanceMode() -> AppearanceMode {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let mode = raw as? AppearanceMode { return mode }
        if let objcMode = raw as? __AppearanceMode { return objcMode.toSwiftEnum() }
        return .light
    }

    private func inputRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "appearanceMode :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)

        segmentedControl.removeAllSegments()
        for (index, mode) in allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: mode.name, at: index, animated: false)
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
