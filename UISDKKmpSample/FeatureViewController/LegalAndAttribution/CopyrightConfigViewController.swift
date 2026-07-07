//
//  CopyrightConfigViewController.swift
//  UISDKKmpSample
//
//  copyrightConfig feature detail page
//  Name: copyrightConfig
//  Type: CopyrightConfig?
//  Default: nil
//  Description: Copyright display configuration. If not set, will use the default copyright information.
//

import UIKit
import SnapKit
import DropInUISDK

final class CopyrightConfigViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "CopyrightConfig"])
    private weak var formContainer: UIView?

    private let alphaField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .decimalPad
        t.placeholder = "alpha (0.0 ~ 1.0)"
        t.autocorrectionType = .no
        return t
    }()

    private let imageUrlField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .URL
        t.placeholder = "imageUrl (optional)"
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        return t
    }()

    private let imageWidthField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .numberPad
        t.placeholder = "imageWidth (px)"
        t.autocorrectionType = .no
        return t
    }()

    private let imageHeightField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .numberPad
        t.placeholder = "imageHeight (px)"
        t.autocorrectionType = .no
        return t
    }()

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

        let selectorRow = selectorRowView()
        let spacer = spacerView(height: 8)
        let form = buildFormContainer()
        formContainer = form
        form.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, form)

        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        loadCurrentValue()
    }

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.copyrightConfig = nil
            Config.shared.saveChange([featureName: nil])
            super.saveBarButtonTapped()
            return
        }

        guard let alphaText = alphaField.text, let alphaValue = Float(alphaText) else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid alpha value (0.0 ~ 1.0).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let widthText = imageWidthField.text, let widthValue = Int32(widthText) else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid imageWidth.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard let heightText = imageHeightField.text, let heightValue = Int32(heightText) else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid imageHeight.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let imageUrl = imageUrlField.text.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let config = CopyrightConfig(alpha: alphaValue, imageUrl: imageUrl, imageWidth: widthValue, imageHeight: heightValue)
        Config.shared.diConfig.copyrightConfig = config
        Config.shared.saveChange([featureName: config])
        super.saveBarButtonTapped()
    }

    // MARK: - Load

    private func loadCurrentValue() {
        guard let obj = Config.shared.configValue(forKey: featureName) as? NSObject,
              !(Config.shared.configValue(forKey: featureName) is NSNull) else {
            segmentControl.selectedSegmentIndex = 0
            segmentChanged()
            return
        }

        segmentControl.selectedSegmentIndex = 1

        if let alpha = obj.value(forKey: "alpha") as? NSNumber {
            alphaField.text = alpha.stringValue
        }
        if let url = obj.value(forKey: "imageUrl") as? String {
            imageUrlField.text = url
        }
        if let w = obj.value(forKey: "imageWidth") as? NSNumber {
            imageWidthField.text = w.stringValue
        }
        if let h = obj.value(forKey: "imageHeight") as? NSNumber {
            imageHeightField.text = h.stringValue
        }

        segmentChanged()
    }

    // MARK: - Visibility

    @objc private func segmentChanged() {
        let isCustom = segmentControl.selectedSegmentIndex == 1
        formContainer?.isHidden = !isCustom
    }

    // MARK: - UI builders

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "copyrightConfig :"
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
        segmentControl.selectedSegmentIndex = 0
        return container
    }

    private func buildFormContainer() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill

        stack.addArrangedSubview(fieldRow(label: "alpha", field: alphaField, hint: "Opacity of copyright image (0.0 ~ 1.0)"))
        stack.addArrangedSubview(fieldRow(label: "imageUrl", field: imageUrlField, hint: "URL of the copyright image resource (optional)"))
        stack.addArrangedSubview(fieldRow(label: "imageWidth", field: imageWidthField, hint: "Desired width of the copyright image in pixels"))
        stack.addArrangedSubview(fieldRow(label: "imageHeight", field: imageHeightField, hint: "Desired height of the copyright image in pixels"))

        return stack
    }

    private func fieldRow(label: String, field: UITextField, hint: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let lbl = UILabel()
        lbl.text = label
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .label

        let hintLbl = UILabel()
        hintLbl.text = hint
        hintLbl.font = .systemFont(ofSize: 12)
        hintLbl.textColor = .secondaryLabel
        hintLbl.numberOfLines = 0

        stack.addArrangedSubview(lbl)
        stack.addArrangedSubview(field)
        stack.addArrangedSubview(hintLbl)
        return stack
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { $0.height.equalTo(height) }
        return v
    }
}
