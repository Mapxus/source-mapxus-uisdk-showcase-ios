import UIKit
import SnapKit
import DropInUISDK

final class LocationRouteViewController: BaseFeatureViewController {

    private let latitudeField = makeTextField(placeholder: "latitude", keyboardType: .numbersAndPunctuation)
    private let longitudeField = makeTextField(placeholder: "longitude", keyboardType: .numbersAndPunctuation)
    private let floorTypeSegment = UISegmentedControl(items: ["none", "floorId", "sharedFloorId"])
    private let floorField = makeTextField(placeholder: "floorId", keyboardType: .default)

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
        scrollView.keyboardDismissMode = .onDrag
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

        addFunctionDescriptionContent(to: content)
        addParameterSection(to: content, views: buildLocationSection())

        floorTypeSegment.selectedSegmentIndex = 0
        floorTypeSegment.addTarget(self, action: #selector(floorTypeChanged), for: .valueChanged)
        floorTypeChanged()
    }

    override func saveBarButtonTapped() {
        guard let latitude = Double((latitudeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)),
              latitude.isFinite, (-90.0...90.0).contains(latitude),
              let longitude = Double((longitudeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)),
              longitude.isFinite, (-180.0...180.0).contains(longitude) else {
            showValidationError("Enter a latitude from -90 to 90 and a longitude from -180 to 180.")
            return
        }

        let location: Location
        switch floorTypeSegment.selectedSegmentIndex {
        case 1, 2:
            let floorId = (floorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !floorId.isEmpty else {
                showValidationError(floorTypeSegment.selectedSegmentIndex == 1
                    ? "Enter a floorId." : "Enter a sharedFloorId.")
                return
            }
            if floorTypeSegment.selectedSegmentIndex == 1 {
                location = IndoorLocation.companion.createWithFloor(
                    latitude: latitude, longitude: longitude, floorId: floorId
                )
            } else {
                location = IndoorLocation.companion.createWithSharedFloor(
                    latitude: latitude, longitude: longitude, sharedFloorId: floorId
                )
            }
        default:
            location = OutdoorLocation.companion.createWith(latitude: latitude, longitude: longitude)
        }

        let route = LocationRoute(location: location)
        Config.shared.appRoute = route
        Config.shared.saveRouteChange([featureName: route])
        super.saveBarButtonTapped()
    }

    @objc private func floorTypeChanged() {
        floorField.isHidden = floorTypeSegment.selectedSegmentIndex == 0
        floorField.placeholder = floorTypeSegment.selectedSegmentIndex == 2 ? "sharedFloorId" : "floorId"
    }

    private func buildLocationSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        let label = UILabel()
        label.text = "location"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(latitudeField)
        stack.addArrangedSubview(longitudeField)
        stack.addArrangedSubview(floorTypeSegment)
        stack.addArrangedSubview(floorField)
        return stack
    }

    private func showValidationError(_ message: String) {
        let alert = UIAlertController(title: "Invalid Location", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private static func makeTextField(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = placeholder
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = keyboardType
        return field
    }
}