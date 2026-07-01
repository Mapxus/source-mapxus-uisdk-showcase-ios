//
//  EnableVisualMapViewController.swift
//  UISDKKmpSample
//
//  enableVisualMap 功能详情页
//  Name: enableVisualMap
//  Type: Boolean
//  Default: false
//  Description: Determines whether the VisualMap button is displayed. When true, the VisualMap button is shown in the UI. Default is false.
//

import UIKit
import SnapKit
import DropInUISDK

final class EnableVisualMapViewController: BaseFeatureViewController {

    private let segmentedControl = UISegmentedControl(items: ["true", "false"])

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
        let current: Bool
        if let b = raw as? Bool { current = b }
        else if let n = raw as? NSNumber { current = n.boolValue }
        else { current = false }
        segmentedControl.selectedSegmentIndex = current ? 0 : 1
    }

    override func saveBarButtonTapped() {
        let value = segmentedControl.selectedSegmentIndex == 0
        Config.shared.diConfig.enableVisualMap = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "enableVisualMap :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(segmentedControl)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(segmentedControl.snp.leading).offset(-12)
        }
        segmentedControl.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        return container
    }
}
