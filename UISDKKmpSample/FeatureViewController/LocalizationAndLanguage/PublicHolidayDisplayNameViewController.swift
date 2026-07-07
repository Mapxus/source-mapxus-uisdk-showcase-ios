//
//  PublicHolidayDisplayNameViewController.swift
//  UISDKKmpSample
//
//  publicHolidayDisplayName feature detail page
//  Name: publicHolidayDisplayName
//  Type: StringsWithLanguage
//  Default: defaultPhDisplayName with localized public holiday labels
//  Description: Display name for public holidays in the UI. Supports multiple languages via StringsWithLanguage.
//

import UIKit
import SnapKit
import DropInUISDK

final class PublicHolidayDisplayNameViewController: BaseFeatureViewController {

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

        let stringsContainer = stringsInputFieldsView()
        addParameterSection(to: content, views: stringsContainer)

        let current = Config.shared.configValue(forKey: featureName) as? StringsWithLanguage
            ?? Config.shared.defaultValue(forKey: featureName) as? StringsWithLanguage
        if let strings = current {
            for (index, _) in StringsField.labels.enumerated() where index < textFields.count {
                textFields[index].text = StringsField.value(at: index, from: strings)
            }
        }
    }

    override func saveBarButtonTapped() {
        let values = textFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let optValues = values.map { s in s.isEmpty ? nil : s }
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
        Config.shared.diConfig.publicHolidayDisplayName = strings
        Config.shared.saveChange([featureName: strings])
        super.saveBarButtonTapped()
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
