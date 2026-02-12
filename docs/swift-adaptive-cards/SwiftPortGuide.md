# Swift Adaptive Cards - Cheat Sheet

Quick reference for the Swift Adaptive Cards implementation and testing.

---

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Adaptive Card JSON                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              ACOAdaptiveCard.fromJson()                      │
│                  (Entry Point)                               │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌──────────────────────┐        ┌──────────────────────┐
│   C++ Parser         │        │   Swift Parser       │
│   (Default)          │        │   (ECS Flag ON)      │
└──────────────────────┘        └──────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              SwiftElementPropertyAccessor                    │
│         (Unified bridge for property access)                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              ACR*Renderer Classes                            │
│         (35 element/action renderers)                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    UIView Hierarchy                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 Key Classes

### Parser Layer
| Class | Purpose |
|-------|---------|
| `SwiftAdaptiveCardParser` | Main entry point for Swift JSON parsing |
| `SwiftAdaptiveCard` | Swift representation of parsed card |
| `ACOAdaptiveCard` | ObjC wrapper (unchanged API) |

### Bridge Layer
| Class | Purpose |
|-------|---------|
| `SwiftElementPropertyAccessor` | Bridge to access element properties |
| `SwiftAdaptiveCardObjcBridge` | ObjC-Swift interop utilities |
| `ACRRegistration` | Feature flag resolver integration |

### Feature Flag
| Flag Name | Purpose |
|-----------|---------|
| `isSwiftAdaptiveCardsEnabled` | Controls Swift vs C++ parser |

---

## 🧪 Running Tests

### Headless Tests (29 tests)
```bash
# Run all Swift integration tests
xcodebuild test \
  -workspace AdaptiveCards.xcworkspace \
  -scheme AdaptiveCards \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AdaptiveCardsTests/SwiftBridgeTests \
  -only-testing:AdaptiveCardsTests/SwiftCppParityTests \
  -only-testing:AdaptiveCardsTests/SwiftRenderingFlagTests \
  -only-testing:AdaptiveCardsTests/SwiftPackageBridgeTests
```

### UI Tests with Swift Flag (16 tests)
```bash
# Run Swift UI tests
xcodebuild test \
  -workspace AdaptiveCards.xcworkspace \
  -scheme ADCIOSVisualizer \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:ADCIOSVisualizerUITests/SwiftAdaptiveCardsUITests
```

### Single Test
```bash
# Run a specific test
xcodebuild test \
  -workspace AdaptiveCards.xcworkspace \
  -scheme ADCIOSVisualizer \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:ADCIOSVisualizerUITests/SwiftAdaptiveCardsUITests/testSwiftRenderingActivityUpdateDate
```

---

## 🚀 Enabling Swift Rendering

### Via Feature Flag (Production)
```objc
// In your feature flag resolver
- (BOOL)boolForFlag:(NSString *)flag {
    if ([flag isEqualToString:@"isSwiftAdaptiveCardsEnabled"]) {
        return YES;  // Enable Swift parser
    }
    return NO;
}
```

### Via Launch Argument (Testing)
```swift
// In UI tests
app.launchArguments = ["ui-testing", "--enable-swift-adaptive-cards"]
app.launch()
```

### Check Current Mode
```objc
BOOL useSwift = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];
```

---

## 📁 File Structure

```
source/ios/AdaptiveCards/
├── AdaptiveCards/
│   ├── AdaptiveCards/
│   │   ├── SwiftAdaptiveCards/          # Swift parser
│   │   │   ├── Models/                   # Data models
│   │   │   ├── Parsing/                  # JSON parsing
│   │   │   └── Bridge/                   # ObjC bridge
│   │   ├── ACR*Renderer.mm              # 35 renderers
│   │   └── SwiftElementPropertyAccessor.* # Property bridge
│   └── AdaptiveCardsTests/
│       └── SwiftAdaptiveCardsTests/
│           └── Integration/              # Headless tests
│               ├── SwiftBridgeTests.swift
│               ├── SwiftCppParityTests.swift
│               ├── SwiftRenderingFlagTests.swift
│               └── SwiftPackageBridgeTests.m
├── ADCIOSVisualizer/
│   ├── ADCIOSVisualizer/
│   │   └── ACRCustomFeatureFlagResolver.m  # Test flag resolver
│   └── ADCIOSVisualizerUITests/
│       ├── ADCIOSVisualizerUITests.mm      # C++ UI tests
│       └── SwiftAdaptiveCardsUITests.swift # Swift UI tests
└── samples/                               # Card JSON samples
    ├── v1.0/
    ├── v1.3/
    ├── v1.5/
    └── v1.6/
```

---

## 🔍 Property Access Pattern

### Before (Direct C++ Access)
```objc
// Old way - direct C++ property access
std::string text = textBlock->GetText();
```

### After (Unified Bridge)
```objc
// New way - works with both Swift and C++ parsed cards
NSString *text = [SwiftElementPropertyAccessor getText:element];
```

---

## ✅ Test Categories

| Category | File | Tests | Purpose |
|----------|------|-------|---------|
| Bridge | SwiftBridgeTests.swift | 4 | Property accessor methods |
| Parity | SwiftCppParityTests.swift | 11 | Swift/C++ parsing equality |
| Flags | SwiftRenderingFlagTests.swift | 11 | ECS flag behavior |
| ObjC | SwiftPackageBridgeTests.m | 3 | ObjC accessibility |
| UI | SwiftAdaptiveCardsUITests.swift | 16 | Visual rendering parity |

---

## 🐛 Debugging Tips

### Check Parser Used
```objc
// Add logging in ACOAdaptiveCard.fromJson
NSLog(@"Using Swift parser: %@", useSwift ? @"YES" : @"NO");
```

### Verify Property Bridge
```objc
// Check if element has Swift data
BOOL hasSwiftData = [SwiftElementPropertyAccessor hasSwiftElement:element];
```

### View Test Logs
```bash
# Check last test run
open ~/Library/Developer/Xcode/DerivedData/AdaptiveCards-*/Logs/Test/
```

---

## 📋 Quick Commands

| Action | Command |
|--------|---------|
| Build SDK | `xcodebuild -workspace AdaptiveCards.xcworkspace -scheme AdaptiveCards build` |
| Run headless tests | `xcodebuild test -workspace AdaptiveCards.xcworkspace -scheme AdaptiveCards -destination 'platform=iOS Simulator,name=iPhone 16'` |
| Run UI tests | `xcodebuild test -workspace AdaptiveCards.xcworkspace -scheme ADCIOSVisualizer -destination 'platform=iOS Simulator,name=iPhone 16'` |
| Clean build | `xcodebuild clean -workspace AdaptiveCards.xcworkspace -scheme AdaptiveCards` |

---

## 🔗 Related Resources

- [CONTACTS.md](CONTACTS.md) - Project contacts
- [Adaptive Cards Spec](https://adaptivecards.io/explorer/)
- [Teams iOS Repo](../../) - Main repository

---

*Last Updated: January 22, 2026*
