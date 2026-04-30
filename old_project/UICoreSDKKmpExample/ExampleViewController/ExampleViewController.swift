//
//  ExampleViewController.swift
//  UICoreSDKKmpExample
//
//  Created by Mapxus on 2025/5/6.
//

import UIKit
import DropInUISDK
import MapxusBaseSDK
import AFNetworking


var statusBarHeight: CGFloat {
  let height: CGFloat
  if let window = UIApplication.shared.connectedScenes
    .compactMap({ $0 as? UIWindowScene })
    .flatMap({ $0.windows })
    .first(where: { $0.isKeyWindow }),
     let statusBarManager = window.windowScene?.statusBarManager {
    height = statusBarManager.statusBarFrame.height
  } else {
    height = 0
  }
  return height
}


class ExampleViewController: JYPageController
{
  private lazy var datas = ExampleV2Model.exampleDatas()
  
  private lazy var progressView = createProgressView()
  private lazy var nextBgView = createNextButtonView()
  private lazy var nextButton = createNextButton()
  
  private var reachabilityManager = NetworkMonitoring()
  
  private lazy var dropInColors = ConfigModel.normalTheme()     //主题色
  
  private var listenerList: [ExampleV2ItemType] = []
  private var poiDetailList: [PoiDetailSection] = []
    private lazy var diconfig = DIConfigBuilder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Example App", comment: "")
    view.backgroundColor = .white
    reachabilityManager.startMonitoring()
    diconfig.isVenueBackButtonVisible = true
    
    setupNavigationBar()
    configSubviews()
  }
  
  @objc func observeNetworkChanged(notification: Notification) {
    AFNetworkReachabilityManager.shared().stopMonitoring()
  }
  
  private func setupNavigationBar() {
    let searchButton = UIBarButtonItem(title: "搜索", style: .plain, target: self, action: #selector(goToSearcher))
    let apiKeyButton = UIBarButtonItem(title: "API密钥", style: .plain, target: self, action: #selector(goToAPIKeySelection))
    navigationItem.rightBarButtonItems = [apiKeyButton, searchButton]
  }
  
  @objc private func goToSearcher() {
    let searcherVC = SearcherViewController()
    navigationController?.pushViewController(searcherVC, animated: true)
  }
  
  @objc private func goToAPIKeySelection() {
    let apiKeyVC = APIKeySelectionViewController()
    navigationController?.pushViewController(apiKeyVC, animated: true)
  }
  
  @objc private func goToKotlin() {
      diconfig.globalFilterModes = [.search, .events, .tags, .settings]
    let vc = KotlinWebViewController(diConfig: diconfig.build(), listeners: listenerList)
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc func nextAction() {
    selectedIndex += 1
    if selectedIndex > datas.count - 1 {
      // push
      goToKotlin()
    } else {
      menuView.select(selectedIndex)
    }
  }
}


extension ExampleViewController {
  override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
    return .zero
  }
  
  override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
    var originY: CGFloat = 0
    if let navBar = navigationController?.navigationBar {
      let navBarHeight = navBar.frame.height
      originY = navBarHeight + statusBarHeight
    }
    return CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - originY)
  }
  
  override func numberOfChildControllers() -> Int {
    return datas.count
  }
  
  override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
    let m = datas[index]
    if index == 0 {
      return ExampleFirstPageController(exampleModel: m)
    }
    if m.type == .POIDetails || m.type == .Listener {
      return makeCheckboxController(for: m)
    }
    return makeParamController(for: m)
  }
  private func makeCheckboxController(for model: ExampleV2Model) -> ExampleCheckboxController {
    let vc = ExampleCheckboxController(exampleModel: model)
    vc.valueCallback = { [weak self] value in
      guard let self = self else { return }
      if model.type == .POIDetails {
        setPoiDetailChecked(value: value)
          diconfig.poiDetailSections = poiDetailList
      } else if model.type == .Listener {
        setListenerChecked(value: value)
      }
    }
    return vc
  }
  private func makeParamController(for model: ExampleV2Model) -> ExampleParamController {
    let vc = ExampleParamController(exampleModel: model)
    vc.valueCallback = { [weak self] value in
      guard let self = self else { return }
      switch model.type {
        case .Theme:
          self.handleTheme(value: value)
        case .Language:
          self.handleLanguage(value: value)
        case .ShareTypeDisplay:
          self.handleShareType(value: value)
        default:
          break
      }
    }
    return vc
  }
  private func handleTheme(value: Any?) {
    guard let theme = value as? MapStyle else { return }
    diconfig.mapStyle = theme.rawValue

    switch theme {
    case .Drop_in_ui_25d:
        diconfig.colors = ConfigModel.designSystem()
        diconfig.materialResourcePath = "default"
        diconfig.shapes = DIShapes(
          buttonShapeCornerSize: 8,
          imageShapeCornerSize: 4,
          searchBarShapeCornerSize: 10,
          bottomSheetShapeCornerSize: 16,
          popupCardShapeCornerSize: 16
        )
        diconfig.recommendedCategories = nil
        diconfig.mapBoundsRestriction = nil
    case .Drop_in_ui:
      diconfig.colors = ConfigModel.normalTheme()
      diconfig.materialResourcePath = "default"
      diconfig.shapes = DIShapes(
        buttonShapeCornerSize: 8,
        imageShapeCornerSize: 4,
        searchBarShapeCornerSize: 10,
        bottomSheetShapeCornerSize: 16,
        popupCardShapeCornerSize: 16
      )
      diconfig.recommendedCategories = nil
      diconfig.mapBoundsRestriction = nil
    case .Taikwun_v1:
      diconfig.colors = ConfigModel.darkTheme()
      diconfig.materialResourcePath = "taikwun"
      diconfig.floorSelectorCategories = [
        "facility.toilet_facility", "facility.restroom", "facility.mothersroom",
        "facility.baby_changing", "facility.wheelchair_assist", "facility.fire_extinguisher",
        "facility.parking", "restaurants", "shopping", "arts_entertainment"
      ]
      diconfig.recommendedCategories = ["facility.attractions"]
      diconfig.shapes = DIShapes(
        buttonShapeCornerSize: 0,
        imageShapeCornerSize: 0,
        searchBarShapeCornerSize: 0,
        bottomSheetShapeCornerSize: 0,
        popupCardShapeCornerSize: 0
      )
    }
  }
  private func handleLanguage(value: Any?) {
    switch value as? ShowCaseLanguage {
    case .English:
      diconfig.language = Language.english
    case .Simplified:
      diconfig.language = Language.simplifiedChinese
    case .Traditional:
      diconfig.language = Language.traditionalChineseHk
    case .Japanese:
      diconfig.language = Language.japanese
    case .System, .none:
      diconfig.language = Language.systemLanguage
    }
  }
  private func handleShareType(value: Any?) {
    switch value as? ShareTypeDisplay {
    case .None:
      diconfig.shareDisplayMode = .none
    case .InfoLocation:
      diconfig.shareDisplayMode = .infoLocation
    case .Both:
      diconfig.shareDisplayMode = .both
    case .none:
      diconfig.shareDisplayMode = .both
    }
  }

  override func pageController(_ pageController: JYPageController, didEnterControllerAt index: Int) {
    let d_count = datas.count
    let count = Float(d_count - 1) * 1.0
    let r = Float(index) / count
    progressView.setProgress(Float(r), animated: true)
    
    if index == 0 {
      nextButton.setTitle(NSLocalizedString("Set Parameters", comment: ""), for: .normal)
    } else if index == d_count - 1 {
      nextButton.setTitle(NSLocalizedString("Start", comment: ""), for: .normal)
    } else {
      nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
    }
    let model = datas[index]
    self.navigationItem.title = model.text
  }
}

