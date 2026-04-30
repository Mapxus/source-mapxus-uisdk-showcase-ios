//
//  IsBuildingListVisibleViewController.swift
//  UISDKKmpSample
//
//  isBuildingListVisible 功能详情页
//  Name: isBuildingListVisible
//  Type: Boolean
//  Default: true
//  Description: Indicates whether the building list is displayed on the venue page.
//  The building list is shown only when the current venue contains multiple buildings.
//  Default is true.
//

import UIKit
import SnapKit
import DropInUISDK

final class IsBuildingListVisibleViewController: BaseFeatureViewController {

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

        // isBuildingListVisible selector
        let row = inputRowView()
        addParameterSection(to: content, views: row)

        let current = currentIsBuildingListVisible()
        segmentedControl.selectedSegmentIndex = current ? 0 : 1
    }

    override func saveBarButtonTapped() {
        let value = segmentedControl.selectedSegmentIndex == 0
        Config.shared.diConfig.isBuildingListVisible = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Reads current isBuildingListVisible from Config, falling back to true.
    private func currentIsBuildingListVisible() -> Bool {
        let raw = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)
        if let boolVal = raw as? Bool { return boolVal }
        if let nsNumber = raw as? NSNumber { return nsNumber.boolValue }
        return true
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "isBuildingListVisible :"
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
