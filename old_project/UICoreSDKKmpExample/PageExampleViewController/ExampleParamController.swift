//
//  ExampleParamController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

class ExampleParamController: FormViewController, JYPageChildContollerProtocol
{
    var valueCallback: ((Any?) -> Void)?
    var didSelectProTable: ((Any?) -> Void)?
    
    var exampleModel: ExampleV2Model
    
    // textfield dict value
    var textfieldDictValue: [String: Any] = [:]
    private var rowValue: Any?
    var pickerSelectorRow: SelectorPickerRowFormer<ExamplePickerTableViewCell, Any>?

    public var dataSources: [SelectorPickerItem<Any>] = []
    
    private lazy var iconImageView: UIImageView = {
        let img = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: view.frame.width - 50)))
        img.image = UIImage.init(named: exampleModel.imagename)
        img.contentMode = .scaleAspectFit
        img.backgroundColor = UIColor(red: 248 / 255.0, green: 247 / 255.0, blue: 247 / 255.0, alpha: 1)
        return img
    }()
    
    init(exampleModel: ExampleV2Model) {
        self.exampleModel = exampleModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.exampleModel.type == .Venue {
            valueCallback?(getDictValue())
        } else {
            valueCallback?(rowValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white

        view.addSubview(iconImageView)

        let top = view.frame.width - 50
        tableView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 100, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: view.frame.width, bottom: 0, right: 0)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorColor = .clear

        rowValue = getDefaultValues()
        loadForm()

        dataSources = getPickerItems().map {
            SelectorPickerItem(title: $0.title, value: $0.value)
        }
    }

    public func getDictValue() -> [String: Any] {
        if !textfieldDictValue.values.isEmpty {
            valueCallback?(textfieldDictValue)
        } else {
            let item = self.getPickerItems().first
            textfieldDictValue["title"] = item?.title
            textfieldDictValue["venyeTypes"] = item?.value
            valueCallback?(textfieldDictValue)
        }
        return textfieldDictValue
    }

}

extension ExampleParamController {
    func loadForm() {
        let inputAccessoryView = FormerInputAccessoryView(former: former)

        let pickerSelectorRow = SelectorPickerRowFormer<ExamplePickerTableViewCell, Any> { [weak self] in
            guard let self = self else { return }
            $0.titleLabel.attributedText = getPickerRow()
            $0.titleLabel.font = .boldSystemFont(ofSize: 13)

            $0.displayLabel.font = .systemFont(ofSize: 15)
            $0.displayLabel.textColor = UIColor(red: 31 / 255.0, green: 31 / 255.0, blue: 31 / 255.0, alpha: 1)
        }.configure {
            $0.selectorViewUpdate {
                $0.backgroundColor = .white
            }
            $0.pickerItems = getPickerItems()
            $0.inputAccessoryView = inputAccessoryView
            $0.rowHeight = UITableView.automaticDimension
            $0.onUpdate { [weak self] in
                guard let self = self else { return }
                pickerRowOnUpdate(r: $0)
            }
        }.onValueChanged { [weak self] item in
            guard let self = self else { return }
            rowValue = item.value
            valueCallback?(self.rowValue)
        }
        self.pickerSelectorRow = pickerSelectorRow

        let titleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) { [weak self] in
            guard let self = self else { return }
            if self.exampleModel.type == .CustomisedContent {
                let att = customisedContentAtt(self.exampleModel.title, subString: self.exampleModel.titleAttri ?? "")
                $0.titleAttributedString = att
            } else {
                $0.title = self.exampleModel.title
                $0.titleFont = .systemFont(ofSize: 15)
            }
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }

        let subtitleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) {[weak self] in
            guard let self = self else { return }
            $0.title = self.exampleModel.subtitle
            $0.titleFont = .systemFont(ofSize: 15)
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }

        let createSpaceHeader: () -> ViewFormer = {
            CustomViewFormer<FormHeaderFooterView>().configure {
                $0.viewHeight = 0.1
            }.update { _ in
            }
        }

        var dynamicHeightSection: SectionFormer
        if self.exampleModel.type == .Venue {
            dynamicHeightSection = SectionFormer(rowFormers: [titleRow, subtitleRow])
                .set(headerViewFormer: createSpaceHeader())
        } else {
            dynamicHeightSection = SectionFormer(rowFormers: [pickerSelectorRow, titleRow, subtitleRow])
                .set(headerViewFormer: createSpaceHeader())
        }
        former.append(sectionFormer: dynamicHeightSection).onCellSelected { _ in
            self.former.deselect(animated: true)
        }
    }
    
}


