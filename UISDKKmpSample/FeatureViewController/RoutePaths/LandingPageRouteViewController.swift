//
//  LandingPageRouteViewController.swift
//  UISDKKmpSample
//
//  LandingPageRoute 功能详情页
//  Name: LandingPageRoute
//  Type: AppRoute
//

import UIKit
import SnapKit
import DropInUISDK

final class LandingPageRouteViewController: BaseFeatureViewController {

    private let venueIdsTextView: UITextView = {
        let t = UITextView()
        t.font = .systemFont(ofSize: 14)
        t.isScrollEnabled = false
        t.layer.cornerRadius = 8
        t.layer.masksToBounds = true
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.separator.cgColor
        t.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return t
    }()

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
    }

    override func saveBarButtonTapped() {
        let route = parseRoute()
        Config.shared.appRoute = route
        Config.shared.saveRouteChange([featureName: route])
        super.saveBarButtonTapped()
    }

    func parseRoute() -> LandingPageRoute {
        let raw = (venueIdsTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ids = raw.isEmpty ? [] : raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return LandingPageRoute(venueIds: ids)
    }

    private func buildFormView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "venueIds"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label

        let hintLabel = UILabel()
        hintLabel.text = "Comma-separated venue IDs. Leave empty for default landing page."
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0

        venueIdsTextView.snp.makeConstraints { $0.height.greaterThanOrEqualTo(80) }

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(venueIdsTextView)
        stack.addArrangedSubview(hintLabel)
        return stack
    }
}
