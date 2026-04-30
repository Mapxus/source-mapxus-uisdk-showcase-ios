//
//  MapEventListenerViewController.swift
//  UISDKKmpSample
//

import UIKit
import SnapKit
import DropInUISDK

final class MapEventListenerViewController: BaseFeatureViewController {

    private let enableSwitch = UISwitch()

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

        addListenerDescriptionContent(to: content)

        enableSwitch.isOn = Config.shared.listener == featureName
        let row = switchRow(title: "Enable", control: enableSwitch)
        addParameterSection(to: content, views: row)
    }

    override func saveBarButtonTapped() {
        Config.shared.saveListenerChange(enableSwitch.isOn ? featureName : nil)
        super.saveBarButtonTapped()
    }
}
