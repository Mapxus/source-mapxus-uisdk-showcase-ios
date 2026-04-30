//
//  BaseFeatureViewController.swift
//  UISDKKmpSample
//
//  三级页面基类（功能详情页）
//

import UIKit
import SnapKit

class BaseFeatureViewController: UIViewController {

    /// 当前功能名称（如 "initialBounds"）
    let featureName: String

    required init(featureName: String) {
        self.featureName = featureName
        super.init(nibName: nil, bundle: nil)
        self.title = featureName
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(saveBarButtonTapped)
        )
    }

    /// Save 按钮点击：基类默认行为为 pop 回上一页。子类可重写此方法，在完成校验与保存后调用 super.saveBarButtonTapped() 执行返回。
    @objc func saveBarButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    /// 描述区域卡片样式（圆角、背景、内边距）
    private func makeCardContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        return container
    }

    /// 区块标题样式
    private func makeSectionTitle(_ text: String) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return container
    }

    /// 分割线：用于分隔描述区块与参数区块
    private func makeSectionDivider() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = .separator
        line.alpha = 0.8
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        container.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        return container
    }

    /// 根据 featureName 从 FeatureInfo.json 读取并构建描述区域 UI，以卡片形式加入 content
    func addDescriptionContent(to content: UIStackView) {
        guard let table = FeatureInfoTable.load(),
              let item = table.item(forKey: featureName) else { return }

        // 描述区块标题
        let descSectionTitle = makeSectionTitle("Description")
        content.addArrangedSubview(descSectionTitle)

        let card = makeCardContainer()
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 16
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        card.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        innerStack.addArrangedSubview(rowView(title: "Name", value: item.name))
        innerStack.addArrangedSubview(rowView(title: "Data Type", value: item.dataType))
        innerStack.addArrangedSubview(rowView(title: "Default Value", value: item.defaultValue))

        let descTitle = UILabel()
        descTitle.text = "Description"
        descTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        descTitle.textColor = .secondaryLabel
        innerStack.addArrangedSubview(descTitle)

        let descText = UILabel()
        descText.text = item.description
        descText.font = .systemFont(ofSize: 15, weight: .regular)
        descText.textColor = .label
        descText.numberOfLines = 0
        descText.lineBreakMode = .byWordWrapping
        innerStack.addArrangedSubview(descText)

        content.addArrangedSubview(card)
    }

    /// 将参数设置 views 包装为卡片区块，加入 content（自动在区块前添加分割线）
    func addParameterSection(to content: UIStackView, views: UIView...) {
        // 分割线 + 参数区块标题
        content.addArrangedSubview(makeSectionDivider())
        let paramSectionTitle = makeSectionTitle("Parameters")
        content.addArrangedSubview(paramSectionTitle)

        let card = makeCardContainer()
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 16
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        card.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for view in views {
            innerStack.addArrangedSubview(view)
        }

        content.addArrangedSubview(card)
    }

    /// 为 Route 类型 VC 构建描述区域，字段：Route Class、Parameters、Return Type、Description
    func addFunctionDescriptionContent(to content: UIStackView) {
        guard let table = FeatureInfoTable.load(),
              let item = table.item(forKey: featureName) else { return }

        let descSectionTitle = makeSectionTitle("Description")
        content.addArrangedSubview(descSectionTitle)

        let card = makeCardContainer()
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 16
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        card.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        innerStack.addArrangedSubview(rowView(title: "Name", value: item.name))
        if let params = item.parameters {
            innerStack.addArrangedSubview(rowView(title: "Parameters", value: params))
        }
        if let returnType = item.returnType {
            innerStack.addArrangedSubview(rowView(title: "Return Type", value: returnType))
        }

        let descTitle = UILabel()
        descTitle.text = "Description"
        descTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        descTitle.textColor = .secondaryLabel
        innerStack.addArrangedSubview(descTitle)

        let descText = UILabel()
        descText.text = item.description
        descText.font = .systemFont(ofSize: 15, weight: .regular)
        descText.textColor = .label
        descText.numberOfLines = 0
        descText.lineBreakMode = .byWordWrapping
        innerStack.addArrangedSubview(descText)

        content.addArrangedSubview(card)
    }

    func rowView(title: String, value: String) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container
    }

    /// Listener 描述区域：从 FeatureInfo.json 读取 listenerName、methods、description 并展示
    func addListenerDescriptionContent(to content: UIStackView) {
        guard let table = FeatureInfoTable.load(),
              let item = table.item(forKey: featureName),
              let listenerName = item.listenerName,
              let methods = item.methods else { return }

        let descSectionTitle = makeSectionTitle("Description")
        content.addArrangedSubview(descSectionTitle)

        let card = makeCardContainer()
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 16
        innerStack.alignment = .fill
        innerStack.isLayoutMarginsRelativeArrangement = true
        innerStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        card.addSubview(innerStack)
        innerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        innerStack.addArrangedSubview(rowView(title: "Listener", value: listenerName))

        let methodsTitle = UILabel()
        methodsTitle.text = "Methods"
        methodsTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        methodsTitle.textColor = .secondaryLabel
        innerStack.addArrangedSubview(methodsTitle)

        for method in methods {
            let label = UILabel()
            label.text = "• \(method)"
            label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            label.textColor = .label
            label.numberOfLines = 0
            innerStack.addArrangedSubview(label)
        }

        let descTitle = UILabel()
        descTitle.text = "Description"
        descTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        descTitle.textColor = .secondaryLabel
        innerStack.addArrangedSubview(descTitle)

        let descText = UILabel()
        descText.text = item.description
        descText.font = .systemFont(ofSize: 15, weight: .regular)
        descText.textColor = .label
        descText.numberOfLines = 0
        innerStack.addArrangedSubview(descText)

        content.addArrangedSubview(card)
    }

    /// Switch 行：左边标题，右边 UISwitch
    func switchRow(title: String, control: UISwitch) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(control)
        label.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        control.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        return container
    }

    // MARK: - Log Section

    private var logTextView: UITextView?
    private var logHeightConstraint: Constraint?
    private var logContainer: UIStackView?

    /// 在 content 底部添加 Log 输出区域（初始隐藏，首次 appendLog 时显示；最高 3/4 屏幕，超出滚动）
    func addLogSection(to content: UIStackView) {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 20
        container.isHidden = true
        logContainer = container

        container.addArrangedSubview(makeSectionDivider())
        container.addArrangedSubview(makeSectionTitle("Log"))

        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.textColor = UIColor(red: 0.2, green: 0.9, blue: 0.35, alpha: 1)
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        logTextView = tv

        let card = makeCardContainer()
        card.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.06, alpha: 1)
        card.layer.borderWidth = 0
        card.addSubview(tv)
        tv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            logHeightConstraint = make.height.equalTo(60).constraint
        }
        container.addArrangedSubview(card)
        content.addArrangedSubview(container)
    }

    /// 追加一条 log，格式为 "[HH:mm:ss] message"，首次调用时自动显示 log 区域
    func appendLog(_ message: String) {
        guard let tv = logTextView else { return }
        if logContainer?.isHidden == true {
            logContainer?.isHidden = false
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let entry = "[\(formatter.string(from: Date()))] \(message)\n"
        tv.text = tv.text.isEmpty ? entry : tv.text + entry
        updateLogHeight()
    }

    private func updateLogHeight() {
        guard let tv = logTextView, let constraint = logHeightConstraint else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let tv = self.logTextView, let constraint = self.logHeightConstraint else { return }
            let availableWidth = tv.frame.width > 0 ? tv.frame.width : (UIScreen.main.bounds.width - 40)
            let contentSize = tv.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
            let maxHeight = UIScreen.main.bounds.height * 0.50
            let newHeight = max(60, min(contentSize.height + 16, maxHeight))
            let needsScroll = contentSize.height + 16 >= maxHeight
            constraint.update(offset: newHeight)
            tv.isScrollEnabled = needsScroll
            UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
            if needsScroll, !tv.text.isEmpty {
                tv.scrollRangeToVisible(NSRange(location: tv.text.count - 1, length: 0))
            }
        }
    }
}
