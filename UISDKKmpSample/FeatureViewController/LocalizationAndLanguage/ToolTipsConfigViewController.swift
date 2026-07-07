//
//  ToolTipsConfigViewController.swift
//  UISDKKmpSample
//
//  toolTipsConfig feature detail page
//  Name: toolTipsConfig
//  Type: ToolTipsConfig?
//  Default: nil
//  Description: Configuration for in-app guidance prompts related to enabling and using indoor navigation features.
//  Provides localized titles and detailed instructions to assist users with required setup steps.
//  If null, will display built-in default guidance messages.
//

import UIKit
import SnapKit
import DropInUISDK

final class ToolTipsConfigViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "ToolTipsConfig"])
    private let isEnabledSwitch = UISwitch()
    private var formContainer: UIView?

    private var titleFields: [UITextField] = []
    private var contentFields: [UITextField] = []
    private var htmlContentFields: [UITextField] = []

    private let titleSegment = UISegmentedControl(items: ["nil", "StringsWithLanguage"])
    private let contentSegment = UISegmentedControl(items: ["nil", "StringsWithLanguage"])
    private let htmlSegment = UISegmentedControl(items: ["nil", "StringsWithLanguage"])

    private var titleFieldsContainer: UIView?
    private var contentFieldsContainer: UIView?
    private var htmlFieldsContainer: UIView?

    private enum StringsField {
        static let labels = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
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
        let spacer = spacerView(height: 8)
        let form = buildFormContainer()
        formContainer = form
        form.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, form)

        loadCurrentValue()
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.toolTipsConfig = nil
            Config.shared.saveChange([featureName: nil])
            super.saveBarButtonTapped()
            return
        }

        let title = buildStrings(from: titleFields, segment: titleSegment)
        let content = buildStrings(from: contentFields, segment: contentSegment)
        let html = buildStrings(from: htmlContentFields, segment: htmlSegment)

        let config = ToolTipsConfig(
            isEnabled: isEnabledSwitch.isOn,
            title: title,
            content: content,
            htmlContent: html
        )
        Config.shared.diConfig.toolTipsConfig = config
        Config.shared.saveChange([featureName: config])
        super.saveBarButtonTapped()
    }

    // MARK: - Load

    private func loadCurrentValue() {
        let raw = Config.shared.configValue(forKey: featureName)
        let current: ToolTipsConfig?
        if let cfg = raw as? ToolTipsConfig {
            current = cfg
        }  else {
            current = nil
        }

        if let cfg = current {
            segmentControl.selectedSegmentIndex = 1
            formContainer?.isHidden = false
            isEnabledSwitch.isOn = cfg.isEnabled

            // title
            if let title = cfg.title {
                titleSegment.selectedSegmentIndex = 1
                titleFieldsContainer?.isHidden = false
                apply(strings: title, to: titleFields)
            } else {
                titleSegment.selectedSegmentIndex = 0
                titleFieldsContainer?.isHidden = true
            }
            // content
            if let content = cfg.content {
                contentSegment.selectedSegmentIndex = 1
                contentFieldsContainer?.isHidden = false
                apply(strings: content, to: contentFields)
            } else {
                contentSegment.selectedSegmentIndex = 0
                contentFieldsContainer?.isHidden = true
            }
            // htmlContent
            if let html = cfg.htmlContent {
                htmlSegment.selectedSegmentIndex = 1
                htmlFieldsContainer?.isHidden = false
                apply(strings: html, to: htmlContentFields)
            } else {
                htmlSegment.selectedSegmentIndex = 0
                htmlFieldsContainer?.isHidden = true
            }
        } else {
            segmentControl.selectedSegmentIndex = 0
            formContainer?.isHidden = true
            titleSegment.selectedSegmentIndex = 0
            contentSegment.selectedSegmentIndex = 0
            htmlSegment.selectedSegmentIndex = 0
            titleFieldsContainer?.isHidden = true
            contentFieldsContainer?.isHidden = true
            htmlFieldsContainer?.isHidden = true
        }
    }

    // MARK: - Helpers

    private func apply(strings: StringsWithLanguage, to fields: [UITextField]) {
        let values: [String?] = [
            strings.default,
            strings.en,
            strings.ja,
            strings.ko,
            strings.zhHans,
            strings.zhHant,
            strings.zhHantTW,
            strings.ar,
            strings.fr,
            strings.it
        ]
        for (idx, value) in values.enumerated() where idx < fields.count {
            fields[idx].text = value
        }
    }

    private func buildStrings(from fields: [UITextField], segment: UISegmentedControl) -> StringsWithLanguage? {
        guard segment.selectedSegmentIndex == 1 else { return nil }
        let values = fields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let allEmpty = values.allSatisfy { $0.isEmpty }
        if allEmpty { return nil }
        let optValues = values.map { s in s.isEmpty ? nil : s }
        return StringsWithLanguage(
            default: optValues[0],
            en: optValues[1],
            ja: optValues[2],
            ko: optValues[3],
            zhHans: optValues[4],
            zhHant: optValues[5],
            zhHantTW: optValues[6],
            ar: optValues[7],
            fr: optValues[8],
            it: optValues[9]
        )
    }

    @objc private func segmentChanged() {
        let isCustom = segmentControl.selectedSegmentIndex == 1
        formContainer?.isHidden = !isCustom
        if !isCustom {
            // Do not force-clear child segments when collapsed, so users can continue editing after reopening
            return
        }
        // Ensures the three child segments default to nil
        if titleSegment.selectedSegmentIndex == UISegmentedControl.noSegment {
            titleSegment.selectedSegmentIndex = 0
            titleFieldsContainer?.isHidden = true
        }
        if contentSegment.selectedSegmentIndex == UISegmentedControl.noSegment {
            contentSegment.selectedSegmentIndex = 0
            contentFieldsContainer?.isHidden = true
        }
        if htmlSegment.selectedSegmentIndex == UISegmentedControl.noSegment {
            htmlSegment.selectedSegmentIndex = 0
            htmlFieldsContainer?.isHidden = true
        }
    }

    @objc private func stringsSegmentChanged(_ sender: UISegmentedControl) {
        let isCustom = sender.selectedSegmentIndex == 1
        switch sender {
        case titleSegment:
            titleFieldsContainer?.isHidden = !isCustom
        case contentSegment:
            contentFieldsContainer?.isHidden = !isCustom
        case htmlSegment:
            htmlFieldsContainer?.isHidden = !isCustom
        default:
            break
        }
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return v
    }

    // MARK: - UI

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "toolTipsConfig :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)

        let segmentWrapper = UIView()
        segmentWrapper.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        container.addArrangedSubview(segmentWrapper)

        segmentControl.apportionsSegmentWidthsByContent = false
        return container
    }

    private func buildFormContainer() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 28
        container.alignment = .fill

        // isEnabled row
        let enabledRow = UIView()
        let enabledLabel = UILabel()
        enabledLabel.text = "isEnabled"
        enabledLabel.font = .systemFont(ofSize: 16, weight: .medium)
        enabledLabel.textColor = .label
        enabledRow.addSubview(enabledLabel)
        enabledRow.addSubview(isEnabledSwitch)
        enabledLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(isEnabledSwitch.snp.leading).offset(-12)
        }
        isEnabledSwitch.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        container.addArrangedSubview(enabledRow)

        // Title, Content, and HTML Content sections, each internally controlled by nil / StringsWithLanguage segments
        container.addArrangedSubview(stringsSection(title: "title", segment: titleSegment, fieldsStore: &titleFields))
        container.addArrangedSubview(stringsSection(title: "content", segment: contentSegment, fieldsStore: &contentFields))
        container.addArrangedSubview(stringsSection(title: "htmlContent", segment: htmlSegment, fieldsStore: &htmlContentFields))

        return container
    }

    private func stringsSection(title: String, segment: UISegmentedControl, fieldsStore: inout [UITextField]) -> UIView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 14
        section.alignment = .fill

        let titleRow = UIStackView()
        titleRow.axis = .vertical
        titleRow.spacing = 4
        titleRow.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleRow.addArrangedSubview(titleLabel)

        let segWrapper = UIView()
        segWrapper.addSubview(segment)
        segment.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        segment.apportionsSegmentWidthsByContent = false
        segment.addTarget(self, action: #selector(stringsSegmentChanged(_:)), for: .valueChanged)
        titleRow.addArrangedSubview(segWrapper)

        section.addArrangedSubview(titleRow)

        let fieldsStack = UIStackView()
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 20
        fieldsStack.alignment = .fill

        fieldsStore = []
        for labelText in StringsField.labels {
            let field = UITextField()
            field.placeholder = "nil"
            field.borderStyle = .roundedRect
            field.font = .systemFont(ofSize: 15)
            field.autocorrectionType = .no
            fieldsStore.append(field)

            let row = UIView()
            let label = UILabel()
            label.text = "\(labelText) :"
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .label
            row.addSubview(label)
            row.addSubview(field)
            label.snp.makeConstraints { make in
                make.top.leading.bottom.equalToSuperview()
                make.trailing.equalTo(field.snp.leading).offset(-8)
            }
            field.snp.makeConstraints { make in
                make.centerY.equalTo(label)
                make.trailing.equalToSuperview()
                make.width.greaterThanOrEqualTo(80)
            }
            fieldsStack.addArrangedSubview(row)
        }

        let indentWrapper = UIStackView(arrangedSubviews: [fieldsStack])
        indentWrapper.axis = .vertical
        indentWrapper.alignment = .fill
        indentWrapper.isLayoutMarginsRelativeArrangement = true
        indentWrapper.layoutMargins = UIEdgeInsets(top: 0, left: 24 * 2, bottom: 0, right: 0)

        switch title {
        case "title":
            titleFieldsContainer = indentWrapper
        case "content":
            contentFieldsContainer = indentWrapper
        default:
            htmlFieldsContainer = indentWrapper
        }
        section.addArrangedSubview(indentWrapper)
        return section
    }
}

