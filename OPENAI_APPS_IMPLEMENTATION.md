# OpenAI Apps SDK Integration - Implementation Summary

## Overview
This document describes the implementation of OpenAI Apps support in the AdaptiveCards iOS SDK. OpenAI Apps allow embedding third-party applications (like Figma, Canva, Miro) within adaptive cards using iframes with collapsible UI controls.

## Integration Pattern
**Following Proven Pattern**: OpenAI Apps use the **same integration pattern** as ChainOfThought and StreamingText views:
- Content is embedded in **TextBlock elements** as JSON
- Factory class checks text content and creates custom view
- Integrated in **ACRTextBlockRenderer** (not card metadata or separate renderer)
- Automatic layout and sizing with UIStackView

### Why TextBlock Pattern?
1. **Proven & Stable**: ChainOfThought and Streaming already work this way
2. **No Breaking Changes**: Doesn't require metadata parsing infrastructure
3. **Easy Migration**: Can move to metadata later if needed
4. **Works Today**: Leverages existing rendering pipeline

## Architecture

### Core Components

#### 1. **OpenAIAppModels.swift**
```swift
struct OpenAIAppData {
    let appId: String
    let appName: String
    let appIconUrl: String?
    let embedUrl: URL
    let authToken: String?
    let initialData: [String: Any]?
    let renderMode: RenderMode
}

enum RenderMode: String {
    case inline      // Collapsible within card
    case fullscreen  // Modal presentation
    case popup       // Future: floating window
}
```

#### 2. **OpenAIAppView.swift** (SwiftUI)
- **Collapsed State**: Shows app icon + name, tap to expand
- **Expanded Inline**: WebViewContainer with collapse/fullscreen buttons
- **Full Screen Modal**: NavigationView with close button
- **Multi-App Support**: Horizontal scroll for multiple apps

#### 3. **WebViewContainer.swift**
```swift
// WKWebView wrapper with auto-height detection
struct WebViewContainer: UIViewRepresentable {
    let url: URL
    let authToken: String?
    @Binding var contentHeight: CGFloat
    let onHeightChange: (CGFloat) -> Void
    
    // JavaScript injection for height updates
    // ResizeObserver monitors document.body
    // Posts messages via webkit.messageHandlers.heightChanged
}
```

#### 4. **OpenAIAppHostingView.swift** (UIKit Bridge)
```swift
class OpenAIAppHostingView: UIView {
    private var hostingController: UIHostingController<AnyView>
    
    // Factory creates from single or multiple apps
    init(appData: OpenAIAppData)
    init(apps: [OpenAIAppData])
    
    // Dynamic height calculation
    func updateHeight()
    override var intrinsicContentSize: CGSize
}
```

#### 5. **OpenAIAppViewFactory** (Objective-C Bridge)
```swift
@objc(OpenAIAppViewFactory)
public class OpenAIAppViewFactory: NSObject {
    @objc public static func createOpenAIAppViewFromTextContent(_ textContent: String) -> UIView?
    @objc public static func isOpenAIAppContent(_ textContent: String) -> Bool
}
```

#### 6. **ACRTextBlockRenderer.mm** Integration
```objectivec
// Added after Streaming check (line ~118)
if ([OpenAIAppViewFactory isOpenAIAppContent:textContent]) {
    UIView *openAIAppView = [OpenAIAppViewFactory createOpenAIAppViewFromTextContent:textContent];
    if (openAIAppView) {
        openAIAppView.translatesAutoresizingMaskIntoConstraints = NO;
        [openAIAppView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [openAIAppView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        openAIAppView.clipsToBounds = NO;
        
        NSString *areaName = stringForCString(elem->GetAreaGridName());
        [viewGroup addArrangedSubview:openAIAppView withAreaName:areaName];
        
        return openAIAppView;
    }
}
```

## JSON Format

### Single App in TextBlock
```json
{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "{\"openAIApp\":{\"appId\":\"figma\",\"appName\":\"Figma\",\"appIconUrl\":\"https://example.com/icon.png\",\"embedUrl\":\"https://www.figma.com/embed?url=...\",\"renderMode\":\"inline\"}}",
      "wrap": true
    }
  ]
}
```

### Multiple Apps in TextBlock
```json
{
  "type": "TextBlock",
  "text": "{\"openAIApps\":[{\"appId\":\"figma\",\"appName\":\"Figma\",\"embedUrl\":\"https://figma.com/embed\"},{\"appId\":\"canva\",\"appName\":\"Canva\",\"embedUrl\":\"https://canva.com/embed\"}]}",
  "wrap": true
}
```

## Key Features

### 1. Collapsible UI
- **Default**: Collapsed placeholder (app icon + name)
- **Tap**: Expands to show iframe
- **Inline Height**: Auto-adjusts via JavaScript (min: 200pt, max: 600pt)

