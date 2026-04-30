//
//  DynamicHeightCell.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit

class DynamicHeightCell: FormCell {
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var titleFont: UIFont? {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }

    var titleAttributedString: NSAttributedString? {
        get { return titleLabel.attributedText }
        set { titleLabel.attributedText = newValue }
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
        ])

    }
    // MARK: Private

    @IBOutlet private weak var titleLabel: UILabel!
}
