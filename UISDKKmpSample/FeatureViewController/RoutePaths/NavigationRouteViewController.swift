//
//  NavigationRouteViewController.swift
//  UISDKKmpSample
//
//  NavigationRoute feature detail page
//  Name: NavigationRoute
//  Type: AppRoute
//

import UIKit
import SnapKit
import DropInUISDK

final class NavigationRouteViewController: BaseFeatureViewController {

    // MARK: - Start Point

    private enum StartPointMode: Int, CaseIterable {
        case nilValue, currentLocation, geo
        var title: String {
            switch self {
            case .nilValue: return "nil"
            case .currentLocation: return "CurrentLocation"
            case .geo: return "Geo"
            }
        }
    }

    private let startTypeSegment = UISegmentedControl(items: StartPointMode.allCases.map { $0.title })
    private weak var startGeoContainer: UIView?

    private let startLatField = makeTextField(placeholder: "latitude")
    private let startLngField = makeTextField(placeholder: "longitude")
    private let startFloorTypeSegment = UISegmentedControl(items: ["none", "floorId", "sharedFloorId"])
    private let startFloorField = makeTextField(placeholder: "floorId / sharedFloorId")

    // MARK: - Destination Point

    private enum DestinationPointMode: Int, CaseIterable {
        case nilValue, geo, poi
        var title: String {
            switch self {
            case .nilValue: return "nil"
            case .geo: return "Geo"
            case .poi: return "Poi"
            }
        }
    }

    private let destTypeSegment = UISegmentedControl(items: DestinationPointMode.allCases.map { $0.title })
    private weak var destGeoContainer: UIView?
    private weak var destPoiContainer: UIView?

    private let destLatField = makeTextField(placeholder: "latitude")
    private let destLngField = makeTextField(placeholder: "longitude")
    private let destFloorTypeSegment = UISegmentedControl(items: ["none", "floorId", "sharedFloorId"])
    private let destFloorField = makeTextField(placeholder: "floorId / sharedFloorId")
    private let destPoiIdField = makeTextField(placeholder: "poiId")

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
        addParameterSection(to: content, views: buildStartPointSection(), buildDestinationPointSection())

        startTypeSegment.selectedSegmentIndex = 0
        destTypeSegment.selectedSegmentIndex = 0
        startFloorTypeSegment.selectedSegmentIndex = 0
        destFloorTypeSegment.selectedSegmentIndex = 0