extension ExampleParamController {
    
    private func getDefaultValues() -> Any {
        switch self.exampleModel.type {
        case .Venue:
            return VenueType.K11Musea
        case .Journey:
            return Journeys.FullUserJourneys
        case .CustomisedContent:
            return CustomisedContentType.NotForNow
        case .MapStyle:
            return MapStyle.Drop_in_ui
        case .Theme:
            return MapStyle.Drop_in_ui
        case .Language:
            return ShowCaseLanguage.System
        case .ShareTypeDisplay:
            return ShareTypeDisplay.Both
        default:
            return VenueType.K11Musea
        }
    }
    
    private func getPickerItems() -> [SelectorPickerItem<Any>] {
        var items: [SelectorPickerItem<Any>] = []
        switch self.exampleModel.type {
        case .Venue:
            let types = EampleConfig.venyeTypes

            items = types.map {
                SelectorPickerItem(title: $0.rawValue, value: $0)
            }
        case .Theme:
            let themes = [NSLocalizedString("Default", comment: ""),
                          NSLocalizedString("Design System", comment: ""),
                          NSLocalizedString("Black/Purple", comment: "")]
            let t = EampleConfig.mapStyles
            
            for (idx, style) in themes.enumerated() {
                items.append(SelectorPickerItem(title: style, value: t[idx]))
            }
        case .Language:
            let l = [NSLocalizedString("System Language（默認）", comment: ""),
                     NSLocalizedString("English", comment: ""),
                     NSLocalizedString("Traditional Chinese", comment: ""),
                     NSLocalizedString("Simplified Chinese", comment: ""),
                     NSLocalizedString("Japanese", comment: "")]
            let languageType = EampleConfig.languageTypes
            
            for (idx, language) in l.enumerated() {
                items.append(SelectorPickerItem(title: language, value: languageType[idx]))
            }
        case .ShareTypeDisplay:
            let list = [
                "None", "Location Info", "Both"
            ]
            let modes = EampleConfig.shareDisplayModes
            for (idx, tmp) in list.enumerated() {
                items.append(SelectorPickerItem(title: tmp, value: modes[idx]))
            }
        default:
            break
        }
        return items
    }

    
    private func getPickerRow() -> NSMutableAttributedString {
        let start = "*"
        let text = self.exampleModel.text ?? ""
        let att = NSMutableAttributedString(string: start + text)
        let redColor = UIColor(red: 245 / 255.0, green: 34 / 255.0, blue: 45 / 255.0, alpha: 1)
        let darkGrayColor = UIColor(red: 89 / 255.0, green: 89 / 255.0, blue: 89 / 255.0, alpha: 1)
        att.addForegroundColor(redColor, range: NSRange(location: 0, length: start.count))
        att.addForegroundColor(darkGrayColor, range: NSRange(location: start.count, length: text.count))
        return att
    }
    
    private func customisedContentAtt(_ text: String, subString: String) -> NSMutableAttributedString {
        let att = NSMutableAttributedString(string: text + "\n" + subString)
        let darkColor = UIColor(red: 31 / 255.0, green: 31 / 255.0, blue: 31 / 255.0, alpha: 1)
        let grayColor = UIColor(red: 140 / 255.0, green: 140 / 255.0, blue: 140 / 255.0, alpha: 1)
        att.addForegroundColor(darkColor, range: NSRange(location: 0, length: text.count))
        att.addFont(.systemFont(ofSize: 15), on: NSRange(location: 0, length: text.count))
        att.addForegroundColor(grayColor, range: NSRange(location: text.count + 1, length: subString.count))
        att.addFont(.systemFont(ofSize: 12), on: NSRange(location: text.count + 1, length: subString.count))
        return att
    }
    
    private func pickerRowOnUpdate(r: SelectorPickerRowFormer<ExamplePickerTableViewCell, Any>) {
        if exampleModel.type == .CustomisedContent {
            if let idx = CustomisedContentType.getTypeIdx(.NotForNow) {
                r.selectedRow = idx
            }
        } else if exampleModel.type == .ShareTypeDisplay {
            let idx = ShareTypeDisplay.getTypeIdx(.Both)
            r.selectedRow = idx
        }
    }
}