### 2. Full Screen Mode
- Button in expanded view launches modal
- NavigationView with toolbar and close button
- Full device height for complex interactions

### 3. Authentication
- Optional `authToken` field
- Injected as `Authorization: Bearer {token}` header
- Supports secure third-party app access

### 4. Auto-Height Detection
```javascript
// Injected into WKWebView
const resizeObserver = new ResizeObserver(entries => {
    const height = document.body.scrollHeight;
    window.webkit.messageHandlers.heightChanged.postMessage({height});
});
resizeObserver.observe(document.body);
```

### 5. Multi-App Support
- Horizontal scroll with tabs
- Each app independently collapsible
- Shared navigation bar

## Files Modified/Created

### New Files
- `OpenAIAppModels.swift` - Data structures
- `OpenAIAppView.swift` - SwiftUI UI components
- `WebViewContainer.swift` - WKWebView wrapper
- `OpenAIAppHostingView.swift` - UIKit bridge + factory
- `samples/OpenAIAppSamples/figma-textblock.json` - Demo card
- `samples/OpenAIAppSamples/README.md` - Documentation

### Modified Files
- `ACRTextBlockRenderer.mm` - Added OpenAI App check (3 lines)
- **NOTE**: Originally attempted metadata integration in ACRView.mm, removed to follow TextBlock pattern

### Not Modified
- ACRView.mm - No changes needed (pattern handled in renderer)
- ACRRenderer.mm - No changes needed
- Project settings - Files added to Xcode project manually

## Testing

### Manual Testing (Visualizer)
1. Open `ADCIOSVisualizer.xcodeproj`
2. Load `samples/OpenAIAppSamples/figma-textblock.json`
3. Verify:
   - Collapsed placeholder appears
   - Tap expands to show WebView
   - Collapse button works
   - Full screen button launches modal
   - Height adjusts automatically

### Test URLs
```swift
// Safe test iframe (no auth required)
"https://www.example.com"
"https://www.figma.com/embed?embed_host=share&url=..."

// Local testing
"http://localhost:3000/test-iframe.html"
```

## Future Enhancements

### 1. State Synchronization (Deferred)
**Problem**: Expanding/collapsing or going fullscreen recreates WKWebView, losing state
**Options**:
- Shared WKWebView pool
- PostMessage bridge to save/restore state
- Server-side session management

### 2. Move to Metadata (Optional)
Can migrate from TextBlock to card metadata:
```json
{
  "type": "AdaptiveCard",
  "body": [...],
  "metadata": {
    "openAIApps": [...]
  }
}
```
Would require:
- ACRView.mm integration point
- Metadata parsing in ACOAdaptiveCard
- Custom renderer or body append logic

### 3. Enhanced Authentication
- OAuth flow integration
- Token refresh handling
- Multiple auth schemes (API key, JWT, etc.)

### 4. Performance Optimizations
- WKWebView preloading
- Lazy loading for off-screen apps
- Memory management for multiple iframes

## Known Limitations

1. **iOS 15.0+**: Requires SwiftUI features
2. **No Offline Support**: Requires network for iframe content
3. **State Loss**: Collapsing loses iframe state (deferred fix)
4. **Height Limits**: Min 200pt, max 600pt for inline mode
5. **TextBlock Visibility**: JSON string visible if rendering fails (graceful degradation)

## Migration Path

### From TextBlock to Metadata (Future)
1. Keep TextBlock support for backward compatibility
2. Add metadata parsing in ACOAdaptiveCard extension
3. Update factory to check both sources
4. Deprecate TextBlock format in v2.0

## Comparison with ChainOfThought/Streaming

| Aspect | ChainOfThought | Streaming | OpenAI Apps |
|--------|----------------|-----------|-------------|
| Integration | ACRTextBlockRenderer | ACRTextBlockRenderer | ACRTextBlockRenderer |
| Data Source | TextBlock content | TextBlock content | TextBlock content |
| Factory Class | ChainOfThoughtViewFactory | StreamingViewFactory | OpenAIAppViewFactory |
| UI Framework | SwiftUI | SwiftUI | SwiftUI |
| Hosting | ChainOfThoughtHostingView | StreamingTextHostingView | OpenAIAppHostingView |
| iOS Requirement | 15.0+ | 15.0+ | 15.0+ |

## Conclusion

The OpenAI Apps integration follows the **exact same proven pattern** as ChainOfThought and Streaming views, ensuring:
- ✅ Minimal code changes
- ✅ No breaking changes to existing architecture
- ✅ Automatic layout and sizing
- ✅ Easy to test and maintain
- ✅ Can migrate to metadata later if needed

**Status**: ✅ Core implementation complete, ready for demo
**Deferred**: Unit tests, state sync, metadata migration
