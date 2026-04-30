//
//  ShareDisplayModeViewController.swift
//  UISDKKmpSample
//
//  shareDisplayMode 功能详情页
//  Name: shareDisplayMode
//  Type: ShareDisplayMode
//  Default: ShareDisplayMode.BOTH
//  Description: Share button display mode. Determines how the share button behaves and what options are available when tapped.
//

import UIKit
import SnapKit
import DropInUISDK

final class ShareDisplayModeViewController: BaseFeatureViewController {

    private let segmentedControl = UISegmentedControl()
    private var allCases: [ShareDisplayMode] { ShareDisplayMode.allCases }

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
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

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
        addParameterSection(to: content, views: inputRowView())

        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        let current: ShareDisplayMode
        if let mode = raw as? ShareDisplayMode { current = mode }
        else { current = .both }
        if let index = allCases.firstIndex(of: current) {
            segmentedControl.selectedSegmentIndex = index
        }
    }

    override func saveBarButtonTapped() {
        let index = segmentedControl.selectedSegmentIndex
        guard index >= 0, index < allCases.count else { return }
        let value = allCases[index]
        Config.shared.diConfig.shareDisplayMode = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    private func inputRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "shareDisplayMode :"
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
