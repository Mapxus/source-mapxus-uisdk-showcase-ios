//
//  SearchPoiByBoundsViewController.swift
//  UISDKKmpSample
//
//  searchPoiByBounds 功能详情页
//

import UIKit
import SnapKit
import DropInUISDK

final class SearchPoiByBoundsViewController: BaseFeatureViewController {

    private let maxLatField = SearchPoiByBoundsViewController.makeDoubleField(placeholder: "maxLat",text: "22.2900")
    private let maxLonField = SearchPoiByBoundsViewController.makeDoubleField(placeholder: "maxLon",text: "114.1650")
    private let minLatField = SearchPoiByBoundsViewController.makeDoubleField(placeholder: "minLat",text: "22.3050")
    private let minLonField = SearchPoiByBoundsViewController.makeDoubleField(placeholder: "minLon",text: "114.1850")
    private let queryNameField: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = "queryName"
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        t.text = "c"
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
        guard
            let maxLatText = maxLatField.text, let maxLat = Double(maxLatText),
            let maxLonText = maxLonField.text, let maxLon = Double(maxLonText),
            let minLatText = minLatField.text, let minLat = Double(minLatText),
            let minLonText = minLonField.text, let minLon = Double(minLonText)
        else {
            showAlert(title: "Invalid Input", message: "Please enter valid numbers for all bounds fields.")
            return
        }
        let queryName = (queryNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let bounds = Bounds(maxLat: maxLat, maxLon: maxLon, minLat: minLat, minLon: minLon)
        appendLog("→ searchPoiByBounds(bounds: Bounds(maxLat: \(maxLat), maxLon: \(maxLon), minLat: \(minLat), minLon: \(minLon)), queryName: \"\(queryName)\")")
        Task { @MainActor in
            do {
                let poi = try await sdk.getDataSearcher().searchPoiByBounds(bounds: bounds, queryName: queryName)
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
        stack.spacing = 8
        stack.alignment = .fill

        func fieldRow(label text: String, field: UITextField) -> UIView {
            let v = UIStackView()
            v.axis = .vertical
            v.spacing = 4
            let lbl = UILabel()
            lbl.text = text
            lbl.font = .systemFont(ofSize: 14, weight: .semibold)
            lbl.textColor = .secondaryLabel
            v.addArrangedSubview(lbl)
            v.addArrangedSubview(field)
            return v
        }

        stack.addArrangedSubview(fieldRow(label: "maxLat", field: maxLatField))
        stack.addArrangedSubview(fieldRow(label: "maxLon", field: maxLonField))
        stack.addArrangedSubview(fieldRow(label: "minLat", field: minLatField))
        stack.addArrangedSubview(fieldRow(label: "minLon", field: minLonField))
        stack.addArrangedSubview(fieldRow(label: "queryName", field: queryNameField))
        return stack
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private static func makeDoubleField(placeholder: String,text:String) -> UITextField {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = placeholder
        t.keyboardType = .decimalPad
        t.text = text
        return t
    }
}
