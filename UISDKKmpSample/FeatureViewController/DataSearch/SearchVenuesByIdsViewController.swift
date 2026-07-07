//
//  SearchVenuesByIdsViewController.swift
//  UISDKKmpSample
//
//  searchVenuesByIds feature detail page
//

import UIKit
import SnapKit
import DropInUISDK

final class SearchVenuesByIdsViewController: BaseFeatureViewController {

    private let venueIdsTextView: UITextView = {
        let t = UITextView()
        t.font = .systemFont(ofSize: 14)
        t.isScrollEnabled = false
        t.layer.cornerRadius = 8
        t.layer.masksToBounds = true
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.separator.cgColor
        t.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        t.text = "caab5a38-79e1-11e8-8453-951df499024d,e679b6fc0818456aa1867aa021a3e84a"
        return t
    }()

    private lazy var sdk: DISdk = DISdk(diConfig: Config.shared.diConfig.build())

    required init(featureName: String) {
        super.init(featureName: featureName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            sdk.cleanup()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Search",
            style: .plain,
            target: self,
            action: #selector(saveBarButtonTapped)
        )

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

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

        addFunctionDescriptionContent(to: content)
        addParameterSection(to: content, views: buildFormView())
        addLogSection(to: content)
    }

    override func saveBarButtonTapped() {
        let raw = (venueIdsTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ids = raw.isEmpty ? [] : raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard !ids.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please enter at least one venue ID.")
            return
        }
        appendLog("→ searchVenuesByIds(venueIds: \(ids))")
        Task { @MainActor in
            do {
                let venues = try await sdk.getDataSearcher().searchVenuesByIds(venueIds: ids)
                if venues.isEmpty {
                    appendLog("← Result: [] (no venues found)")
                } else {
                    appendLog("← Success \(venues)")
                }
            } catch {
                appendLog("✗ Error: \(error.localizedDescription)")
            }
        }
    }

    private func buildFormView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "venueIds"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let hintLabel = UILabel()
        hintLabel.text = "Comma-separated venue IDs. Max 10 IDs."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .tertiaryLabel
        hintLabel.numberOfLines = 0

        venueIdsTextView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(80) }

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(venueIdsTextView)
        stack.addArrangedSubview(hintLabel)
        return stack
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
