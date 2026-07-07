//
//  GlobalFilterTagIdsViewController.swift
//  UISDKKmpSample
//
//  globalFilterTagIds feature detail page
//  Name: globalFilterTagIds
//  Type: [String]?
//  Default: nil
//  Description: Specifies the list of tagIds to be displayed in the global filter.
//  Controls which tags are visible to users when interacting with the global filter module.
//  If null, the global filter will use the default set of tags.
//  If an empty list is set, no tags will be displayed in the global filter.
//

import UIKit
import SnapKit
import DropInUISDK

final class GlobalFilterTagIdsViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[String]"])
    private let tagIdsTextView = UITextView()
    private var tagIdsFieldsContainer: UIView?

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

        let selectorRow = selectorRowView()
        let spacer = spacerView(height: 16)
        let tagIdsContainer = tagIdsInputFieldsView()
        tagIdsFieldsContainer = tagIdsContainer
        tagIdsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, tagIdsContainer)

        let current = Config.shared.configValue(forKey: featureName) as? [String]
        if let tagIds = current {
            segmentControl.selectedSegmentIndex = 1
            tagIdsFieldsContainer?.isHidden = false
            tagIdsTextView.text = tagIds.joined(separator: ",")
        } else {
            segmentControl.selectedSegmentIndex = 0
            tagIdsFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let tagIds = valueToSave()
        Config.shared.diConfig.globalFilterTagIds = tagIds
        Config.shared.saveChange([featureName: tagIds])
        super.saveBarButtonTapped()
    }

    private func valueToSave() -> [String]? {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return nil
        }
        let rawText = (tagIdsTextView.text ?? "")
        let parts = rawText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts
    }

    @objc private func segmentChanged() {
        tagIdsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "globalFilterTagIds :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addSubview(label)
        container.addSubview(segmentControl)
        label.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(segmentControl.snp.leading).offset(-12)
        }
        segmentControl.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
        }
        return container
    }

    private func spacerView(height: CGFloat) -> UIView {
        let v = UIView()
        v.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return v
    }

    private func tagIdsInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        tagIdsTextView.font = .systemFont(ofSize: 15)
        tagIdsTextView.isScrollEnabled = false
        tagIdsTextView.layer.cornerRadius = 8
        tagIdsTextView.layer.masksToBounds = true
        tagIdsTextView.layer.borderWidth = 1
        tagIdsTextView.layer.borderColor = UIColor.separator.cgColor
        tagIdsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tagIdsTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Tag IDs separated by commas. Leave empty to save an empty list []."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        container.addArrangedSubview(tagIdsTextView)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
