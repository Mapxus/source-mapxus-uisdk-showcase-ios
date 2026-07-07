//
//  InitialBoundsViewController.swift
//  UISDKKmpSample
//
//  initialBounds feature detail page
//

import UIKit
import SnapKit
import DropInUISDK

final class InitialBoundsViewController: BaseFeatureViewController, UITextFieldDelegate {

    private var boundsFieldsContainer: UIView?
    private var boundsTextFields: [UITextField] = []
    private let segmentControl = UISegmentedControl(items: ["nil", "Bounds"])

    private enum BoundsValidationError: LocalizedError {
        case missingFields
        case invalidNumber(field: String)
        var errorDescription: String? {
            switch self {
            case .missingFields: return "Please fill in all Bounds fields (maxLat, maxLon, minLat, minLon)."
            case .invalidNumber(let field): return "Invalid number for \(field)."
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

        // InitialBounds : (selector)
        let selectorRow = selectorRowView()
        let boundsContainer = boundsInputFieldsView()
        boundsFieldsContainer = boundsContainer
        boundsContainer.isHidden = true
        addParameterSection(to: content, views: selectorRow, boundsContainer)

        // Load current value from config and prefill UI
        let current = Config.shared.configValue(forKey: featureName) as? Bounds

        if let bounds = current {
            segmentControl.selectedSegmentIndex = 1
            boundsFieldsContainer?.isHidden = false
            if boundsTextFields.indices.contains(0) { boundsTextFields[0].text = formatNumber(bounds.maxLat) }
            if boundsTextFields.indices.contains(1) { boundsTextFields[1].text = formatNumber(bounds.maxLon) }
            if boundsTextFields.indices.contains(2) { boundsTextFields[2].text = formatNumber(bounds.minLat) }
            if boundsTextFields.indices.contains(3) { boundsTextFields[3].text = formatNumber(bounds.minLon) }
        } else {
            segmentControl.selectedSegmentIndex = 0
            boundsFieldsContainer?.isHidden = true
        }
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let (error, bounds) = validate()
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
        Config.shared.diConfig.initialBounds = bounds
        Config.shared.saveChange([featureName: bounds])
        super.saveBarButtonTapped()
    }

    /// Returns (error, bounds). When error != nil, bounds is meaningless. When error == nil, bounds is the value to save (nil or Bounds).
    private func validate() -> (error: Error?, bounds: Bounds?) {
        guard segmentControl.selectedSegmentIndex != 0 else {
            return (nil, nil)
        }
        let values = boundsTextFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        guard values.count >= 4 else { return (BoundsValidationError.missingFields, nil) }
        guard values.allSatisfy({ !$0.isEmpty }) else { return (BoundsValidationError.missingFields, nil) }
        let fields = ["maxLat", "maxLon", "minLat", "minLon"]
        var parsed: [Double] = []
        parsed.reserveCapacity(4)
        for (idx, field) in fields.enumerated() {
            guard let v = Double(values[idx]) else {
                return (BoundsValidationError.invalidNumber(field: field), nil)
            }
            parsed.append(v)
        }
        let bounds = Bounds(maxLat: parsed[0], maxLon: parsed[1], minLat: parsed[2], minLon: parsed[3])
        return (nil, bounds)
    }

    @objc private func segmentChanged() {
        boundsFieldsContainer?.isHidden = (segmentControl.selectedSegmentIndex == 0)
    }

    private func selectorRowView() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = "InitialBounds :"
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

    private func boundsInputFieldsView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.alignment = .fill
        boundsTextFields = []
        for placeholder in ["maxLat", "maxLon", "minLat", "minLon"] {
            let field = UITextField()
            field.placeholder = placeholder
            field.borderStyle = .roundedRect
            field.font = .systemFont(ofSize: 15)
            field.keyboardType = .decimalPad
            field.autocorrectionType = .no
            field.delegate = self
            container.addArrangedSubview(field)
            boundsTextFields.append(field)
        }
        return container
    }

    private func formatNumber(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let proposed = (current as NSString).replacingCharacters(in: range, with: string)
        if proposed.isEmpty { return true }
        let decimalCount = proposed.filter { $0 == "." }.count
        guard decimalCount <= 1 else { return false }
        return proposed.allSatisfy { $0.isNumber || $0 == "." }
    }
}
