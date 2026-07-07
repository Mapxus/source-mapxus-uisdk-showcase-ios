//
//  FloorSelectorCategoriesViewController.swift
//  UISDKKmpSample
//
//  floorSelectorCategories feature detail page
//  Name: floorSelectorCategories
//  Type: [String]?
//  Default: nil
//  Description: List of recommended POI categories for each floor on the floor selector page.
//  When null, the default category list (e.g., restroom, mothers room, wheelchair_assist, parking) is displayed.
//

import UIKit
import SnapKit
import DropInUISDK

final class FloorSelectorCategoriesViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[String]"])
    private let categoriesTextView = UITextView()
    private var categoriesFieldsContainer: UIView?

    private enum CategoriesValidationError: LocalizedError {
        case atLeastOneRequired
        var errorDescription: String? {
            switch self {
            case .atLeastOneRequired:
                return "Please enter at least one category, separated by commas."
            }
        }
    }

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
        let categoriesContainer = categoriesInputFieldsView()
        categoriesFieldsContainer = categoriesContainer
        categoriesContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, categoriesContainer)

        let current = Config.shared.configValue(forKey: featureName) as? [String]
        if let categories = current, !categories.isEmpty {
            segmentControl.selectedSegmentIndex = 1
            categoriesFieldsContainer?.isHidden = false
            categoriesTextView.text = categories.joined(separator: ",")
        } else {
            segmentControl.selectedSegmentIndex = 0
            categoriesFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let (error, categories) = validate()
        if let error = error {
            let alert = UIAlertController(
                title: "Invalid",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        Config.shared.diConfig.floorSelectorCategories = categories
        Config.shared.saveChange([featureName: categories])
        super.saveBarButtonTapped()
    }

    /// Returns (error, categories). When error != nil, categories is meaningless. When error == nil, categories is the value to save (nil or [String]).
    private func validate() -> (error: Error?, categories: [String]?) {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }
        let rawText = (categoriesTextView.text ?? "")
        let parts = rawText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else {
            return (CategoriesValidationError.atLeastOneRequired, nil)
        }
        return (nil, parts)
    }

    @objc private func segmentChanged() {
        categoriesFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "floorSelectorCategories :"
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

    private func categoriesInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        categoriesTextView.font = .systemFont(ofSize: 15)
        categoriesTextView.isScrollEnabled = false
        categoriesTextView.layer.cornerRadius = 8
        categoriesTextView.layer.masksToBounds = true
        categoriesTextView.layer.borderWidth = 1
        categoriesTextView.layer.borderColor = UIColor.separator.cgColor
        categoriesTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        categoriesTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Multiple categories separated by commas, e.g. \"restroom, mothers room, wheelchair_assist, parking\"."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        container.addArrangedSubview(categoriesTextView)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
