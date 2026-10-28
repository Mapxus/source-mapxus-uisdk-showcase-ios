import UIKit
import SnapKit
import DropInUISDK

final class RouteRenderModeViewController: BaseFeatureViewController {

    private let segmentControl = UISegmentedControl(items: ["Default", "Custom"])
    private let modeControl = UISegmentedControl()
    private let modes = Array(RouteRenderMode.allCases)

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

        for (index, mode) in modes.enumerated() {
            modeControl.insertSegment(withTitle: mode.name, at: index, animated: false)
        }
        addParameterSection(to: content, views: selectorRowView(), modeControl)

        let current = Config.shared.diConfig.routeRenderMode
        let defaultMode = Config.shared.diConfigDefault.routeRenderMode
        segmentControl.selectedSegmentIndex = current == defaultMode ? 0 : 1
        modeControl.selectedSegmentIndex = modes.firstIndex(of: current) ?? UISegmentedControl.noSegment
        updateModeControl()
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func saveBarButtonTapped() {
        let value: RouteRenderMode
        if segmentControl.selectedSegmentIndex == 0 {
            value = Config.shared.diConfigDefault.routeRenderMode
        } else {
            let index = modeControl.selectedSegmentIndex
            guard modes.indices.contains(index) else { return }
            value = modes[index]
        }
        Config.shared.diConfig.routeRenderMode = value
        Config.shared.saveChange([featureName: value])
        super.saveBarButtonTapped()
    }

    @objc private func segmentChanged() {
        if segmentControl.selectedSegmentIndex == 0 {
            modeControl.selectedSegmentIndex = modes.firstIndex(of: Config.shared.diConfigDefault.routeRenderMode)
                ?? UISegmentedControl.noSegment
        }
        updateModeControl()
    }

    private func updateModeControl() {
        let isCustom = segmentControl.selectedSegmentIndex == 1
        modeControl.isEnabled = isCustom
        modeControl.alpha = isCustom ? 1.0 : 0.4
    }

    private func selectorRowView() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 10
        container.alignment = .fill

        let label = UILabel()
        label.text = "routeRenderMode :"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        container.addArrangedSubview(label)
        container.addArrangedSubview(segmentControl)
        return container
    }
}