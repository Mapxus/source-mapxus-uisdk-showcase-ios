# DropInUISDK Usage Guide

## Overview

This document focuses on the current integration pattern for `DropInUISDK` in an iOS project, along with the runnable example provided in this repository.

`UISDKKmpSample` is used to demonstrate and validate the following capabilities:

1. SDK initialization and authentication
2. `DISdk` creation, presentation, and cleanup
3. `DIConfigBuilder` configuration injection
4. `AppRoute`-based page launching
5. Listener registration patterns

## Requirements

- iOS 15.6 or later
- Xcode 26+
- CocoaPods
- Ruby / Bundler

## Installation

### Install via CocoaPods

Add the dependency to your `Podfile`:

```ruby
source 'https://github.com/Mapxus/mapxusSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourAppName' do
	use_frameworks!

	pod 'DropInUISDK'
end
```

After cloning this repository, run the following command before opening the workspace:

```bash
bundle exec pod install
```

## Credentials Setup

This project does not commit the API key or secret to Git. Instead, they are injected through `xcconfig`.

1. Copy `BuildConfig/Secrets.example.xcconfig` to `BuildConfig/Secrets.local.xcconfig`
2. Fill in your own `MAPXUS_API_KEY` and `MAPXUS_SECRET`
3. Open the project with `UISDKKmpSample.xcworkspace`

`BuildConfig/Secrets.local.xcconfig` is already listed in `.gitignore` and should remain local only.

## Initialization

Before using `DropInUISDK`, you must register the Mapxus service. In this project, initialization is done in `SceneDelegate`, and the credentials are read from `Info.plist` values injected by the build configuration.

```swift
import MapxusBaseSDK

let services = MXMMapServices.shared()
services.delegate = self

let credentials = mapxusCredentials()
services.register(withApiKey: credentials.apiKey, secret: credentials.secret)
```

See [UISDKKmpSample/SceneDelegate.swift](UISDKKmpSample/SceneDelegate.swift) for the reference implementation.

## Create and Display the SDK View

This project uses the current API pattern: build a `DIConfig` first, then initialize `DISdk` with `DISdk(diConfig:)`.

```swift
private let sdk: DISdk

init() {
	self.sdk = DISdk(diConfig: Config.shared.diConfig.build())
	super.init(nibName: nil, bundle: nil)
}
```

Use `getView()` to obtain the SDK view and attach it to your page.

```swift
dropInView = sdk.getView()
guard let dropInView = dropInView else { return }

view.addSubview(dropInView)
dropInView.snp.makeConstraints { make in
	make.edges.equalToSuperview()
}
```

See [UISDKKmpSample/MapViewController.swift](UISDKKmpSample/MapViewController.swift) for the reference implementation.

## Start a Page

This project launches SDK pages with `start(route:)`.

```swift
sdk.start(route: Config.shared.appRoute)
```

This allows you to explicitly choose which business page to enter before launch, such as the landing page, venue detail page, POI detail page, or navigation page.

## DIConfig Setup

This project does not create `DIConfig` ad hoc in each page. Instead, it manages a shared `DIConfigBuilder` through `Config.shared.diConfig`, and calls `build()` only when entering the map page.

This pattern works well for dynamic configuration editing and is closer to a real-world flow where configuration is collected first and the SDK is launched afterward.

`Config.shared` mainly maintains three kinds of state:

- `diConfig`: the active `DIConfigBuilder`
- `appRoute`: the `AppRoute` to launch
- `listener`: the single listener currently selected for registration

See [UISDKKmpSample/Config.swift](UISDKKmpSample/Config.swift) for the implementation.

## AppRoute Usage

When the map page starts, it reads `Config.shared.appRoute` and passes it to `sdk.start(route:)`. The sample currently covers several common route types, including:

- `LandingPageRoute`
- `VenueDetailRoute`
- `BuildingDetailRoute`
- `PoiDetailRoute`
- `EventDetailRoute`
- `NavigationRoute`

Route-related definitions can be found in [UISDKKmpSample/FeatureConstants.swift](UISDKKmpSample/FeatureConstants.swift).

## Listener Usage

This project performs listener registration in `MapViewController`, selecting the registration method based on the current configuration before the page is displayed.

`DISdk` itself supports multiple listeners, but this sample app configures only one listener at a time so each listener behavior can be tested independently.

```swift
private func setupListener() {
		guard let listener = Config.shared.listener else { return }
		switch listener {
		case "setMapEventListener":
				sdk.setMapEventListener(listener: MapEventHandler())
		case "setNavigationEventListener":
				sdk.setNavigationEventListener(listener: NavigationEventHandler())
		case "setPoiEventListener":
				sdk.setPoiEventListener(listener: PoiEventHandler())
		default:
				break
		}
}
```

The sample currently covers these registration entry points:

- `setToolTipsListener`
- `setLandingPageEventListener`
- `setVenueEventListener`
- `setBuildingEventListener`
- `setPoiEventListener`
- `setCategorySearchEventListener`
- `setEventListener`
- `setKeywordSearchEventListener`
- `setMapEventListener`
- `setNavigationEventListener`
- `setRoutePlanningEventListener`
- `setShareEventListener`
- `setMenuEventListener`
- `setDataTrackingListener`

See [UISDKKmpSample/MapViewController.swift](UISDKKmpSample/MapViewController.swift) for the full implementation.

## Resource Cleanup

This project calls `cleanup()` when the page is being popped to release SDK resources.

```swift
override func viewWillDisappear(_ animated: Bool) {
	super.viewWillDisappear(animated)
	if isMovingFromParent {
		sdk.cleanup()
	}
}
```

If your page lifecycle matches this sample, this cleanup pattern is recommended.

## Sample App Structure

In addition to demonstrating SDK integration, this repository also provides a configuration-driven sample entry for quickly switching parameters and verifying behavior.

- `MainViewController`: displays the current configuration, route, and listener
- `CategoryListViewController`: organizes capability entries by category
- `FeatureListViewController`: shows the feature items under a category
- `BaseFeatureViewController` and subclasses: edit configuration and save changes
- `MapViewController`: creates and starts `DISdk`

If you only care about SDK integration, start with `SceneDelegate.swift`, `Config.swift`, and `MapViewController.swift`.

## Run the Sample

1. Set up the local credentials file
2. Open `UISDKKmpSample.xcworkspace`
3. Select the `UISDKKmpSample` scheme
4. Run the app

## Notes

1. You must configure `BuildConfig/Secrets.local.xcconfig` before launch, otherwise the app will stop immediately due to missing credentials.
2. `MapxusApiKey` and `MapxusSecret` in `Info.plist` are used to receive injected build configuration values and should not be removed.
3. This project uses `Config.shared` to manage runtime configuration state. Do not introduce another configuration singleton.
4. The sample currently registers only one listener at a time, and `MapViewController` is implemented around that assumption.
5. If you change Pods or build configuration files, always open the project through `UISDKKmpSample.xcworkspace`.

## Key Files

- [UISDKKmpSample/SceneDelegate.swift](UISDKKmpSample/SceneDelegate.swift)
- [UISDKKmpSample/MapViewController.swift](UISDKKmpSample/MapViewController.swift)
- [UISDKKmpSample/Config.swift](UISDKKmpSample/Config.swift)
- [UISDKKmpSample/FeatureConstants.swift](UISDKKmpSample/FeatureConstants.swift)
- [BuildConfig/Secrets.example.xcconfig](BuildConfig/Secrets.example.xcconfig)
