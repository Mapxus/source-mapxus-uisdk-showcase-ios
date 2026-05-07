# UISDKKmpSample

## Overview

`UISDKKmpSample` is a configuration-driven sample app for exploring and validating `DropInUISDK` features. It lets you pick a route, tweak config options, and attach a listener — then launch the SDK view to observe the result.

## Requirements

- iOS 15.6 or later
- Xcode 26+
- CocoaPods

## Setup

### 1. Install dependencies

```bash
pod install
```

### 2. Configure credentials

This project does not commit the API key or secret to Git. They are injected via `xcconfig`.

1. Copy `BuildConfig/Secrets.example.xcconfig` to `BuildConfig/Secrets.local.xcconfig`
2. Fill in your own `MAPXUS_API_KEY` and `MAPXUS_SECRET`

`BuildConfig/Secrets.local.xcconfig` is listed in `.gitignore` and should remain local only.

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
- [BuildConfig/Secrets.example.xcconfig](BuildConfig/Secrets.example.xcconfig)
