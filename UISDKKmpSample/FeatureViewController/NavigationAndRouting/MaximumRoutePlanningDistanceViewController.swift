//
//  MaximumRoutePlanningDistanceViewController.swift
//  UISDKKmpSample
//
//  maximumRoutePlanningDistance 功能详情页
//  Name: maximumRoutePlanningDistance
//  Type: Double?
//  Default: nil
//  Description: Maximum allowed distance for route planning, in meters. Used to limit the range of navigation routes.
//

import UIKit
import SnapKit
import DropInUISDK

final class MaximumRoutePlanningDistanceViewController: BaseFeatureViewController, UITextFieldDelegate {

    private let textField = UITextField()

    private enum DistanceValidationError: LocalizedError {
        case invalidNumber
        var errorDescription: String? {
            switch self {
            case .invalidNumber:
                return "Please enter a valid number (meters), or leave it empty for nil."
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

        let rawValue = Config.shared.configValue(forKey: featureName)
            ?? Config.shared.defaultValue(forKey: featureName)

        if let n = rawValue as? NSNumber {
            textField.text = formatDistance(n.doubleValue)
        } else if let obj = rawValue as? NSObject,
                  let d = obj.value(forKey: "doubleValue") as? Double {
            textField.text = formatDistance(d)
        } else {
            textField.text = nil
        }
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
        
        if let value = value {
            let kotlinValue = KotlinDouble(double: value)
            Config.shared.diConfig.maximumRoutePlanningDistance = kotlinValue
            Config.shared.saveChange([featureName: kotlinValue])
        } else {
            Config.shared.diConfig.maximumRoutePlanningDistance = nil
            Config.shared.saveChange([featureName: nil])
        }
        super.saveBarButtonTapped()
    }

    /// Returns (error, value). When error != nil, value is meaningless.
    /// When text is empty, returns (nil, nil) to represent no limit.
    private func validate() -> (error: Error?, value: Double?) {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return (nil, nil)
        }
        guard let value = Double(text) else {
            return (DistanceValidationError.invalidNumber, nil)
        }
        return (nil, value)
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "maximumRoutePlanningDistance :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        textField.placeholder = "nil"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 15)
        textField.keyboardType = .decimalPad
        textField.autocorrectionType = .no
        textField.delegate = self
        container.addSubview(label)
        container.addSubview(textField)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(textField.snp.leading).offset(-12)
        }
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }
        return container
    }

    private func formatDistance(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    // 限制输入为数字、小数点和负号，且只允许一个小数点
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let proposed = (current as NSString).replacingCharacters(in: range, with: string)
        if proposed.isEmpty { return true }
        let decimalCount = proposed.filter { $0 == "." }.count
        guard decimalCount <= 1 else { return false }
        return proposed.allSatisfy { $0.isNumber || $0 == "." || $0 == "-" }
    }
}

