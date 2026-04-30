//
//  CheckRowFormer.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

public protocol CheckFormableRow: FormableRow {
    func formTitleLabel() -> UILabel?
    func formCustomCheckView() -> UIView?
}

open class CheckRowFormer<T: UITableViewCell>
: BaseRowFormer<T>, Formable where T: CheckFormableRow {
    // MARK: Public
    open var value: Any?
    open var checked = false
    open var customCheckView: UIView?
    open var titleDisabledColor: UIColor? = .lightGray

    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }

    @discardableResult
    public final func onCheckChanged(_ handler: @escaping ((Bool) -> Void)) -> Self {
        onCheckChanged = handler
        return self
    }

    open override func update() {
        super.update()

        customCheckView = cell.formCustomCheckView()

        if let customCheckView = customCheckView {
            customCheckView.isHidden = checked ? false : true
        } else {
            cell.accessoryType = checked ? .checkmark : .none
        }
        let titleLabel = cell.formTitleLabel()
        if enabled {
            _ = titleColor.map { titleLabel?.textColor = $0 }
            titleColor = nil
        } else {
            if titleColor == nil { titleColor = titleLabel?.textColor ?? .black }
            titleLabel?.textColor = titleDisabledColor
        }
    }

    open override func cellSelected(indexPath: IndexPath) {
        former?.deselect(animated: true)
        if enabled {
            checked.toggle()
            onCheckChanged?(checked)
            if let customCheckView = customCheckView {
                customCheckView.isHidden = checked ? false : true
            } else {
                cell.accessoryType = checked ? .checkmark : .none
            }
        }
    }

    // MARK: Private

    private final var titleColor: UIColor?
    private final var onCheckChanged: ((Bool) -> Void)?
}

