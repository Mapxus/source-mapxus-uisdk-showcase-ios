//
//  MapLabelsConfigViewController.swift
//  UISDKKmpSample
//
//  mapLabelsConfig 功能详情页
//  Name: mapLabelsConfig
//  Type: MapLabelsConfig?
//  Default: null
//  Description: Configuration for controlling map labels visibility behavior. When null, map labels follow default visibility settings.
//

import UIKit
import SnapKit
import DropInUISDK

final class MapLabelsConfigViewController: BaseFeatureViewController {

    // MARK: - Root
    private let rootSegment = UISegmentedControl(items: ["nil", "MapLabelsConfig"])
    private var mapLabelsContainer: UIStackView?

    // MARK: - buildingPins
    private let buildingPinsSegment = UISegmentedControl(items: ["nil", "PinVisibilityConfig"])
    private var pinVisibilityContainer: UIStackView?

    // MARK: - PinVisibilityConfig fields
    private let fallbackVisibilitySegment = UISegmentedControl(items: ["true", "false"])
    private let pagesVisibilitySegment = UISegmentedControl(items: ["nil", "PagesVisibilityOverride"])
    private var pagesVisibilityContainer: UIStackView?

    // MARK: - PagesVisibilityOverride fields
    private let navigationPageSegment = UISegmentedControl(items: ["nil", "true", "false"])

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

        addDescriptionContent(to: content)
        addParameterSection(to: content, views: buildParameterView())

        restoreCurrentValue()

        rootSegment.addTarget(self, action: #selector(rootSegmentChanged), for: .valueChanged)
        buildingPinsSegment.addTarget(self, action: #selector(buildingPinsSegmentChanged), for: .valueChanged)
        pagesVisibilitySegment.addTarget(self, action: #selector(pagesVisibilitySegmentChanged), for: .valueChanged)
    }

    // MARK: - Build UI

    private func buildParameterView() -> UIView {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 10

        outer.addArrangedSubview(makeLabel("mapLabelsConfig :"))
        outer.addArrangedSubview(rootSegment)

        // --- MapLabelsConfig container ---
        let mlStack = UIStackView()
        mlStack.axis = .vertical
        mlStack.spacing = 10
        mapLabelsContainer = mlStack
        mlStack.isHidden = true

        mlStack.addArrangedSubview(makeThinSeparator())
        mlStack.addArrangedSubview(makeLabel("buildingPins :"))
        mlStack.addArrangedSubview(buildingPinsSegment)

        // --- PinVisibilityConfig container ---
        let pvStack = UIStackView()
        pvStack.axis = .vertical
        pvStack.spacing = 10
        pinVisibilityContainer = pvStack
        pvStack.isHidden = true

        pvStack.addArrangedSubview(makeLabel("  fallbackVisibility : (required)"))
        pvStack.addArrangedSubview(fallbackVisibilitySegment)

        pvStack.addArrangedSubview(makeThinSeparator())
        pvStack.addArrangedSubview(makeLabel("  pagesVisibilityOverride :"))
        pvStack.addArrangedSubview(pagesVisibilitySegment)

        // --- PagesVisibilityOverride container ---
        let pageStack = UIStackView()
        pageStack.axis = .vertical
        pageStack.spacing = 10
        pagesVisibilityContainer = pageStack
        pageStack.isHidden = true

        pageStack.addArrangedSubview(makeLabel("    navigationPage :"))
        pageStack.addArrangedSubview(navigationPageSegment)

        pvStack.addArrangedSubview(pageStack)
        mlStack.addArrangedSubview(wrapInCard(pvStack))
        outer.addArrangedSubview(wrapInCard(mlStack))

        return outer
    }

    // MARK: - Segment Actions

    @objc private func rootSegmentChanged() {
        mapLabelsContainer?.isHidden = (rootSegment.selectedSegmentIndex == 0)
    }

    @objc private func buildingPinsSegmentChanged() {
        pinVisibilityContainer?.isHidden = (buildingPinsSegment.selectedSegmentIndex == 0)
    }

    @objc private func pagesVisibilitySegmentChanged() {
        pagesVisibilityContainer?.isHidden = (pagesVisibilitySegment.selectedSegmentIndex == 0)
    }

    // MARK: - Save

    override func saveBarButtonTapped() {
        let config: MapLabelsConfig?
        if rootSegment.selectedSegmentIndex == 0 {
            config = nil
        } else {
            let buildingPins: PinVisibilityConfig?
            if buildingPinsSegment.selectedSegmentIndex == 0 {
                buildingPins = nil
            } else {
                let fallback = fallbackVisibilitySegment.selectedSegmentIndex == 0
                let pagesOverride: PagesVisibilityOverride?
                if pagesVisibilitySegment.selectedSegmentIndex == 0 {
                    pagesOverride = nil
                } else {
                    let navPage: KotlinBoolean?
                    switch navigationPageSegment.selectedSegmentIndex {
                    case 1: navPage = KotlinBoolean(value: true)
                    case 2: navPage = KotlinBoolean(value: false)
                    default: navPage = nil
                    }
                    pagesOverride = PagesVisibilityOverride(navigationPage: navPage)
                }
                buildingPins = PinVisibilityConfig(fallbackVisibility: fallback, pagesVisibilityOverride: pagesOverride)
            }
            config = MapLabelsConfig(buildingPins: buildingPins)
        }
        Config.shared.diConfig.mapLabelsConfig = config
        Config.shared.saveChange([featureName: config as Any])
        super.saveBarButtonTapped()
    }

    // MARK: - Restore

    private func restoreCurrentValue() {
        guard let config = Config.shared.configValue(forKey: featureName) as? MapLabelsConfig else {
            rootSegment.selectedSegmentIndex = 0
            return
        }
        rootSegment.selectedSegmentIndex = 1
        mapLabelsContainer?.isHidden = false

        guard let buildingPins = config.buildingPins else {
            buildingPinsSegment.selectedSegmentIndex = 0
            return
        }
        buildingPinsSegment.selectedSegmentIndex = 1
        pinVisibilityContainer?.isHidden = false

        fallbackVisibilitySegment.selectedSegmentIndex = buildingPins.fallbackVisibility ? 0 : 1

        guard let pagesOverride = buildingPins.pagesVisibilityOverride else {
            pagesVisibilitySegment.selectedSegmentIndex = 0
            return
        }
        pagesVisibilitySegment.selectedSegmentIndex = 1
        pagesVisibilityContainer?.isHidden = false

        if let navPage = pagesOverride.navigationPage {
            navigationPageSegment.selectedSegmentIndex = navPage.boolValue ? 1 : 2
        } else {
            navigationPageSegment.selectedSegmentIndex = 0
        }
    }

    // MARK: - UI Helpers

    private func makeLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .label
        lbl.numberOfLines = 0
        return lbl
    }

    private func makeThinSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.snp.makeConstraints { $0.height.equalTo(1) }
        return v
    }

    private func wrapInCard(_ stack: UIStackView) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemBackground
        card.layer.cornerRadius = 8
        card.layer.masksToBounds = true
        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        return card
    }
}
