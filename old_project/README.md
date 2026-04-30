


          
# DropInUISDK 使用文档

## 简介

DropInUISDK 是 Mapxus 提供的一个 iOS SDK，用于在应用中快速集成室内地图、导航、搜索等功能。该 SDK 采用了 Kotlin Multiplatform (KMP) 技术，可以在 iOS 平台上使用。

## 安装要求

- iOS 13.0 及以上
- Xcode 最新版本
- CocoaPods

## 安装方法

### 通过 CocoaPods 安装

在项目的 Podfile 中添加以下内容：

```ruby
source 'https://github.com/Mapxus/mapxusSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourAppName' do
  use_frameworks!
  
  pod 'DropInUISDK', '5.0.0'
end
```

然后在终端中执行：

```bash
pod install
```

## 初始化

在使用 DropInUISDK 之前，需要先进行初始化和认证。通常在 `SceneDelegate.swift` 的 `scene(_:willConnectTo:options:)` 方法中进行：

```swift
import MapxusBaseSDK

// 在 SceneDelegate 中
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // ... existing code ...
    
    let services = MXMMapServices.shared()
    services.register(withApiKey: "YOUR_APP_ID", secret: "YOUR_APP_SECRET")
    
    // ... existing code ...
}
```

## 添加 DropInUISDK 视图

### 创建和添加视图

DropInUISDK 提供了一个简单的方法来生成和添加视图到您的 ViewController 中：

```swift
import UIKit
import DropInUISDK

class YourViewController: UIViewController {
    private lazy var sdk: DISdk = DISdk()
    private var dropInView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建配置对象
        let config = DIConfig(/* 配置参数 */)
        
        // 生成视图
        dropInView = sdk.generateView(diConfig: config)
        
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
    
    // 在视图控制器销毁时清理资源
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            sdk.destroyWebView()
        }
    }
}
```

### DIConfig 配置

`DIConfig` 是用于配置 DropInUISDK 视图的类，可以设置各种参数：

```swift
// 创建配置对象
let config = DIConfig()
config.setLanguage("zh") // 设置语言，支持 "zh"、"en" 等
config.setTheme("light") // 设置主题，支持 "light"、"dark"
config.setInitialPage("map") // 设置初始页面，如 "map"、"search" 等

// 生成视图
dropInView = sdk.generateView(diConfig: config)
```

## 主要功能

### 设置事件监听器

DropInUISDK 提供了多种事件监听器，用于处理不同页面和功能的事件：

```swift
// 创建各种事件处理器
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

// 设置事件监听器
func setListener() {
    // 设置登陆页面事件监听器
    sdk.setLandingPageEventListener(listener: landingHandler)
    
    // 设置场馆页面事件监听器
    sdk.setVenueEventListener(listener: venueHandler)
    
    // 设置建筑物页面事件监听器
    sdk.setBuildingEventListener(listener: buildingHandler)
    
    // 设置POI页面事件监听器
    sdk.setPoiEventListener(listener: poiHandler)
    
    // 设置分类搜索事件监听器
    sdk.setCategorySearchEventListener(listener: categroyHandler)
    
    // 设置关键词搜索事件监听器
    sdk.setKeywordSearchEventListener(listener: searchHandler)
    
    // 设置事件页面监听器
    sdk.setEventListener(listener: eventHandler)
    
    // 设置地图事件监听器
    sdk.setMapEventListener(listener: mapHandler)
    
    // 设置导航事件监听器
    sdk.setNavigationEventListener(listener: navigationHandler)
    
    // 设置路径规划事件监听器
    sdk.setRoutePlanningEventListener(listener: routeHandler)
    
    // 设置分享事件监听器
    sdk.setShareEventListener(listener: shareHandler)
}

// 移除所有监听器
func removeAllListener() {
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
}
```

### 资源清理

当不再需要 DropInUISDK 视图时，应该调用 `destroyWebView()` 方法来释放资源：

```swift
// 例如，在返回按钮的点击事件中
@objc func backAction() {
    sdk.destroyWebView()
    navigationController?.popViewController(animated: true)
}
```

## 事件处理器示例

### 地图事件处理器

```swift
class MapHandler: MapEventListener {
    // 建筑物点击事件
    func onBuildingClick(buildingId: String) {
        // 处理建筑物点击事件
    }
    
    // POI 点击事件
    func onPoiClick(poiId: String) {
        // 处理 POI 点击事件
    }
    
    // 位置点击事件
    func onLocationClick(location: Coordinate) {
        // 处理位置点击事件，location 包含 lat 和 lon 属性
    }
    
    // 场馆点击事件
    func onVenueClick(venueId: String) {
        // 处理场馆点击事件
    }
    
    // 事件点击事件
    func onEventClick(eventId: String) {
        // 处理事件点击事件
    }
    
    // 是否使用自定义建筑物页面
    func useCustomBuildingPage() -> Bool {
        return true // 返回 true 表示使用自定义页面
    }
    
    // 是否使用自定义事件页面
    func useCustomEventPage() -> Bool {
        return true
    }
    
    // 是否使用自定义位置页面
    func useCustomLocationPage() -> Bool {
        return true
    }
    
    // 是否使用自定义 POI 页面
    func useCustomPoi() -> Bool {
        return true
    }
    
    // 是否使用自定义场馆页面
    func useCustomVenuePage() -> Bool {
        return true
    }
}
```

### 路径规划事件处理器

```swift
class RoutePlanningHandler: RoutePlanningEventListener {
    // 是否使用自定义关闭按钮
    func useCustomClose() -> Bool {
        return true
    }
    
    // 关闭事件处理
    func onClose(param: Any?) {
        // 处理关闭事件
    }
}
```

## 完整示例

以下是一个完整的示例，展示了如何在视图控制器中使用 DropInUISDK：

```swift
import UIKit
import DropInUISDK

class ExampleViewController: UIViewController {
    private lazy var sdk: DISdk = DISdk()
    private var dropInView: UIView? = nil
    
    private lazy var mapHandler = MapHandler()
    private lazy var routeHandler = RoutePlanningHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色
        view.backgroundColor = .white
        
        // 添加返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backAction))
        
        // 创建配置
        let config = DIConfig()
        config.setLanguage("zh")
        config.setTheme("light")
        
        // 生成并添加视图
        dropInView = sdk.generateView(diConfig: config)
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
        
        // 设置事件监听器
        sdk.setMapEventListener(listener: mapHandler)
        sdk.setRoutePlanningEventListener(listener: routeHandler)
    }
    
    @objc func backAction() {
        sdk.destroyWebView()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            sdk.destroyWebView()
        }
    }
}
```

## 注意事项

1. 使用 SDK 前必须先调用 `MXMMapServices.shared().register(withApiKey: "YOUR_APP_ID", secret: "YOUR_APP_SECRET")` 进行初始化和认证
2. 确保在 Info.plist 中添加了必要的权限，如位置权限
3. 在视图控制器销毁前调用 `destroyWebView()` 释放资源
4. 根据需要设置适当的事件监听器来处理用户交互

## 技术支持

如有任何问题，请联系 Mapxus 技术支持团队。
