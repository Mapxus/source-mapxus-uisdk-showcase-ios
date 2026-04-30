//
//  RecommendedPoiIdsViewController.swift
//  UISDKKmpSample
//
//  recommendedPoiIds 功能详情页
//  Name: recommendedPoiIds
//  Type: [String]?
//  Default: nil
//  Description: List of recommended POI (Point of Interest) IDs to highlight or prioritize in the UI.
//  Can be used to guide users toward specific featured POIs.
//  When null, the default POI recommendation list is used.
//

import UIKit
import SnapKit
import DropInUISDK

final class RecommendedPoiIdsViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[String]"])
    private let poiIdsTextView = UITextView()
    private var poiIdsFieldsContainer: UIView?

    private enum PoiIdsValidationError: LocalizedError {
        case atLeastOneRequired
        var errorDescription: String? {
            switch self {
            case .atLeastOneRequired:
                return "Please enter at least one POI ID, separated by commas."
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

        // Selector + input for recommendedPoiIds
        let selectorRow = selectorRowView()
        let spacer = spacerView(height: 16)
        let poiIdsContainer = poiIdsInputFieldsView()
        poiIdsFieldsContainer = poiIdsContainer
        poiIdsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, poiIdsContainer)

        // Load current value from config and prefill UI
        let current = Config.shared.configValue(forKey: featureName) as? [String]
        if let ids = current, !ids.isEmpty {
            segmentControl.selectedSegmentIndex = 1
            poiIdsFieldsContainer?.isHidden = false
            poiIdsTextView.text = ids.joined(separator: ",")
        } else {
            segmentControl.selectedSegmentIndex = 0
            poiIdsFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let (error, ids) = validate()
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
        Config.shared.diConfig.recommendedPoiIds = ids
        Config.shared.saveChange([featureName: ids])
        super.saveBarButtonTapped()
    }

    /// Returns (error, ids). When error != nil, ids is meaningless. When error == nil, ids is the value to save (nil or [String]).
    private func validate() -> (error: Error?, ids: [String]?) {
        // nil selected -> valid
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }
        let rawText = (poiIdsTextView.text ?? "")
        let parts = rawText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else {
            return (PoiIdsValidationError.atLeastOneRequired, nil)
        }
        return (nil, parts)
    }

    @objc private func segmentChanged() {
        poiIdsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "recommendedPoiIds :"
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

    private func poiIdsInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        poiIdsTextView.font = .systemFont(ofSize: 15)
        poiIdsTextView.isScrollEnabled = false
        poiIdsTextView.layer.cornerRadius = 8
        poiIdsTextView.layer.masksToBounds = true
        poiIdsTextView.layer.borderWidth = 1
        poiIdsTextView.layer.borderColor = UIColor.separator.cgColor
        poiIdsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        poiIdsTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Multiple POI IDs separated by commas, e.g. \"poi_001, poi_002\"."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        container.addArrangedSubview(poiIdsTextView)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
