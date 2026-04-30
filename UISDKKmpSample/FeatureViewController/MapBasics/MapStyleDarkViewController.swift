//
//  MapStyleDarkViewController.swift
//  UISDKKmpSample
//
//  mapStyleDark 功能详情页
//  Name: mapStyleDark
//  Type: String
//  Default: "mapxus_v8_dark"
//  Description: Map style used when appearanceMode is set to AppearanceMode.DARK.
//  This value controls the visual style specifically for dark mode.
//

import UIKit
import SnapKit
import DropInUISDK

final class MapStyleDarkViewController: BaseFeatureViewController {

    private let textField = UITextField()

    private enum StyleValidationError: LocalizedError {
        case emptyStyle
        var errorDescription: String? {
            switch self {
            case .emptyStyle: return "Please enter a style name."
            }
        }
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

        let row = inputRowView()
        addParameterSection(to: content, views: row)

        let current = Config.shared.configValue(forKey: featureName) as? String
            ?? Config.shared.defaultValue(forKey: featureName) as? String
            ?? "mapxus_v8_dark"
        textField.text = current
    }

    override func saveBarButtonTapped() {
        let (error, value) = validate()
        if let error = error {
            let alert = UIAlertController(
                title: "Invalid",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        Config.shared.diConfig.mapStyleDark = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    private func validate() -> (error: Error?, value: String) {
        let value = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return (StyleValidationError.emptyStyle, "") }
        return (nil, value)
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "mapStyleDark :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        textField.placeholder = Config.shared.defaultValue(forKey: featureName) as? String ?? "mapxus_v8_dark"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 15)
        textField.autocorrectionType = .no
        container.addSubview(label)
        container.addSubview(textField)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(textField.snp.leading).offset(-12)
        }
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalToSuperview()
            make.width.greaterThanOrEqualTo(120)
        }
        return container
    }
}

