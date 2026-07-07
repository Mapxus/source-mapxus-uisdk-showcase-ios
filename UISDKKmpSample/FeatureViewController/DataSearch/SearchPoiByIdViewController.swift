//
//  SearchPoiByIdViewController.swift
//  UISDKKmpSample
//
//  searchPoiById feature detail page
//

import UIKit
import SnapKit
import DropInUISDK

final class SearchPoiByIdViewController: BaseFeatureViewController {

    private let poiIdField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = "poiId"
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        t.text = "12735072"
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
        let poiId = (poiIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !poiId.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please enter a poiId.")
            return
        }
        appendLog("→ searchPoiById(poiId: \"\(poiId)\")")
        Task { @MainActor in
            do {
                let poi = try await sdk.getDataSearcher().searchPoiById(poiId: poiId)
                if let poi = poi {
                    appendLog("← Success \(poi)")
                } else {
                    appendLog("← Result: nil (no POI found)")
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

        let label = UILabel()
        label.text = "poiId"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(poiIdField)
        return stack
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
