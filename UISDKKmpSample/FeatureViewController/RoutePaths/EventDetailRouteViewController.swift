//
//  EventDetailRouteViewController.swift
//  UISDKKmpSample
//
//  EventDetailRoute feature detail page
//  Name: EventDetailRoute
//  Type: AppRoute
//

import UIKit
import SnapKit
import DropInUISDK

final class EventDetailRouteViewController: BaseFeatureViewController {

    private let eventIdField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = "eventId"
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
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
        guard let route = parseRoute() else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter an eventId.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        Config.shared.appRoute = route
        Config.shared.saveRouteChange([featureName: route])
        super.saveBarButtonTapped()
    }

    func parseRoute() -> EventDetailRoute? {
        let eventId = (eventIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !eventId.isEmpty else { return nil }
        return EventDetailRoute(eventId: eventId)
    }

    private func buildFormView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        let titleLabel = UILabel()
        titleLabel.text = "eventId"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(eventIdField)
        return stack
    }
}
