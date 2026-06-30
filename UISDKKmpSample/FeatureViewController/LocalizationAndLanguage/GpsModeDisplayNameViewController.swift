//
//  GpsModeDisplayNameViewController.swift
//  UISDKKmpSample
//
//  gpsModeDisplayName 功能详情页
//  Name: gpsModeDisplayName
//  Type: StringsWithLanguage?
//  Default: nil
//  Description: Custom display name for the GPS mode label shown alongside the GPS icon.
//  Replaces the default "GPS" text on all pages displaying the GPS icon.
//  If the text exceeds available space, it will be truncated with an ellipsis (…).
//  Supports multiple languages via [StringsWithLanguage].
//  When null, uses the default localized "GPS" label.
//  When set to an empty string (\"\"), the GPS mode label will not be displayed.
//

import UIKit
import SnapKit
import DropInUISDK

final class GpsModeDisplayNameViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "StringsWithLanguage"])
    private var stringsFieldsContainer: UIView?
    private var textFields: [UITextField] = []

    private enum StringsField {
        static let labels = ["default", "en", "ja", "ko", "zhHans", "zhHant", "zhHantTW", "ar", "fr", "it"]
        static func value(at index: Int, from strings: StringsWithLanguage) -> String? {
            switch index {
            case 0: return strings.default
            case 1: return strings.en
            case 2: return strings.ja
            case 3: return strings.ko
            case 4: return strings.zhHans
            case 5: return strings.zhHant
            case 6: return strings.zhHantTW
            case 7: return strings.ar
            case 8: return strings.fr
            case 9: return strings.it
            default: return nil
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
        let spacer = spacerView(height: 1)
        let stringsContainer = stringsInputFieldsView()
        stringsFieldsContainer = stringsContainer
        stringsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, stringsContainer)

        let current = Config.shared.configValue(forKey: featureName) as? StringsWithLanguage
        if let strings = current {
            segmentControl.selectedSegmentIndex = 1
            stringsFieldsContainer?.isHidden = false
            for (index, _) in StringsField.labels.enumerated() where index < textFields.count {
                textFields[index].text = StringsField.value(at: index, from: strings)
            }
        } else {
            segmentControl.selectedSegmentIndex = 0
            stringsFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            Config.shared.diConfig.gpsModeDisplayName = nil
            Config.shared.saveChange([featureName: nil as StringsWithLanguage?])
            super.saveBarButtonTapped()
            return
        }

        let values = textFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        // 支持显式空字符串：输入 \"\" 表示空字符串，留空表示 nil
        let optValues: [String?] = values.map { s in
            if s.isEmpty { return nil }
            if s == "\"\"" { return "" }
            return s
        }

        let strings = StringsWithLanguage(
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
        Config.shared.diConfig.gpsModeDisplayName = strings
        Config.shared.saveChange([featureName: strings])
        super.saveBarButtonTapped()
    }

    @objc private func segmentChanged() {
        stringsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return v
    }

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "gpsModeDisplayName :"
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

        // 2 个 segment 时等宽更美观
        segmentControl.apportionsSegmentWidthsByContent = false
        return container
    }

    private func stringsInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        container.alignment = .fill
        textFields = []
        for labelText in StringsField.labels {
            let field = UITextField()
            field.placeholder = "nil"
            field.borderStyle = .roundedRect
            field.font = .systemFont(ofSize: 15)
            field.autocorrectionType = .no
            textFields.append(field)
            let row = inputRowView(label: "\(labelText) :", textField: field)
            container.addArrangedSubview(row)
        }
        let tabWidth: CGFloat = 24
        let wrapper = UIStackView(arrangedSubviews: [container])
        wrapper.axis = .vertical
        wrapper.alignment = .fill
        wrapper.isLayoutMarginsRelativeArrangement = true
        wrapper.layoutMargins = UIEdgeInsets(top: 0, left: tabWidth * 2, bottom: 0, right: 0)
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
            make.width.greaterThanOrEqualTo(80)
        }
        return container
    }
}