        startTypeSegment.addTarget(self, action: #selector(startTypeChanged), for: .valueChanged)
        destTypeSegment.addTarget(self, action: #selector(destTypeChanged), for: .valueChanged)
        startFloorTypeSegment.addTarget(self, action: #selector(startFloorTypeChanged), for: .valueChanged)
        destFloorTypeSegment.addTarget(self, action: #selector(destFloorTypeChanged), for: .valueChanged)

        updateStartVisibility()
        updateDestVisibility()
    }

    override func saveBarButtonTapped() {
        let route = parseRoute()
        Config.shared.appRoute = route
        Config.shared.saveRouteChange([featureName: route])
        super.saveBarButtonTapped()
    }

    func parseRoute() -> NavigationRoute {
        NavigationRoute(startPoint: parseStartPoint(), destinationPoint: parseDestinationPoint())
    }

    // MARK: - Parse

    private func parseStartPoint() -> StartPoint? {
        switch StartPointMode(rawValue: startTypeSegment.selectedSegmentIndex) {
        case .nilValue, nil: return nil
        case .currentLocation: return CurrentLocationStartPoint()
        case .geo:
            guard let lat = Double(startLatField.text ?? ""),
                  let lng = Double(startLngField.text ?? "") else { return nil }
            switch startFloorTypeSegment.selectedSegmentIndex {
            case 1:
                let floorId = (startFloorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return floorId.isEmpty ? GeoStartPoint.companion.createWith(latitude: lat, longitude: lng)
                    : GeoStartPoint.companion.createWithFloor(latitude: lat, longitude: lng, floorId: floorId)
            case 2:
                let sharedFloorId = (startFloorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return sharedFloorId.isEmpty ? GeoStartPoint.companion.createWith(latitude: lat, longitude: lng)
                    : GeoStartPoint.companion.createWithSharedFloor(latitude: lat, longitude: lng, sharedFloorId: sharedFloorId)
            default:
                return GeoStartPoint.companion.createWith(latitude: lat, longitude: lng)
            }
        }
    }

    private func parseDestinationPoint() -> DestinationPoint? {
        switch DestinationPointMode(rawValue: destTypeSegment.selectedSegmentIndex) {
        case .nilValue, nil: return nil
        case .geo:
            guard let lat = Double(destLatField.text ?? ""),
                  let lng = Double(destLngField.text ?? "") else { return nil }
            switch destFloorTypeSegment.selectedSegmentIndex {
            case 1:
                let floorId = (destFloorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return floorId.isEmpty ? GeoDestinationPoint.companion.createWith(latitude: lat, longitude: lng)
                    : GeoDestinationPoint.companion.createWithFloor(latitude: lat, longitude: lng, floorId: floorId)
            case 2:
                let sharedFloorId = (destFloorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return sharedFloorId.isEmpty ? GeoDestinationPoint.companion.createWith(latitude: lat, longitude: lng)
                    : GeoDestinationPoint.companion.createWithSharedFloor(latitude: lat, longitude: lng, sharedFloorId: sharedFloorId)
            default:
                return GeoDestinationPoint.companion.createWith(latitude: lat, longitude: lng)
            }
        case .poi:
            let poiId = (destPoiIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !poiId.isEmpty else { return nil }
            return PoiDestinationPoint.companion.createWith(poiId: poiId)
        }
    }

    // MARK: - Visibility

    @objc private func startTypeChanged() { updateStartVisibility() }
    @objc private func destTypeChanged() { updateDestVisibility() }
    @objc private func startFloorTypeChanged() { updateStartFloorVisibility() }
    @objc private func destFloorTypeChanged() { updateDestFloorVisibility() }

    private func updateStartVisibility() {
        let mode = StartPointMode(rawValue: startTypeSegment.selectedSegmentIndex)
        startGeoContainer?.isHidden = mode != .geo
    }

    private func updateDestVisibility() {
        let mode = DestinationPointMode(rawValue: destTypeSegment.selectedSegmentIndex)
        destGeoContainer?.isHidden = mode != .geo
        destPoiContainer?.isHidden = mode != .poi
    }

    private func updateStartFloorVisibility() {
        startFloorField.isHidden = startFloorTypeSegment.selectedSegmentIndex == 0
    }

    private func updateDestFloorVisibility() {
        destFloorField.isHidden = destFloorTypeSegment.selectedSegmentIndex == 0
    }

    // MARK: - UI builders

    private func buildStartPointSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        let titleLabel = sectionTitleLabel("startPoint")
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(startTypeSegment)

        let geoContainer = UIStackView()
        geoContainer.axis = .vertical
        geoContainer.spacing = 8
        geoContainer.alignment = .fill
        geoContainer.isHidden = true
        startGeoContainer = geoContainer

        geoContainer.addArrangedSubview(startLatField)
        geoContainer.addArrangedSubview(startLngField)

        let floorRow = UIStackView()
        floorRow.axis = .vertical
        floorRow.spacing = 6
        floorRow.addArrangedSubview(startFloorTypeSegment)
        startFloorField.isHidden = true
        floorRow.addArrangedSubview(startFloorField)
        geoContainer.addArrangedSubview(floorRow)

        stack.addArrangedSubview(geoContainer)
        return stack
    }

    private func buildDestinationPointSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        let titleLabel = sectionTitleLabel("destinationPoint")
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(destTypeSegment)

        let geoContainer = UIStackView()
        geoContainer.axis = .vertical
        geoContainer.spacing = 8
        geoContainer.alignment = .fill
        geoContainer.isHidden = true
        destGeoContainer = geoContainer

        geoContainer.addArrangedSubview(destLatField)
        geoContainer.addArrangedSubview(destLngField)

        let floorRow = UIStackView()
        floorRow.axis = .vertical
        floorRow.spacing = 6
        floorRow.addArrangedSubview(destFloorTypeSegment)
        destFloorField.isHidden = true
        floorRow.addArrangedSubview(destFloorField)
        geoContainer.addArrangedSubview(floorRow)

        stack.addArrangedSubview(geoContainer)

        let poiContainer = UIStackView()
        poiContainer.axis = .vertical
        poiContainer.spacing = 8
        poiContainer.isHidden = true
        destPoiContainer = poiContainer
        poiContainer.addArrangedSubview(destPoiIdField)

        stack.addArrangedSubview(poiContainer)
        return stack
    }

    private func sectionTitleLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        return l
    }

    private static func makeTextField(placeholder: String) -> UITextField {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.placeholder = placeholder
        t.autocorrectionType = .no
        t.autocapitalizationType = .none
        t.keyboardType = .decimalPad
        return t
    }
}

// top-level helper for stored property default values
private func makeTextField(placeholder: String) -> UITextField {
    let t = UITextField()
    t.borderStyle = .roundedRect
    t.placeholder = placeholder
    t.autocorrectionType = .no
    t.autocapitalizationType = .none
    t.keyboardType = .decimalPad
    return t
}
