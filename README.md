# BetaWebKitScanner

BetaWebKitScanner is a SwiftUI iOS app. It expands an inclusive IPv4 range and requests `http://<address>` for each address, then lists the HTTP status code for each response.

The screen exists to show which addresses in that range return HTTP, and to filter the recorded lines to status 200 or to every other recorded status.

## Prerequisites

- A Mac with Xcode 14.2 or later. The project was created and last upgraded with Xcode 14.2 (`LastUpgradeCheck` 1420, compatibility version Xcode 14.0).
- The iOS 16.2 SDK or later. `IPHONEOS_DEPLOYMENT_TARGET` is 16.2.
- An iPhone or iPad destination. `TARGETED_DEVICE_FAMILY` is `1,2`.
- Swift 5.0, from `SWIFT_VERSION` on the app target.

The project does not use Swift Package Manager, CocoaPods, or Carthage. The sources import SwiftUI, Foundation (`URLSession`), and WebKit.

## Install, build, run, and test

Commands below are from the repository root.

Open the project in Xcode:

```bash
open BetaWebKitScanner/BetaWebKitScanner.xcodeproj
```

List targets and schemes:

```bash
xcodebuild -list -project BetaWebKitScanner/BetaWebKitScanner.xcodeproj
```

Build the Debug configuration for the iOS Simulator:

```bash
xcodebuild -project BetaWebKitScanner/BetaWebKitScanner.xcodeproj -scheme BetaWebKitScanner -destination 'generic/platform=iOS Simulator' -configuration Debug build
```

Build Release with the same command and `-configuration Release`. The project defines Debug and Release. The default configuration name is Release.

Run from Xcode on an iOS Simulator or a paired device: select the BetaWebKitScanner scheme and an iPhone or iPad destination, then choose Product > Run.

The repository does not include a shared scheme file under `xcshareddata/xcschemes`. The checked-in scheme state names `BetaWebKitScanner`. If `xcodebuild` reports that the scheme is missing, open the project in Xcode so it can create the scheme for the BetaWebKitScanner target, then run the build command again.

The Xcode project has one application target, `BetaWebKitScanner`, and no test target or test plan. There is no test command.

## Usage

1. Launch the app.
2. Edit **Lower IP** and **Upper IP**. The fields start as `1.1.1.1` and `255.255.255.255`.
3. Tap **Scan**.

Scan clears the result list, walks every IPv4 address from the lower bound through the upper bound in steps of 1, and starts `URLSession.shared.dataTask` for `http://<address>` on each address. When the response is an `HTTPURLResponse`, the list appends `<address>: <status code>`.

The segmented control filters that list:

- **All** shows every recorded line.
- **200** shows lines that end with `: 200`.
- **Not 200** shows recorded lines that do not end with `: 200`.

Transport errors and responses that are not HTTP add no line.

Each bound must be four decimal octets separated by `.`. The parser force-unwraps each octet. A missing octet or a non-integer octet traps. The comment in `ipv4StringToInt` notes an index-out-of-range trap when the address does not contain four sections.

The initial bounds cover a very large span. Scan starts one task per address and does not cap, delay, or cancel those tasks. Enter a narrow range before tapping Scan.

`WebView.swift` is part of the app target. It wraps `WKWebView`, loads `urlString`, and stores the HTTP status code from the navigation response. When that response is not HTTP it stores `404`. When provisional navigation fails it stores the `NSError` code. `ContentView` and `BetaWebKitScannerApp` do not reference `WebView`, so the running screen does not show it.

## Layout

```text
BetaWebKitScanner/
  BetaWebKitScanner.xcodeproj/    Xcode project
  BetaWebKitScanner/
    BetaWebKitScannerApp.swift    App entry, shows ContentView
    ContentView.swift             IP fields, Scan, filter, result list
    WebView.swift                 WKWebView wrapper, unused by the screen
    Assets.xcassets/              App icon and accent color
    Preview Content/              SwiftUI preview assets
```

The target marketing version is 1.0 and the project version is 1. The product name is BetaWebKitScanner.

## License

This repository has no LICENSE file.
