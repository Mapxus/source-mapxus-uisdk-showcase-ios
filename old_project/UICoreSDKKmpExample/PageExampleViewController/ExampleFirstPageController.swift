//
//  ExampleFirstPageController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit


class ExampleFirstPageController: FormViewController, JYPageChildContollerProtocol {
    var exampleModel: ExampleV2Model

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

        self.loadForm()
    }

    func loadForm() {
        let iconRow = CustomRowFormer<ExampleHeaderTableViewCell>(instantiateType: .Class) { [weak self] in
            guard let self = self else { return }
            $0.iconname = self.exampleModel.imagename
        }.configure {
            $0.rowHeight = view.frame.width - 50
        }

        let titleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) { [weak self] in
            guard let self = self else { return }
            $0.title = self.exampleModel.title
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }

        let subtitleRow = CustomRowFormer<DynamicHeightCell>(instantiateType: .Class) {[weak self] in
            guard let self = self else { return }
            $0.title = self.exampleModel.subtitle
        }.configure {
            $0.rowHeight = UITableView.automaticDimension
        }

        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 0.1
                }
        }

        let dynamicHeightSection = SectionFormer(rowFormers: [iconRow, titleRow, subtitleRow]).set(headerViewFormer: createSpaceHeader())

        former.append(sectionFormer: dynamicHeightSection).onCellSelected { [weak self] _ in
            guard let self = self else { return }
            self.former.deselect(animated: true)
        }
    }
}
