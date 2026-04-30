//
//  AttributionConfigViewController.swift
//  UISDKKmpSample
//
//  attributionConfig 功能详情页
//  Name: attributionConfig
//  Type: AttributionConfig?
//  Default: nil
//  Description: Attribution display configuration. If not set, will use the default attribution information.
//

import UIKit
import SnapKit
import DropInUISDK

final class AttributionConfigViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "AttributionConfig"])
    private weak var formContainer: UIView?

    private let textField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .default
        t.placeholder = "text (nil = default, \"\" = hidden)"
        t.autocorrectionType = .no
        return t
    }()

    private let textSegment = UISegmentedControl(items: ["nil", "String"])

    private let urlField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.keyboardType = .URL
        t.placeholder = "url (nil or \"\" = unclickable)"
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        return t
    }()

    private let urlSegment = UISegmentedControl(items: ["nil", "String"])

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
        textSegment.addTarget(self, action: #selector(textSegmentChanged), for: .valueChanged)
        urlSegment.addTarget(self, action: #selector(urlSegmentChanged), for: .valueChanged)
        loadCurrentValue()
    }

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.attributionConfig = nil
            Config.shared.saveChange([featureName: nil])
            super.saveBarButtonTapped()
            return
        }

        let text: String? = textSegment.selectedSegmentIndex == 0 ? nil : (textField.text ?? "")
        let url: String? = urlSegment.selectedSegmentIndex == 0 ? nil : (urlField.text ?? "")

        let config = AttributionConfig(text: text, url: url)
        Config.shared.diConfig.attributionConfig = config
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

        if let text = obj.value(forKey: "text") as? String {
            textSegment.selectedSegmentIndex = 1
            textField.text = text
        } else {
            textSegment.selectedSegmentIndex = 0
        }

        if let url = obj.value(forKey: "url") as? String {
            urlSegment.selectedSegmentIndex = 1
            urlField.text = url
        } else {
            urlSegment.selectedSegmentIndex = 0
        }

        textSegmentChanged()
        urlSegmentChanged()
        segmentChanged()
    }

    // MARK: - Visibility

    @objc private func segmentChanged() {
        formContainer?.isHidden = segmentControl.selectedSegmentIndex != 1
    }

    @objc private func textSegmentChanged() {
        textField.isHidden = textSegment.selectedSegmentIndex != 1
    }

    @objc private func urlSegmentChanged() {
        urlField.isHidden = urlSegment.selectedSegmentIndex != 1
    }

    // MARK: - UI builders

    private func selectorRowView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        let label = UILabel()
        label.text = "attributionConfig :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label

        segmentControl.selectedSegmentIndex = 0

        stack.addArrangedSubview(label)
        stack.addArrangedSubview(segmentControl)
        return stack
    }

    private func buildFormContainer() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        // text field
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 6

        let textLabel = UILabel()
        textLabel.text = "text"
        textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = .label

        let textHint = UILabel()
        textHint.text = "nil = default text, \"\" = link hidden"
        textHint.font = .systemFont(ofSize: 12)
        textHint.textColor = .secondaryLabel
        textHint.numberOfLines = 0

        textSegment.selectedSegmentIndex = 0
        textField.isHidden = true

        let textRow = UIStackView()
        textRow.axis = .horizontal
        textRow.alignment = .center
        textRow.distribution = .equalSpacing
        textRow.addArrangedSubview(textLabel)
        textRow.addArrangedSubview(textSegment)

        textStack.addArrangedSubview(textRow)
        textStack.addArrangedSubview(textField)
        textStack.addArrangedSubview(textHint)

        // url field
        let urlStack = UIStackView()
        urlStack.axis = .vertical
        urlStack.spacing = 6

        let urlLabel = UILabel()
        urlLabel.text = "url"
        urlLabel.font = .systemFont(ofSize: 14, weight: .medium)
        urlLabel.textColor = .label

        let urlHint = UILabel()
        urlHint.text = "nil or \"\" = link unclickable"
        urlHint.font = .systemFont(ofSize: 12)
        urlHint.textColor = .secondaryLabel
        urlHint.numberOfLines = 0

        urlSegment.selectedSegmentIndex = 0
        urlField.isHidden = true

        let urlRow = UIStackView()
        urlRow.axis = .horizontal
        urlRow.alignment = .center
        urlRow.distribution = .equalSpacing
        urlRow.addArrangedSubview(urlLabel)
        urlRow.addArrangedSubview(urlSegment)

        urlStack.addArrangedSubview(urlRow)
        urlStack.addArrangedSubview(urlField)
        urlStack.addArrangedSubview(urlHint)

        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(urlStack)

        return stack
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { $0.height.equalTo(height) }
        return v
    }
}
