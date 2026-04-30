//
//  SelectedBuildingBorderStyleViewController.swift
//  UISDKKmpSample
//
//  selectedBuildingBorderStyle 功能详情页
//  Name: selectedBuildingBorderStyle
//  Type: BorderStyle?
//  Default: null
//  Description: Style configuration for rendering selected building or shared floor borders on the map. When null, the default border style is used.
//

import UIKit
import SnapKit
import DropInUISDK

final class SelectedBuildingBorderStyleViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "BorderStyle"])
    private let lineOpacityField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = "lineOpacity  e.g. 0.8"
        t.keyboardType = .decimalPad
        return t
    }()
    private var borderStyleContainer: UIView?

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
        let fieldsContainer = borderStyleFieldsView()
        borderStyleContainer = fieldsContainer
        fieldsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, fieldsContainer)

        // Restore saved value
        let current = Config.shared.configValue(forKey: featureName) as? BorderStyle
        if let current = current {
            segmentControl.selectedSegmentIndex = 1
            borderStyleContainer?.isHidden = false
            if let op = current.lineOpacity {
                lineOpacityField.text = "\(op.doubleValue)"
            }
        } else {
            segmentControl.selectedSegmentIndex = 0
            borderStyleContainer?.isHidden = true
        }

        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    @objc private func segmentChanged() {
        borderStyleContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    override func saveBarButtonTapped() {
        let style: BorderStyle?
        if segmentControl.selectedSegmentIndex == 0 {
            style = nil
        } else {
            var opacity: KotlinDouble? = nil
            if let text = lineOpacityField.text, let val = Double(text) {
                opacity = KotlinDouble(value: val)
            }
            style = BorderStyle(lineOpacity: opacity)
        }
        Config.shared.diConfig.selectedBuildingBorderStyle = style
        Config.shared.saveChange([featureName: style as Any])
        super.saveBarButtonTapped()
    }

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        let label = UILabel()
        label.text = "selectedBuildingBorderStyle :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0

        container.addArrangedSubview(label)
        container.addArrangedSubview(segmentControl)
        return container
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return v
    }

    private func borderStyleFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        let opacityLabel = UILabel()
        opacityLabel.text = "lineOpacity (optional)"
        opacityLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        opacityLabel.textColor = .secondaryLabel

        let hintLabel = UILabel()
        hintLabel.text = "Stroke opacity of the highlight line. Leave empty for nil."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .tertiaryLabel
        hintLabel.numberOfLines = 0

        container.addArrangedSubview(opacityLabel)
        container.addArrangedSubview(lineOpacityField)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
