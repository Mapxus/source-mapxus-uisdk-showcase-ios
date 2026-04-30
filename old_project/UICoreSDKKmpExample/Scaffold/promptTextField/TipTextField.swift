//
//  TipTextField.swift
//  DropInUISDKExample
//
//  Created by mapxus on 2023/8/29.
//  Copyright © 2023 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.
//

import UIKit

class TipTextField: UITextField {
    let pCellHeight: CGFloat = 39
    private lazy var rightV = createRightView()

    init(frame: CGRect, inView: UIView) {
        super.init(frame: frame)
        setUpInView(inView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpInView(_ view: UIView) {
        font = UIFont.systemFont(ofSize: 14)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        leftViewMode = .always

        rightView = rightV
        rightViewMode = .unlessEditing
        clearButtonMode = .whileEditing

        addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
    }

    @objc func textFieldDidChanged(_ textField: UITextField) {
    }

    @objc func textFieldDidBegin(_ textField: UITextField) {
    }

    @objc func textFieldDidEnd(_ textField: UITextField) {
        self.resignFirstResponder()
    }

    private func createRightView() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        img.image = UIImage.init(named: "Search")
        v.addSubview(img)
        return v
    }
}


class PromptTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let t = UILabel()
        t.textColor = UIColor(red: 31 / 255.0, green: 31 / 255.0, blue: 31 / 255.0, alpha: 1)
        t.font = UIFont.systemFont(ofSize: 15)
        t.text = "-"
        return t
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 1000, right: 0)

        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(12)
//            make.trailing.equalToSuperview().offset(-12)
//            make.top.equalToSuperview().offset(15)
//            make.bottom.equalToSuperview().offset(-15)
//        }
    }

    func setTitleText(text: String?) {
        titleLabel.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


let CustomHeaderHeight: CGFloat = 25.0
class CustomHeader: UITableViewHeaderFooterView {
    lazy var headerTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: 200, height: CustomHeaderHeight))
        label.text = "Recommend"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 140 / 255.0, green: 140 / 255.0, blue: 140 / 255.0, alpha: 1)
        return label
    }()


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.setUI()
    }

    private func setUI() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(headerTitleLabel)
    }
}
