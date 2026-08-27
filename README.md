# UISDKKmpSample

## Overview

`UISDKKmpSample` is a configuration-driven sample app for exploring and validating `DropInUISDK` features. It lets you pick a route, tweak config options, and attach a listener — then launch the SDK view to observe the result.

## Requirements

- iOS 15.6 or later
- Xcode 26+
- CocoaPods

## Setup

### 1. Configure credentials

Credentials are injected at build time through `BuildConfig/Config.example.xcconfig`,
which is the base configuration for the project. Open it and fill in:

- `PRODUCT_BUNDLE_IDENTIFIER`
- `INFOPLIST_KEY_CFBundleDisplayName`
- `MAPXUS_API_KEY`
- `MAPXUS_SECRET`

If you would rather keep your credentials out of the tracked file, copy it to
`BuildConfig/Config.<name>.xcconfig`, edit the copy, and point the build
configuration at it in **Project > Info > Configurations**. Files matching
`BuildConfig/Config.*.xcconfig` are ignored by Git.

### 2. Install dependencies

```bash
pod install
```

### 3. Open the workspace

Always open `UISDKKmpSample.xcworkspace`, not the `.xcodeproj`.

## Run

1. Select the `UISDKKmpSample` scheme
2. Build and run

## How the Sample App Works

The app is organized around three pieces of shared state managed by `Config.shared`:

- **`diConfig`** — a `DIConfigBuilder` you edit through the feature screens
- **`appRoute`** — the `AppRoute` to launch (e.g. landing page, venue detail, navigation)
- **`listener`** — the single event listener registered for the current run

### Navigation flow

1. **`MainViewController`** — shows the current config, route, and listener; tap "Start" to launch the map
2. **`CategoryListViewController`** — browse features organized by category
3. **`FeatureListViewController`** — pick a specific feature to configure
4. **Feature screens** (`BaseFeatureViewController` subclasses) — edit a config value or select a route/listener and save it back to `Config.shared`
5. **`MapViewController`** — creates `DISdk` with the current config, attaches the selected listener, and starts the chosen route

### Supported routes

- `LandingPageRoute`
- `VenueDetailRoute`
- `BuildingDetailRoute`
- `PoiDetailRoute`
- `EventDetailRoute`
- `NavigationRoute`

### Supported listeners

> **Note:** `DISdk` supports setting multiple listeners simultaneously, but this sample registers only one at a time so each listener's behavior can be tested in isolation.

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

## Key Files

- [UISDKKmpSample/SceneDelegate.swift](UISDKKmpSample/SceneDelegate.swift)
- [UISDKKmpSample/Config.swift](UISDKKmpSample/Config.swift)
- [UISDKKmpSample/MapViewController.swift](UISDKKmpSample/MapViewController.swift)
- [UISDKKmpSample/FeatureConstants.swift](UISDKKmpSample/FeatureConstants.swift)
- [BuildConfig/Config.example.xcconfig](BuildConfig/Config.example.xcconfig)
