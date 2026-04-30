//
//  ExampleCheckTableViewCell.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/14.
//

import UIKit


open class ExampleCheckTableViewCell: FormCell, CheckFormableRow {
    // MARK: Public

    public private(set) weak var titleLabel: UILabel!
    public private(set) weak var subtitleLabel: UILabel!
    public private(set) weak var checkBgView: UIView!
    public private(set) weak var cutstomCheckView: UIView!

    public func formCustomCheckView() -> UIView? {
        return cutstomCheckView
    }

    public func formTitleLabel() -> UILabel? {
        return titleLabel
    }

    open override func setup() {
        super.setup()

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel

        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        self.subtitleLabel = subtitleLabel

        let checkBgView = UIView()
        checkBgView.layer.cornerRadius = 0
        checkBgView.layer.borderColor = UIColor.label.cgColor
        checkBgView.layer.borderWidth = 1
        checkBgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkBgView)
        self.checkBgView = checkBgView
        
        let check = UIImage(named: "check-square")!.withRenderingMode(.alwaysTemplate)
        let checkView = UIImageView(image: check)
        checkView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkView)
        cutstomCheckView = checkView

        // ✅ 添加原生约束
        NSLayoutConstraint.activate([
            checkView.widthAnchor.constraint(equalToConstant: 18),
            checkView.heightAnchor.constraint(equalToConstant: 18),
            checkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            checkBgView.widthAnchor.constraint(equalToConstant: 18),
            checkBgView.heightAnchor.constraint(equalToConstant: 18),
            checkBgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: checkView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}

