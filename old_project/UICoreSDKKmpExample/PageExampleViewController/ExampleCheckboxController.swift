//
//  ExamplePOIDetailsController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

class ExampleCheckboxController: FormViewController, JYPageChildContollerProtocol {
    var valueCallback: ((Any?) -> Void)?
    private var rowValue: [[String: [Any]]]?
    var exampleModel: ExampleV2Model
    //    var modelConfiguration: ExampleModelConfiguration?
    
    private var checkSection: SectionFormer?
    init(exampleModel: ExampleV2Model) {
        self.exampleModel = exampleModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: view.frame.width, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorColor = .clear
        
        loadForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        valueCallback?(getRowsValue())
    }
    
    func getRowsValue() -> [[String: [Any]]]? {
        rowValue = []
        checkSection?.rowFormers.forEach { former in
            if let f = former as? CheckRowFormer<ExampleCheckTableViewCell>, let item = f.value as? ExampleV2ModelItem {
                var dict: [String: [Any]] = [:]
                dict[item.type.rawValue] = [item, f.checked]
                rowValue?.append(dict)
            }
        }
        return rowValue
    }
    
    func loadForm() {
        let iconRow = CustomRowFormer<ExampleHeaderTableViewCell>(instantiateType: .Class) { [self] in
            $0.iconname = self.exampleModel.imagename
        }.configure {
            if exampleModel.imagename.isEmpty {
                $0.rowHeight = 0
            } else {
                $0.rowHeight = view.frame.width - 50
            }
        }
        
        let titleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) { [self] in
            $0.title = self.exampleModel.title
            $0.titleFont = .systemFont(ofSize: 15)
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }
        
        let titleRow1 = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) {
            $0.title = NSLocalizedString("Select the checkbox to listen for events", comment: "")
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }
        
        let subtitleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) {[self] in
            $0.title = self.exampleModel.subtitle
            $0.titleFont = .systemFont(ofSize: 15)
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 0.1
                }.update { _ in
                    //                    view.view.backgroundColor = .white
                }
        }
        
        var checkRows: [RowFormer] = []
        self.exampleModel.child?.forEach { item in
            let customCheckRow = CheckRowFormer<ExampleCheckTableViewCell> {
                let text = NSLocalizedString(item.type.rawValue, comment: "")
                $0.titleLabel.text = text
                $0.subtitleLabel.text = item.subtitle
                
                $0.titleLabel.font = .boldSystemFont(ofSize: 16)
                $0.subtitleLabel.font = .systemFont(ofSize: 13)
                
                $0.subtitleLabel.textColor = UIColor(red: 140 / 255.0, green: 140 / 255.0, blue: 140 / 255.0, alpha: 1)
            }.configure {
                $0.rowHeight = UITableView.automaticDimension
                //                if modelConfiguration != nil {
                //                    $0.checked = setCheckRowValue(item)
                //                } else {
                //                }
                $0.checked = item.isSelect
                $0.value = item
            }.onCheckChanged { [weak self] _ in
                guard let self = self else { return }
                self.valueCallback?(self.getRowsValue())
            }
            checkRows.append(customCheckRow)
        }
        
        let dynamicHeightSection = SectionFormer(rowFormers: [iconRow, titleRow, titleRow1]) .set(headerViewFormer: createSpaceHeader())
        checkSection = SectionFormer(rowFormers: checkRows).set(headerViewFormer: createSpaceHeader())
        
        let subtitleSection = SectionFormer(rowFormers: [subtitleRow]).set(headerViewFormer: createSpaceHeader())
        
        former.append(sectionFormer: dynamicHeightSection, checkSection!, subtitleSection).onCellSelected { _ in
            self.former.deselect(animated: true)
        }
    }
    
    private func getChildItem() -> ExampleV2ModelItem? {
        return self.exampleModel.child?.first
    }
    
    private func setCheckRowValue(_ item: ExampleV2ModelItem) -> Bool {
        var re = false
        return re
    }
}
