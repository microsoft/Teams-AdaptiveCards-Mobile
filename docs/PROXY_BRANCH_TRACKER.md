# Proxy Branch Tracker

## Branch: `proxy/integration`

**Purpose:** Agent validation gate for the production AdaptiveCards-Mobile SDK.  
**Fork:** `hggzm/Teams-AdaptiveCards-Mobile` (fork of `microsoft/Teams-AdaptiveCards-Mobile`)  
**Created from:** `upstream/main` at commit `2db8482b` (Merge PR #503 - v3.8.1)

---

## Gate Status

| Run | Conclusion | Commit | Date |
|-----|-----------|--------|------|
| [#22547502002](https://github.com/hggzm/Teams-AdaptiveCards-Mobile/actions/runs/22547502002) | **SUCCESS** | `b4c4ef0b` | 2025-03-01 |

## Gate Architecture

The `agent-gate.yml` workflow runs **6 parallel jobs** + a **gate verdict** aggregator:

### Blocking Jobs (must pass)
1. **structure-check** - Validates repo structure, shared C++ headers, test card JSON syntax (excludes `*Invalid*` files)
2. **ios-spm-build** - `swift build` + `swift test --filter AdaptiveCardsTest` on macOS 15
3. **android-build** - `./gradlew :adaptivecards:assembleDebug` with JDK 17 on Ubuntu

### Advisory Jobs (continue-on-error)
4. **ios-xcodebuild** - CocoaPods install + xcodebuild workspace build on macOS 15
5. **android-unit-tests** - `./gradlew :adaptivecards:testDebugUnitTest`, uploads test reports
6. **parity-check** - Source inventory counts across C++, iOS, Android

### Gate Verdict
- Requires: structure-check + ios-spm-build + android-build
- Reports advisory job status but does not block on them

## Commits on `proxy/integration`

| Hash | Message |
|------|---------|
| `b4c4ef0b` | ci: skip intentionally-invalid test JSON files in validation |
| `04ff142d` | ci: add agent validation gate workflow |

## Build Systems

### iOS
- **SPM** (`Package.swift`): ObjectModel (C++17) + AdaptiveCards (ObjC/Swift) + AdaptiveCardsTest. iOS 13+.
- **Xcode** (`AdaptiveCards.xcworkspace`): CocoaPods (FluentUI 0.1.9, SVGKit 3.0.0). iOS 15+.

### Android
- **Gradle 8.10**, AGP 8.5.2, Kotlin 1.9.24, JDK 17, NDK 28.0.13004108
- CMake builds `adaptivecards-native-lib` shared library from `source/shared/cpp/ObjectModel/*.cpp`

## Dashboard Tracking

Two autonomy engine jobs track this fork:

| Job ID | Executor | Interval |
|--------|----------|----------|
| `github-issues-sync-prod-fork` | `github-issues-sync` | 600s |
| `github-work-state-tracker-prod-fork` | `github-work-state-tracker` | 300s |

## Remotes

```
origin    git@github.com:hggzm/Teams-AdaptiveCards-Mobile.git
upstream  https://github.com/microsoft/Teams-AdaptiveCards-Mobile.git
```

## Key Paths

| Path | Description |
|------|-------------|
| `.github/workflows/agent-gate.yml` | Agent validation gate workflow |
| `Package.swift` | SPM package manifest (iOS) |
| `source/ios/AdaptiveCards/AdaptiveCards.xcworkspace` | Xcode workspace (iOS) |
| `source/android/build.gradle` | Top-level Gradle build (Android) |
| `source/shared/cpp/ObjectModel/` | Shared C++ object model |
| `source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCardsTests/` | iOS test files |
| `source/android/adaptivecards/src/test/` | Android unit tests |
