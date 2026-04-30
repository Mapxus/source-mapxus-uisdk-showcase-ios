//
//  ShapesViewController.swift
//  UISDKKmpSample
//
//  shapes 功能详情页
//

import UIKit
import SnapKit
import DropInUISDK

final class ShapesViewController: BaseFeatureViewController {

    private var shapeTextFields: [UITextField] = []

    /// 属性名与 Shape.kt 一致（corner radius in dp）
    private enum ShapeField {
        static let keys = [
            "buttonShapeCornerSize",
            "imageShapeCornerSize",
            "searchBarShapeCornerSize",
            "bottomSheetShapeCornerSize",
            "popupCardShapeCornerSize"
        ]
    }

    private enum ShapesValidationError: LocalizedError {
        case allPropertiesRequired
        case allMustBeNumbers
        var errorDescription: String? {
            switch self {
            case .allPropertiesRequired: return "Please fill in all shape properties."
            case .allMustBeNumbers: return "All values must be valid numbers."
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

        let identifierRow = shapesIdentifierRowView()
        let shapesContainer = shapeInputFieldsView()
        addParameterSection(to: content, views: identifierRow, shapesContainer)

        // Load current value from config and prefill UI
        let current = Config.shared.configValue(forKey: featureName) as? DIShapes
        if let shapes = current {
            if shapeTextFields.indices.contains(0) { shapeTextFields[0].text = "\(shapes.buttonShapeCornerSize)" }
            if shapeTextFields.indices.contains(1) { shapeTextFields[1].text = "\(shapes.imageShapeCornerSize)" }
            if shapeTextFields.indices.contains(2) { shapeTextFields[2].text = "\(shapes.searchBarShapeCornerSize)" }
            if shapeTextFields.indices.contains(3) { shapeTextFields[3].text = "\(shapes.bottomSheetShapeCornerSize)" }
            if shapeTextFields.indices.contains(4) { shapeTextFields[4].text = "\(shapes.popupCardShapeCornerSize)" }
        }
    }

    override func saveBarButtonTapped() {
        switch validateAndBuildShapes() {
        case .failure(let error):
            let alert = UIAlertController(
                title: "Invalid",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .success(let shapes):
            Config.shared.diConfig.shapes = shapes
            Config.shared.saveChange([featureName: shapes])
            super.saveBarButtonTapped()
        }
    }

    /// 校验：每个属性必填且为合法数字；通过则生成新的 DIShapes。
    private func validateAndBuildShapes() -> Result<DIShapes, Error> {
        let values = shapeTextFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        guard values.allSatisfy({ !$0.isEmpty }) else {
            return .failure(ShapesValidationError.allPropertiesRequired)
        }
        let parsed = values.compactMap { Double($0) }
        guard parsed.count == ShapeField.keys.count else {
            return .failure(ShapesValidationError.allMustBeNumbers)
        }
        let shapes = DIShapes(
            buttonShapeCornerSize: parsed[0],
            imageShapeCornerSize: parsed[1],
            searchBarShapeCornerSize: parsed[2],
            bottomSheetShapeCornerSize: parsed[3],
            popupCardShapeCornerSize: parsed[4]
        )
        return .success(shapes)
    }

    private func shapesIdentifierRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "shapes : DIShapes("
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return container
    }

    private func shapeInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        container.alignment = .fill
        shapeTextFields = []
        let defaultShapes = Config.shared.defaultValue(forKey: featureName) as? NSObject
        for key in ShapeField.keys {
            let field = UITextField()
            let defaultValue = (defaultShapes?.value(forKey: key) as? NSNumber)?.doubleValue ?? 0
            field.placeholder = "\(defaultValue)"
            field.borderStyle = .roundedRect
            field.font = .systemFont(ofSize: 15)
            field.autocorrectionType = .no
            field.keyboardType = .decimalPad
            field.delegate = self
            shapeTextFields.append(field)
            let row = inputRowView(label: "\(key) :", textField: field)
            container.addArrangedSubview(row)
        }
        let tabWidth: CGFloat = 24
        let indentedBlock = UIStackView(arrangedSubviews: [container])
        indentedBlock.axis = .vertical
        indentedBlock.isLayoutMarginsRelativeArrangement = true
        indentedBlock.layoutMargins = UIEdgeInsets(top: 0, left: tabWidth, bottom: 0, right: 0)
        let closingLabel = UILabel()
        closingLabel.text = ")"
        closingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        closingLabel.textColor = .label
        let wrapper = UIStackView(arrangedSubviews: [indentedBlock, closingLabel])
        wrapper.axis = .vertical
        wrapper.spacing = 20
        wrapper.alignment = .leading
        return wrapper
    }

    private func inputRowView(label text: String, textField field: UITextField) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(field)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(field.snp.leading).offset(-12)
        }
        field.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalToSuperview()
            make.width.equalTo(50)
        }
        return container
    }
}

// MARK: - UITextFieldDelegate（仅允许数字输入，含一位小数点）
extension ShapesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let allowed = CharacterSet(charactersIn: "0123456789.")
        guard string.unicodeScalars.allSatisfy({ allowed.contains($0) }) else { return false }
        let current = textField.text ?? ""
        let proposed = (current as NSString).replacingCharacters(in: range, with: string)
        if proposed.contains(".") {
            let parts = proposed.split(separator: ".", omittingEmptySubsequences: false)
            if parts.count > 2 { return false }
        }
        return true
    }
}
