//
//  MapViewController.swift
//  UISDKKmpSample
//

import UIKit
import SnapKit
import DropInUISDK


final class MapViewController: UIViewController {
  private let sdk: DISdk
  private var dropInView: UIView?

  init() {
    self.sdk = DISdk(diConfig: Config.shared.diConfig.build())
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"
        view.backgroundColor = .systemBackground
        setupDropInView()
        setupListener()
        sdk.start(route: Config.shared.appRoute)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            sdk.cleanup()
        }
    }

    private func setupListener() {
        guard let listener = Config.shared.listener else { return }
        switch listener {
        case "setToolTipsListener":
            sdk.setToolTipsListener(listener: ToolTipsHandler())
        case "setLandingPageEventListener":
            sdk.setLandingPageEventListener(listener: LandingPageEventHandler())
        case "setVenueEventListener":
            sdk.setVenueEventListener(listener: VenueEventHandler())
        case "setBuildingEventListener":
            sdk.setBuildingEventListener(listener: BuildingEventHandler())
        case "setPoiEventListener":
            sdk.setPoiEventListener(listener: PoiEventHandler())
        case "setCategorySearchEventListener":
            sdk.setCategorySearchEventListener(listener: CategorySearchEventHandler())
        case "setEventListener":
            sdk.setEventListener(listener: EventHandler())
        case "setKeywordSearchEventListener":
            sdk.setKeywordSearchEventListener(listener: KeywordSearchEventHandler())
        case "setMapEventListener":
            sdk.setMapEventListener(listener: MapEventHandler())
        case "setNavigationEventListener":
            sdk.setNavigationEventListener(listener: NavigationEventHandler())
        case "setRoutePlanningEventListener":
            sdk.setRoutePlanningEventListener(listener: RoutePlanningEventHandler())
        case "setShareEventListener":
            sdk.setShareEventListener(listener: ShareEventHandler())
        case "setMenuEventListener":
            sdk.setMenuEventListener(listener: MenuEventHandler())
        case "setDataTrackingListener":
            sdk.setDataTrackingListener(listener: DataTrackingHandler())
        default:
            break
        }
    }
    
  func setupDropInView() {
    dropInView = sdk.getView()
    guard let dropInView = dropInView else { return }

    view.addSubview(dropInView)
    dropInView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

}
