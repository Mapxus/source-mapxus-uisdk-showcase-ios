//
//  SearchVenuesNearbyViewController.swift
//  UISDKKmpSample
//
//  searchVenuesNearby 功能详情页
//

import UIKit
import SnapKit
import DropInUISDK

final class SearchVenuesNearbyViewController: BaseFeatureViewController {

    private let latitudeField = SearchVenuesNearbyViewController.makeDoubleField(placeholder: "latitude",text: "22.29445")
    private let longitudeField = SearchVenuesNearbyViewController.makeDoubleField(placeholder: "longitude",text: "114.174815")
    private let radiusField = SearchVenuesNearbyViewController.makeDoubleField(placeholder: "radius (meters)",text: "1000")

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
            let latText = latitudeField.text, let latitude = Double(latText),
            let lonText = longitudeField.text, let longitude = Double(lonText),
            let radiusText = radiusField.text, let radius = Double(radiusText)
        else {
            showAlert(title: "Invalid Input", message: "Please enter valid numbers for latitude, longitude, and radius.")
            return
        }
        appendLog("→ searchVenuesNearby(latitude: \(latitude), longitude: \(longitude), radius: \(radius))")
        Task { @MainActor in
            do {
                let venues = try await sdk.getDataSearcher().searchVenuesNearby(latitude: latitude, longitude: longitude, radius: radius)
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

        stack.addArrangedSubview(fieldRow(label: "latitude", field: latitudeField))
        stack.addArrangedSubview(fieldRow(label: "longitude", field: longitudeField))
        stack.addArrangedSubview(fieldRow(label: "radius", field: radiusField))
        return stack
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private static func makeDoubleField(placeholder: String,text: String) -> UITextField {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = placeholder
        t.keyboardType = .decimalPad
        t.text = text
        return t
    }
}
