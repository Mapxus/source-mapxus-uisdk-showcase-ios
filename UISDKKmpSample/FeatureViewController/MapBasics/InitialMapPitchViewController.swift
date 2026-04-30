//
//  InitialMapPitchViewController.swift
//  UISDKKmpSample
//
//  initialMapPitch 功能详情页
//  Name: initialMapPitch
//  Type: Double
//  Default: 0.0
//  Description: Initial map pitch (tilt angle) in degrees. Defines the vertical tilt angle of the map when first loaded.
//  A value of 0.0 represents a top-down view (2D), while higher values create a 3D perspective.
//  Valid range is 0.0 to 60.0 degrees. Default is 0.0 (vertical top-down view).
//

import UIKit
import SnapKit
import DropInUISDK

final class InitialMapPitchViewController: BaseFeatureViewController, UITextFieldDelegate {

    private let textField = UITextField()

    private enum PitchValidationError: LocalizedError {
        case invalidNumber
        case outOfRange
        var errorDescription: String? {
            switch self {
            case .invalidNumber: return "Please enter a valid number (degrees)."
            case .outOfRange: return "Pitch must be between 0.0 and 60.0 degrees."
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

        let current = Config.shared.configValue(forKey: featureName) as? Double ?? Config.shared.defaultValue(forKey: featureName) as? Double ?? 0.0
        textField.text = formatPitch(current)
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
        Config.shared.diConfig.initialMapPitch = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    /// Returns (error, value). When error != nil, value is meaningless. When error == nil, value is the Double to save.
    private func validate() -> (error: Error?, value: Double) {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return (PitchValidationError.invalidNumber, 0.0) }
        guard let value = Double(text) else { return (PitchValidationError.invalidNumber, 0.0) }
        guard value >= 0.0 && value <= 60.0 else { return (PitchValidationError.outOfRange, 0.0) }
        return (nil, value)
    }

    private func inputRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "initialMapPitch :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        textField.placeholder = "0.0"
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

    private func formatPitch(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let proposed = (current as NSString).replacingCharacters(in: range, with: string)
        if proposed.isEmpty { return true }
        let decimalCount = proposed.filter { $0 == "." }.count
        guard decimalCount <= 1 else { return false }
        return proposed.allSatisfy { $0.isNumber || $0 == "." || $0 == "-" }
    }
}
