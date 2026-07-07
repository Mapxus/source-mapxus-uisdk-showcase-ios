//
//  VenueDefaultSharedFloorIdsViewController.swift
//  UISDKKmpSample
//
//  venueDefaultSharedFloorIds feature detail page
//  Name: venueDefaultSharedFloorIds
//  Type: [String]?
//  Default: nil
//  Description: List of shared floor IDs for venues. Replaces the default shared floor IDs of a venue with custom ones.
//  This list supports up to 10 venues; if more than 10 shared floor IDs are provided, only the first 10 will be applied.
//  When null, the system defaults are used for all venues.
//

import UIKit
import SnapKit
import DropInUISDK

final class VenueDefaultSharedFloorIdsViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["nil", "[String]"])
    private let idsTextView = UITextView()
    private var idsFieldsContainer: UIView?

    private enum ValidationError: LocalizedError {
        case atLeastOneRequired
        var errorDescription: String? {
            switch self {
            case .atLeastOneRequired:
                return "Please enter at least one shared floor ID, separated by commas."
            }
        }
    }

    /// Maximum number of shared floor IDs applied by the SDK.
    private static let maxCount = 10

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
        let idsContainer = idsInputFieldsView()
        idsFieldsContainer = idsContainer
        idsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, spacer, idsContainer)

        let current = Config.shared.configValue(forKey: featureName) as? [String]
        if let ids = current, !ids.isEmpty {
            segmentControl.selectedSegmentIndex = 1
            idsFieldsContainer?.isHidden = false
            idsTextView.text = ids.joined(separator: ",")
        } else {
            segmentControl.selectedSegmentIndex = 0
            idsFieldsContainer?.isHidden = true
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
        Config.shared.diConfig.venueDefaultSharedFloorIds = ids
        Config.shared.saveChange([featureName: ids])
        super.saveBarButtonTapped()
    }

    /// Returns (error, ids). When error != nil, ids is meaningless. When error == nil, ids is the value to save (nil or [String], at most 10).
    private func validate() -> (error: Error?, ids: [String]?) {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }
        let rawText = (idsTextView.text ?? "")
        let parts = rawText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !parts.isEmpty else {
            return (ValidationError.atLeastOneRequired, nil)
        }
        let capped = Array(parts.prefix(Self.maxCount))
        return (nil, capped)
    }

    @objc private func segmentChanged() {
        idsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "venueDefaultSharedFloorIds :"
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

    private func idsInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill

        idsTextView.font = .systemFont(ofSize: 15)
        idsTextView.isScrollEnabled = false
        idsTextView.layer.cornerRadius = 8
        idsTextView.layer.masksToBounds = true
        idsTextView.layer.borderWidth = 1
        idsTextView.layer.borderColor = UIColor.separator.cgColor
        idsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        idsTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }

        let hintLabel = UILabel()
        hintLabel.text = "Shared floor IDs separated by commas. At most 10 will be applied; extra IDs are ignored."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        container.addArrangedSubview(idsTextView)
        container.addArrangedSubview(hintLabel)
        return container
    }
}
