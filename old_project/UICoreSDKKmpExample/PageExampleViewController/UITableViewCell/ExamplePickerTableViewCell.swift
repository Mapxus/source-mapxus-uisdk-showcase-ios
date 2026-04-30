//
//  ExamplePickerTableViewCell.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

open class ExamplePickerTableViewCell: FormCell, SelectorPickerFormableRow {
    // MARK: Public

    open var selectorPickerView: UIPickerView?
    open var selectorAccessoryView: UIView?

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    public private(set) weak var titleLabel: UILabel!
    public private(set) weak var displayLabel: UILabel!

    public func formTitleLabel() -> UILabel? {
        return titleLabel
    }

    public func formDisplayLabel() -> UILabel? {
        return displayLabel
    }

    public func formDefaultDisplayLabelText() -> String? {
        return nil
    }

    public func formDefaultSelectedRow() -> Int? {
        return 0
    }

    open override func setup() {
        super.setup()

        let titleLabel = UILabel()
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(titleLabel, at: 0)
        self.titleLabel = titleLabel

        let pickerBgView = UIView()
        pickerBgView.translatesAutoresizingMaskIntoConstraints = false
        pickerBgView.layer.borderWidth = 1.0
        pickerBgView.layer.cornerRadius = 10
        pickerBgView.layer.borderColor = UIColor(red: 191 / 255.0, green: 191 / 255.0, blue: 191 / 255.0, alpha: 1).cgColor
        contentView.insertSubview(pickerBgView, at: 0)

        let displayLabel = UILabel()
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.textColor = .lightGray
        displayLabel.textAlignment = .left
        contentView.insertSubview(displayLabel, at: 0)
        self.displayLabel = displayLabel

        let rightImageView = UIImageView()
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.image = UIImage(named: "unfold_more_horizontal")
        pickerBgView.insertSubview(rightImageView, at: 0)

        NSLayoutConstraint.activate([
            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            // pickerBgView
            pickerBgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            pickerBgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pickerBgView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            pickerBgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            pickerBgView.heightAnchor.constraint(equalToConstant: 50),

            // rightImageView
            rightImageView.widthAnchor.constraint(equalToConstant: 20),
            rightImageView.heightAnchor.constraint(equalToConstant: 20),
            rightImageView.trailingAnchor.constraint(equalTo: pickerBgView.trailingAnchor, constant: -8),
            rightImageView.centerYAnchor.constraint(equalTo: pickerBgView.centerYAnchor),

            // displayLabel
            displayLabel.leadingAnchor.constraint(equalTo: pickerBgView.leadingAnchor, constant: 8),
            displayLabel.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -8),
            displayLabel.centerYAnchor.constraint(equalTo: pickerBgView.centerYAnchor)
        ])
    }
}

