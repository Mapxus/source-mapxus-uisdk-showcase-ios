//
//  ColorsViewController.swift
//  UISDKKmpSample
//
//  colors 功能详情页
//

import UIKit
import SnapKit
import DropInUISDK
import ObjectiveC

final class ColorsViewController: BaseFeatureViewController {

    private var colorTextFields: [UITextField] = []
    private var colorsFieldsContainer: UIView?
    private let segmentControl = UISegmentedControl(items: ["nil", "DIColors"])

    private enum ColorField {
        static let keys = [
            "brandPrimaryColor",
            "primaryContentColor",
            "brandSecondaryColor",
            "secondaryContentColor",
            "accentColor"
        ]
    }

    private enum ColorsValidationError: LocalizedError {
        case atLeastOneRequired
        var errorDescription: String? {
            switch self {
            case .atLeastOneRequired: return "Please fill in at least one color property."
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

        let selectorRow = selectorRowView()
        let spacer = spacerView(height: 16)
        let colorsContainer = colorInputFieldsView()
        colorsFieldsContainer = colorsContainer
        colorsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, colorsContainer)

        // Load current value from config and prefill UI
        let current = Config.shared.configValue(forKey: featureName) as? DIColors
        if let colors = current {
            segmentControl.selectedSegmentIndex = 1
            colorsFieldsContainer?.isHidden = false
            if colorTextFields.indices.contains(0) { colorTextFields[0].text = colors.brandPrimaryColor ?? "" }
            if colorTextFields.indices.contains(1) { colorTextFields[1].text = colors.primaryContentColor ?? "" }
            if colorTextFields.indices.contains(2) { colorTextFields[2].text = colors.brandSecondaryColor ?? "" }
            if colorTextFields.indices.contains(3) { colorTextFields[3].text = colors.secondaryContentColor ?? "" }
            if colorTextFields.indices.contains(4) { colorTextFields[4].text = colors.accentColor ?? "" }
        } else {
            segmentControl.selectedSegmentIndex = 0
            colorsFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let (error, colors) = validate()
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
        Config.shared.diConfig.colors = colors
        Config.shared.saveChange([featureName:colors])
        super.saveBarButtonTapped()
    }

    /// Returns (error, colors). When error != nil, colors is meaningless. When error == nil and segment is nil, colors is nil; when DIColors, colors is built from DIColorsBuilder with only filled properties set.
    private func validate() -> (error: Error?, colors: DIColors?) {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }
        let values = colorTextFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let atLeastOneFilled = values.contains { !$0.isEmpty }
        guard atLeastOneFilled else {
            return (ColorsValidationError.atLeastOneRequired, nil)
        }
        let builder = DIColorsBuilder()
        if !values[0].isEmpty { builder.brandPrimaryColor = values[0] }
        if !values[1].isEmpty { builder.primaryContentColor = values[1] }
        if !values[2].isEmpty { builder.brandSecondaryColor = values[2] }
        if !values[3].isEmpty { builder.secondaryContentColor = values[3] }
        if !values[4].isEmpty { builder.accentColor = values[4] }
        return (nil, builder.build())
    }

    @objc private func segmentChanged() {
        colorsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "DIColors :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(segmentControl)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(segmentControl.snp.leading).offset(-12)
        }
        segmentControl.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        return container
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return v
    }

    private func colorInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        container.alignment = .fill
        colorTextFields = []
        for key in ColorField.keys {
            let field = UITextField()
            field.placeholder = "nil"
            field.borderStyle = .roundedRect
            field.font = .systemFont(ofSize: 15)
            field.autocorrectionType = .no
            colorTextFields.append(field)
            let row = inputRowView(label: "\(key) :", textField: field)
            container.addArrangedSubview(row)
        }
        return container
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
            make.width.greaterThanOrEqualTo(120)
        }
        return container
    }
}