extension ExampleViewController {
  
  private func createNextButtonView() -> UIView {
    let bottom = DeviceInfo.bottomSafeArea + 60
    let v = UIView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height - bottom), size: CGSize(width: view.frame.width, height: bottom)))
    v.backgroundColor = .white
    v.addSubview(nextButton)
    return v
  }
  
  private func createNextButton() -> UIButton {
    let b = UIButton(frame: CGRect(x: 24, y: 6, width: view.frame.width - 48, height: 48))
    b.backgroundColor = UIColor(red: 32 / 255.0, green: 115 / 255.0, blue: 236 / 255.0, alpha: 1)
    b.setTitleColor(.white, for: .normal)
    b.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    b.setTitle(NSLocalizedString("Set Parameters", comment: ""), for: .normal)
    b.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    b.layer.cornerRadius = 10
    
    return b
  }
  
  private func createProgressView() -> GradientProgressView {
    var originY: CGFloat = 0
    if let navBar = navigationController?.navigationBar {
      let navBarHeight = navBar.frame.height
      originY = navBarHeight + statusBarHeight
    }
    let v = GradientProgressView(frame: CGRect(x: 0, y: originY, width: view.frame.width, height: 4))
    v.progressCornerRadius = 0
    v.progressColors = [UIColor(red: 79 / 255.0, green: 139 / 255.0, blue: 255 / 255.0, alpha: 1)]
    v.backgroundColor = UIColor(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1)
    return v
  }
}


extension ExampleViewController {
  private func configSubviews() {
    view.backgroundColor = .white
    view.addSubview(progressView)
    view.addSubview(nextBgView)
    
  }
  
  private func makeButton(title: String, action: Selector) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 15
    button.titleLabel?.font = .systemFont(ofSize: 15)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
}

extension ExampleViewController
{
  private func setPoiDetailChecked(value: Any?) {
    guard let infos = value as? [[String: [Any]]] else {
      return
    }
    poiDetailList.removeAll()
    for info in infos {
      guard let item = info.values.first?.first as? ExampleV2ModelItem,
            let last = info.values.first?.last as? Bool, last == true else {
        continue
      }
      switch item.type {
      case .Address:
        poiDetailList.append(PoiDetailSection.address)
      case .OpenHours:
        poiDetailList.append(PoiDetailSection.openingHours)
      case .Phone:
        poiDetailList.append(PoiDetailSection.phone)
      case .Website:
        poiDetailList.append(PoiDetailSection.website)
      case .SpecialHours:
        poiDetailList.append(PoiDetailSection.specialHours)
      case .ServiceHours:
        poiDetailList.append(PoiDetailSection.serviceHours)
      case .Business:
        poiDetailList.append(PoiDetailSection.businessStatus)
      case .Email:
        poiDetailList.append(PoiDetailSection.email)
      default:
        break
      }
    }
  }
  
  func setListenerChecked(value: Any?) {
    guard let infos = value as? [[String: [Any]]] else {
      return
    }
    listenerList.removeAll()
    for info in infos {
      guard let item = info.values.first?.first as? ExampleV2ModelItem,
            let last = info.values.first?.last as? Bool, last == true else {
        continue
      }
      listenerList.append(item.type)
    }
  }
  
}


extension ExampleViewController: MXMServiceDelegate {
  func registerMXMServiceSuccess() {
    print("*** registerMXMServiceSuccess")
  }
  
  func registerMXMServiceFailWithError(_ error: Error) {
    print("*** registerMXMServiceSuccess = \(error)")
  }
}
