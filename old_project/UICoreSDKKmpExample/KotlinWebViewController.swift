//
//  ViewController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/4/9.
//

import UIKit
import DropInUISDK



final class KotlinWebViewController: UIViewController {
    // MARK: - Properties
    private let diConfig: DIConfig
    private let sdk: DISdk
    private var dropInView: UIView?
    private var listeners: [ExampleV2ItemType] = []
    
    // Handler instances
    private lazy var toolTipsHandler = ToolTipsHandler()
    private lazy var landingHandler = LandingPageHandler()
    private lazy var venueHandler = VenueHandler()
    private lazy var buildingHandler = BuildingHandler()
    private lazy var poiHandler = PoiHandler()
    private lazy var categroyHandler = CategroySearchHandler()
    private lazy var searchHandler = KeywordSearchHandler()
    private lazy var eventHandler = EventHandler()
    private lazy var mapHandler = MapHandler()
    private lazy var navigationHandler = NavigationHandler()
    private lazy var routeHandler = RoutePlanningHandler()
    private lazy var shareHandler = ShareHandler()
    private lazy var menuHandler = MenuHandler()
    private lazy var dataTrackingHandler = DataTrackingHandler()
    
    
    private enum Constants {
        static let defaultVenueIds = [
            "3cd9b17d-f3f4-4afd-ba34-5e3fad2518a6",
            "ff9cf333fbea41dc9545c62261312d5c",
            "e679b6fc0818456aa1867aa021a3e84a",
            "06d7e41af5154838a8d6ddda7d10cb0a",
            "00752cce7b3d43eb96a72a566fe2f4f3",
            "caab5a38-79e1-11e8-8453-951df499024d",
            "d76ee96d15294c79bdd5c479c20a0151",
            "8423acf2a7594a989f272f479f866cfa"
        ]
    }
    
    // MARK: - Initialization
    init(diConfig: DIConfig, listeners: [ExampleV2ItemType] = []) {
        //        let builder = DIConfigBuilder()
        //        builder.globalFilterModes = [.search, .events, .settings]
        //        builder.venueAnchorPoiConfigs = [
        //            VenueAnchorPoiConfig(venueId: "2584df52d9b441168d46ffe8ef43a2b3", poiIds: ["12188690", "12188579", "12188680", "12186750", "12186033", "12186694", "12289917", "12289920", "12289720", "12289819", "12298958", "12186923"]),
        //            VenueAnchorPoiConfig(venueId: "1be1f7a157ee4398bf9ce94460615f36", poiIds: ["11363565", "11363585", "11362940", "11363509", "11358675", "11359938", "11359796", "11358197", "11358779", "11359294", "11358753", "11359927"]),
        //            VenueAnchorPoiConfig(venueId: "60cc7a21f73a4b478e3ca08351dd7812", poiIds: ["12045340", "12045333", "12045349", "12033626", "12033533", "12384749", "12384740"]),
        //        ]
        //        builder.appearanceMode = .dark
        self.diConfig = diConfig
        self.listeners = listeners
        self.sdk = DISdk(diConfig: diConfig)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupDropInView()
        startSDK()
        setListener()
    }
    
    // MARK: - Actions
    @objc private func backAction() {
        sdk.cleanup()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Setup Methods
private extension KotlinWebViewController {
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(backAction)
        )
    }
    
    func setupDropInView() {
        dropInView = sdk.getView()
        guard let dropInView = dropInView else { return }
        
        dropInView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dropInView)
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            dropInView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            dropInView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            dropInView.topAnchor.constraint(equalTo: guide.topAnchor),
            dropInView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func startSDK() {
        let route = LandingPageRoute(venueIds: Constants.defaultVenueIds)
        sdk.start(route: route)
    }
}

// MARK: - Listener Management
private extension KotlinWebViewController {
    func setListener() {
        removeAllListeners()
        
        for type in listeners {
            switch type {
            case .ToolTips: sdk.setToolTipsListener(listener: toolTipsHandler)
            case .LandingPage: sdk.setLandingPageEventListener(listener: landingHandler)
            case .VenuePage: sdk.setVenueEventListener(listener: venueHandler)
            case .BuildingPage: sdk.setBuildingEventListener(listener: buildingHandler)
            case .PoiPage: sdk.setPoiEventListener(listener: poiHandler)
            case .CategoryPage: sdk.setCategorySearchEventListener(listener: categroyHandler)
            case .KeywordSearchPage: sdk.setKeywordSearchEventListener(listener: searchHandler)
            case .EventPage: sdk.setEventListener(listener: eventHandler)
            case .Map: sdk.setMapEventListener(listener: mapHandler)
            case .Navigation: sdk.setNavigationEventListener(listener: navigationHandler)
            case .RoutePlanning: sdk.setRoutePlanningEventListener(listener: routeHandler)
            case .SharePage: sdk.setShareEventListener(listener: shareHandler)
            case .Menu: sdk.setMenuEventListener(listener: menuHandler)
            case .DataTracking: sdk.setDataTrackingListener(listener: dataTrackingHandler)
            default: break
            }
        }
    }
    
    func removeAllListeners() {
        sdk.setToolTipsListener(listener: nil)
        sdk.setLandingPageEventListener(listener: nil)
        sdk.setVenueEventListener(listener: nil)
        sdk.setBuildingEventListener(listener: nil)
        sdk.setPoiEventListener(listener: nil)
        sdk.setCategorySearchEventListener(listener: nil)
        sdk.setEventListener(listener: nil)
        sdk.setKeywordSearchEventListener(listener: nil)
        sdk.setMapEventListener(listener: nil)
        sdk.setNavigationEventListener(listener: nil)
        sdk.setRoutePlanningEventListener(listener: nil)
        sdk.setShareEventListener(listener: nil)
        sdk.setMenuEventListener(listener: nil)
        sdk.setDataTrackingListener(listener: nil)
    }
}
