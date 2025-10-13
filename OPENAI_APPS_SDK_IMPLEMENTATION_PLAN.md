# OpenAI Apps SDK Integration - Implementation Plan

## Document Purpose
This document tracks the implementation of OpenAI Apps SDK integration into the Adaptive Cards Mobile SDK, following the self-contained SwiftUI pattern established by existing embedded apps (ChainOfThought and StreamingText views).

---

## Meeting Context Summary (October 12, 2025)

### What is OpenAI Apps SDK?
OpenAI announced a new "ChatGPT Apps" feature that allows third-party applications (like Figma, Canva) to be embedded and interact within ChatGPT conversations. The apps have three rendering modes:
1. **Inline** - Embedded within the message bubble
2. **Pop-up / Picture-in-Picture (PIP)** - Floating overlay
3. **Full Screen** - Takes over entire view

### Key Technical Points from Meeting

**Web Implementation (David's Prototype):**
- Uses iframe-based rendering
- Challenges with max height and sizing the iframe properly
- Adaptive Cards has better solutions for web-based rendering on mobile
- Breaking out of message bubble in Teams Message Preview (TMP) is complex due to nested components
- Full screen mode ideally should "blow up" inline content rather than pop into dialog

**State Management Concern:**
- Rendering the same app twice (inline + dialog) causes state synchronization issues
- Need to maintain single source of truth for app state

**Revenue Model Discussion:**
- Teams has in-app purchase model that could benefit app developers
- Apps typically serve as gateways to full products (e.g., Figma wants users on their website)
- Agents may need these apps for agent-to-agent communication (e.g., describing UI via Figma)

---

## Reference SwiftUI Implementations

### 1. ChainOfThoughtView Pattern
**File:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/SwiftViews/ChainOfThought/ChainOfThoughtView.swift`

**Key Characteristics:**
- ✅ Self-contained SwiftUI view with all logic embedded
- ✅ Data model-driven: `ChainOfThoughtData` with `entries` array
- ✅ Collapsible/expandable state management
- ✅ Animation support (`withAnimation`)
- ✅ Height change notifications: `onHeightChange` callback
- ✅ Complex nested state (expandedSteps set)
- ✅ Preview support for development
- ✅ iOS 15+ availability

**Pattern Strengths:**
```swift
struct ChainOfThoughtView: View {
    let data: ChainOfThoughtData          // Immutable data model
    @State private var expandedSteps      // Local UI state
    var onHeightChange: (() -> Void)?     // Height notification callback
    
    var body: some View {
        VStack(alignment: .leading) {
            // Self-contained rendering logic
        }
        .onAppear { /* Initialize state */ }
        .onChange(of: expandedSteps) { /* Notify height changes */ }
    }
}
```

### 2. StreamingTextView Pattern
**File:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/SwiftViews/Streaming/StreamingTextView.swift`

**Key Characteristics:**
- ✅ Multi-phase rendering (start, informative, streaming, final)
- ✅ Collapsible state with "Thinking..." placeholder
- ✅ Performance optimization for long content (50K+ chars)
- ✅ Timer-based animation with cleanup
- ✅ Manual state management (`hasBeenManuallyExpanded`)
- ✅ Throttled height notifications for performance
- ✅ Stop/cancel interaction support

**Pattern Strengths:**
```swift
struct StreamingTextView: View {
    let streamingData: StreamingContent
    var onHeightChange: (() -> Void)?
    
    @State private var displayedText: String = ""
    @State private var isCollapsed: Bool = false
    @State private var internalStreamingPhase: StreamingPhase
    
    var body: some View {
        if isCollapsed {
            collapsedView  // Compact representation
        } else {
            expandedView   // Full content
        }
    }
}
```

**Lessons Learned:**
- Height change notifications must be throttled for performance
- Performance mode needed for very long content
- Separate internal state from data model state for UI control
- Collapsible views improve initial render performance

---

## OpenAI Apps SDK Integration Plan

### Architecture Overview

```
Adaptive Card JSON
    ↓
[Parse OpenAI App Config]
    ↓
OpenAIAppView (SwiftUI)
    ↓
┌─────────────────────────────┐
│  Inline Rendering Mode      │
│  - WKWebView/iframe wrapper │
│  - Height-responsive        │
│  - Message bubble embedded  │
└─────────────────────────────┘
    ↓ (expand button)
┌─────────────────────────────┐
│  Full Screen Mode           │
│  - Reuse same web content   │
│  - State preservation       │
│  - Native modal presentation│
└─────────────────────────────┘
```

### Data Model Design

#### Option 1: Dedicated Adaptive Card Field (Preferred)
```json
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [
    {
      "type": "OpenAIApp",
      "appId": "figma-app-123",
      "appName": "Figma",
      "appIcon": "https://...",
      "embedUrl": "https://figma.com/embed/...",
      "authToken": "...",
      "initialData": { 
        "designId": "abc123"
      },
      "renderMode": "inline",
      "fallback": {
        "type": "TextBlock",
        "text": "View in Figma: [link]"
      }
    }
  ]
}
```

#### Option 2: Extension Data Pattern (More Flexible)
```json
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [
    {
      "type": "Container",
      "items": [
        {
          "type": "TextBlock",
          "text": "Figma Design Preview"
        }
      ]
    }
  ],
  "extensions": {
    "openai": {
      "apps": [
        {
          "appId": "figma-app-123",
          "embedUrl": "https://...",
          "placement": "inline",
          "config": { /* app-specific config */ }
        }
      ]
    }
  },
  "fallback": "text"
}
```

#### Option 3: Metadata Field Pattern (Chain of Thought style)
```json
{
  "type": "AdaptiveCard",
  "body": [...],
  "metadata": {
    "openAIApp": {
      "type": "embedded-app",
      "appType": "figma",
      "url": "https://...",
      "mode": "inline"
    }
  }
}
```

**Recommendation:** Start with Option 3 (metadata pattern) since it's similar to existing Chain of Thought parsing and doesn't require schema changes.

---

## Implementation Phases

### Phase 1: Core Infrastructure ✅ (Week 1-2)

**1.1 Data Model**
```swift
// File: OpenAIAppModels.swift

@available(iOS 15.0, *)
struct OpenAIAppData {
    let appId: String
    let appName: String
    let appIconUrl: String?
    let embedUrl: URL
    let authToken: String?
    let initialData: [String: Any]?
    let renderMode: RenderMode
    
    enum RenderMode: String {
        case inline
        case popup
        case fullscreen
    }
}

// Parser extension
extension ACOAdaptiveCard {
    func parseOpenAIAppData() -> OpenAIAppData? {
        // Parse from metadata field similar to Chain of Thought
        guard let metadata = self.additionalProperty(forKey: "metadata") as? [String: Any],
              let appConfig = metadata["openAIApp"] as? [String: Any] else {
            return nil
        }
        
        // Build OpenAIAppData from config
        // Return nil if required fields missing
    }
}
```

**1.2 Base SwiftUI View**
```swift
// File: OpenAIAppView.swift

@available(iOS 15.0, *)
struct OpenAIAppView: View {
    let appData: OpenAIAppData
    var onHeightChange: (() -> Void)? = nil
    
    @State private var isCollapsed: Bool = true
    @State private var isLoading: Bool = true
    @State private var contentHeight: CGFloat = 300
    @State private var showFullScreen: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isCollapsed {
                collapsedAppPlaceholder
            } else {
                expandedInlineView
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            // Initialize if needed
        }
    }
    
    @ViewBuilder
    private var collapsedAppPlaceholder: some View {
        // Similar to StreamingTextView collapsed state
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: appData.appIconUrl ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 32, height: 32)
            
            Text("\(appData.appName) App (Tap to open)")
                .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            Image(systemName: "arrow.up.right.square")
                .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation {
                isCollapsed = false
            }
            onHeightChange?()
        }
    }
    
    @ViewBuilder
    private var expandedInlineView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with app info and controls
            appHeader
            
            // Web content container
            WebViewContainer(
                url: appData.embedUrl,
                contentHeight: $contentHeight,
                isLoading: $isLoading,
                onHeightChange: onHeightChange
            )
            .frame(height: contentHeight)
            .cornerRadius(8)
            
            // Footer with expand button
            expandToFullScreenButton
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    @ViewBuilder
    private var appHeader: some View {
        HStack {
            AsyncImage(url: URL(string: appData.appIconUrl ?? ""))
                .frame(width: 24, height: 24)
            
            Text(appData.appName)
                .font(.headline)
            
            Spacer()
            
            Button(action: { 
                withAnimation { isCollapsed = true }
                onHeightChange?()
            }) {
                Image(systemName: "chevron.up")
            }
        }
    }
    
    @ViewBuilder
    private var expandToFullScreenButton: some View {
        Button(action: {
            showFullScreen = true
        }) {
            HStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                Text("Open Full Screen")
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .sheet(isPresented: $showFullScreen) {
            OpenAIAppFullScreenView(appData: appData)
        }
    }
}
```

**1.3 WebView Container (Inline)**
```swift
// File: WebViewContainer.swift

@available(iOS 15.0, *)
struct WebViewContainer: UIViewRepresentable {
    let url: URL
    @Binding var contentHeight: CGFloat
    @Binding var isLoading: Bool
    var onHeightChange: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false // Controlled by parent
        
        // Inject height observer script
        let heightScript = """
        function updateHeight() {
            window.webkit.messageHandlers.heightChanged.postMessage(
                document.documentElement.scrollHeight
            );
        }
        const observer = new ResizeObserver(updateHeight);
        observer.observe(document.body);
        updateHeight();
        """
        
        let userScript = WKUserScript(
            source: heightScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(
            context.coordinator,
            name: "heightChanged"
        )
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "heightChanged",
               let height = message.body as? CGFloat {
                DispatchQueue.main.async {
                    self.parent.contentHeight = min(height, 600) // Max height cap
                    self.parent.onHeightChange?()
                }
            }
        }
    }
}
```

---

### Phase 2: Full Screen Mode (Week 3)

**2.1 Full Screen View**
```swift
// File: OpenAIAppFullScreenView.swift

@available(iOS 15.0, *)
struct OpenAIAppFullScreenView: View {
    let appData: OpenAIAppData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full screen web view
                FullScreenWebView(
                    url: appData.embedUrl,
                    isLoading: $isLoading
                )
                
                // Loading overlay
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle(appData.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct FullScreenWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: FullScreenWebView
        
        init(_ parent: FullScreenWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}
```

---

### Phase 3: State Synchronization (Week 4)

**Challenge:** Maintaining state between inline and full screen views

**Solution Options:**

**Option A: Shared WebView Instance (Recommended)**
```swift
class OpenAIAppWebViewManager: ObservableObject {
    static let shared = OpenAIAppWebViewManager()
    
    private var webViewCache: [String: WKWebView] = [:]
    
    func getOrCreateWebView(for appId: String, url: URL) -> WKWebView {
        if let existing = webViewCache[appId] {
            return existing
        }
        
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        webViewCache[appId] = webView
        return webView
    }
    
    func removeWebView(for appId: String) {
        webViewCache.removeValue(forKey: appId)
    }
}
```

**Option B: PostMessage Bridge**
```swift
// Save/restore state via JavaScript bridge
func saveAppState(webView: WKWebView, completion: @escaping ([String: Any]?) -> Void) {
    let script = "window.getAppState ? window.getAppState() : null"
    webView.evaluateJavaScript(script) { result, error in
        completion(result as? [String: Any])
    }
}

func restoreAppState(webView: WKWebView, state: [String: Any]) {
    let stateJSON = try? JSONSerialization.data(withJSONObject: state)
    let stateString = String(data: stateJSON ?? Data(), encoding: .utf8) ?? "{}"
    let script = "window.setAppState && window.setAppState(\(stateString))"
    webView.evaluateJavaScript(script, completionHandler: nil)
}
```

---

### Phase 4: Integration with Adaptive Cards SDK (Week 5)

**4.1 Register Custom Element**
```swift
// In AdaptiveCards SDK initialization

@available(iOS 15.0, *)
extension ACRRegistration {
    func registerOpenAIAppRenderer() {
        // Register parser for OpenAI app metadata
        self.setBaseCardElementParser(
            OpenAIAppParser(),
            cardElementType: .customType("OpenAIApp")
        )
        
        // Register renderer
        self.setBaseCardElementRenderer(
            OpenAIAppRenderer(),
            cardElementType: .customType("OpenAIApp")
        )
    }
}

class OpenAIAppParser: ACOBaseCardElementParser {
    override func deserialize(
        from data: Data,
        parseContext: ACOParseContext
    ) -> ACOBaseCardElement? {
        // Parse OpenAI app data from JSON
        // Return custom ACOOpenAIAppElement
    }
}

class OpenAIAppRenderer: ACRBaseCardElementRenderer {
    override func render(
        _ viewGroup: UIView,
        rootView: ACRView,
        inputs: [ACRIBaseInputHandler],
        baseCardElement: ACOBaseCardElement,
        hostConfig: ACOHostConfig
    ) -> UIView {
        guard let appElement = baseCardElement as? ACOOpenAIAppElement else {
            return UIView()
        }
        
        let appData = appElement.getAppData()
        let swiftUIView = OpenAIAppView(
            appData: appData,
            onHeightChange: {
                rootView.setNeedsLayout()
                rootView.layoutIfNeeded()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        return hostingController.view
    }
}
```

---

## Testing Strategy

### Unit Tests
- [ ] OpenAIAppData parsing from JSON
- [ ] Height calculation logic
- [ ] State management (collapsed/expanded)
- [ ] WebView message handling

### Integration Tests
- [ ] Full adaptive card with OpenAI app rendering
- [ ] Inline to full screen transition
- [ ] State persistence across mode changes
- [ ] Height change notifications

### Manual Test Cases
1. **Inline Rendering**
   - App loads correctly in message bubble
   - Height adjusts to content
   - Collapse/expand works smoothly

2. **Full Screen Mode**
   - Opens in modal presentation
   - Maintains scroll position
   - Close button works

3. **State Preservation**
   - User interactions persist across inline/fullscreen
   - Form data not lost on mode change

4. **Performance**
   - Multiple apps in same card render correctly
   - Memory management (no leaks from WKWebView)
   - Smooth animations

---

## Open Questions & Decisions Needed

### Technical Decisions
1. **Q:** Should we support popup/PIP mode or only inline + fullscreen?
   - **Recommendation:** Start with inline + fullscreen. Add PIP later if needed.

2. **Q:** Max height for inline rendering?
   - **Recommendation:** 600pt cap, similar to task modules

3. **Q:** Authentication handling - where does authToken come from?
   - **Options:** 
     - A) Bot provides token in card JSON
     - B) SDK makes separate auth call
     - **Recommendation:** Bot provides token (simpler)

4. **Q:** Should apps be sandboxed (no network access to other domains)?
   - **Recommendation:** Yes, use WKWebView content rules

### Product Decisions
1. **Q:** What apps should be supported in PoC?
   - **Suggestion:** Start with 1-2 apps (Figma, Canva mentioned in meeting)

2. **Q:** How to handle app failures (404, timeout)?
   - **Recommendation:** Show fallback TextBlock

3. **Q:** Allow multiple apps in one card?
   - **Recommendation:** Yes, render as vertical stack

---

## Success Criteria

### PoC Success (End of Week 5)
- ✅ Can render OpenAI app iframe inline in adaptive card
- ✅ Tap to expand to full screen works
- ✅ Height adjusts dynamically based on content
- ✅ Works with at least one real app (Figma or Canva)
- ✅ No state loss between inline and full screen
- ✅ Performance acceptable (< 1s load time)

### Production Ready (Future)
- [ ] Support all three modes (inline, popup, fullscreen)
- [ ] Security review passed
- [ ] Accessibility support (VoiceOver)
- [ ] Localization support
- [ ] Analytics integration
- [ ] Error handling & fallbacks
- [ ] Documentation complete

---

## Timeline

| Week | Phase | Deliverable |
|------|-------|-------------|
| 1 | Data model & parsing | Parse OpenAI app from adaptive card JSON |
| 2 | Basic inline view | Render iframe in message bubble with collapse/expand |
| 3 | Full screen mode | Modal presentation with shared state |
| 4 | State sync | WebView state preservation working |
| 5 | SDK integration | Registered custom element, full PoC demo ready |

---

## References

### Existing Patterns to Follow
- `ChainOfThoughtView.swift` - Collapsible state, height notifications
- `StreamingTextView.swift` - Multi-phase rendering, performance optimization

### OpenAI Documentation
- [ ] Find OpenAI Apps SDK documentation URL
- [ ] Review authentication flow
- [ ] Check supported embedding options

### Microsoft Teams Documentation
- [ ] Task module height/sizing guidelines
- [ ] WebView security requirements
- [ ] Adaptive Cards 1.6 extension spec

---

## Next Steps (Immediate)

1. **Week 1 Day 1-2:**
   - Create `OpenAIAppModels.swift` with data structures
   - Implement JSON parsing from metadata field
   - Write unit tests for parsing

2. **Week 1 Day 3-4:**
   - Create basic `OpenAIAppView.swift` with collapsed state
   - Implement collapsible placeholder UI
   - Test with mock data

3. **Week 1 Day 5:**
   - Begin `WebViewContainer.swift` implementation
   - Test iframe loading with sample URL
   - Verify height change notifications work

---

## Notes from Meeting

- David has already prototyped this on web, can share learnings
- Teams has advantage over ChatGPT: in-app purchase model
- Figma/Canva want users to discover their full products
- Agent-to-agent communication may drive value (e.g., Figma for UI description)
- Teams Message Preview (TMP) component nesting makes "blow up" difficult
- State duplication issue if rendering twice (inline + dialog)

---

## Appendix: JSON Examples

### Example 1: Figma Embedded App
```json
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [
    {
      "type": "TextBlock",
      "text": "Design Review",
      "size": "large",
      "weight": "bolder"
    }
  ],
  "metadata": {
    "openAIApp": {
      "appId": "figma-123",
      "appName": "Figma",
      "appIconUrl": "https://figma.com/icon.png",
      "embedUrl": "https://figma.com/embed/abc123",
      "authToken": "Bearer xyz...",
      "renderMode": "inline"
    }
  }
}
```

### Example 2: Multiple Apps
```json
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [
    {
      "type": "TextBlock",
      "text": "Design Options"
    }
  ],
  "metadata": {
    "openAIApps": [
      {
        "appId": "figma-1",
        "appName": "Figma Option A",
        "embedUrl": "https://figma.com/embed/a"
      },
      {
        "appId": "canva-1",
        "appName": "Canva Option B",
        "embedUrl": "https://canva.com/embed/b"
      }
    ]
  }
}
```

---

**Document Version:** 1.0  
**Last Updated:** October 12, 2025  
**Owner:** Hugo Gonzalez  
**Status:** In Progress - Phase 1 (Week 1)

---

## Implementation Progress

### ✅ Completed (October 12, 2025)

#### 1. OpenAIAppModels.swift
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/SwiftViews/OpenAIApp/OpenAIAppModels.swift`

**What we built:**
- `OpenAIAppData` struct with all required/optional fields
- `RenderMode` enum (inline, popup, fullscreen)
- `parse(from:)` static method for JSON parsing
- `CustomStringConvertible` for debugging
- Validation logic for required fields (appId, appName, embedUrl)

**Key Features:**
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
```

#### 2. ACOAdaptiveCard+OpenAIApp.swift  
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/Extensions/ACOAdaptiveCard+OpenAIApp.swift`

**What we built:**
- Extension method `parseOpenAIApps()` that reads from `additionalProperty()`
- `hasOpenAIApps()` convenience method
- `OpenAIAppsContainer` class with Objective-C bridge
- Objective-C accessible properties on `OpenAIAppData` (prefixed with `objc_`)
- Support for both single app and multiple apps in metadata

**Usage Example:**
```swift
let card = ACOAdaptiveCard.fromJson(jsonString)
if let appsContainer = card.parseOpenAIApps() {
    for i in 0..<appsContainer.count {
        if let app = appsContainer.app(at: i) {
            print("Found app: \(app.appName)")
        }
    }
}
```

#### 3. WebViewContainer.swift
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/SwiftViews/OpenAIApp/WebViewContainer.swift`

**What we built:**
- `WebViewContainer` - UIViewRepresentable wrapper for WKWebView
- Automatic height detection via JavaScript injection
- ResizeObserver for dynamic content changes
- Authentication token support in headers
- Initial data injection for app configuration
- Loading state management
- `FullScreenWebView` variant for modal presentation
- Height bounds (min: 200pt, max: 600pt)

**Key Features:**
- Injects JavaScript to observe DOM height changes
- Reports height updates via WKScriptMessageHandler
- Disables scrolling (parent controls it)
- Supports auth tokens and custom headers
- Periodic fallback checks for height updates

#### 4. OpenAIAppView.swift
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftAdaptiveCards/SwiftViews/OpenAIApp/OpenAIAppView.swift`

**What we built:**
- Main SwiftUI view following StreamingTextView/ChainOfThought patterns
- **Collapsed state** - Compact placeholder with app icon and name
- **Expanded inline state** - Full web view with header/footer
- **Full screen modal** - Sheet presentation with navigation
- `OpenAIAppsContainerView` for multiple apps
- Smooth animations with height change notifications
- Error handling and loading states

**UI Components:**
```swift
struct OpenAIAppView: View {
    - collapsedAppPlaceholder    // Tap to expand
    - expandedInlineView         // Web content + controls
    - appHeader                  // Icon, name, collapse button
    - inlineWebContent           // WebViewContainer
    - appFooter                  // Full screen button
    - errorView                  // Error display
}
```

#### 5. OpenAIAppHostingView.swift
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/SwiftViews/OpenAIApp/OpenAIAppHostingView.swift`

**What we built:**
- UIKit/Objective-C bridge class (similar to ChainOfThoughtHostingView)
- UIHostingController wrapper for SwiftUI views
- Automatic height calculation and updates
- Support for single and multiple apps
- Factory methods for easy creation

**Factory Methods:**
```swift
// From adaptive card
OpenAIAppHostingView.createFromCard(_ card: ACOAdaptiveCard) -> UIView?

// From app data
OpenAIAppHostingView.createFromAppData(_ appData: OpenAIAppData) -> UIView

// Check if card has apps
OpenAIAppHostingView.cardHasOpenAIApps(_ card: ACOAdaptiveCard) -> Bool
```

#### 5. OpenAIAppHostingView.swift
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/SwiftViews/OpenAIApp/OpenAIAppHostingView.swift`

**What we built:**
- UIKit/Objective-C bridge class (similar to ChainOfThoughtHostingView)
- UIHostingController wrapper for SwiftUI views
- Automatic height calculation and updates
- Support for single and multiple apps
- Factory methods for easy creation

**Factory Methods:**
```swift
// From adaptive card
OpenAIAppHostingView.createFromCard(_ card: ACOAdaptiveCard) -> UIView?

// From app data
OpenAIAppHostingView.createFromAppData(_ appData: OpenAIAppData) -> UIView

// Check if card has apps
OpenAIAppHostingView.cardHasOpenAIApps(_ card: ACOAdaptiveCard) -> Bool
```

#### 6. ACRRenderer+OpenAIApp
**Location:** `/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards/ACRRenderer+OpenAIApp.{h,mm}`

**What we built:**
- Objective-C category on ACRRenderer
- Automatic rendering of OpenAI apps from metadata
- Integration into ACRView render pipeline
- Appends app views to end of card body

**Integration Point:**
```objc
// In ACRView.mm render method:
[ACRRenderer renderOpenAIAppsForCard:_adaptiveCard 
                            rootView:self 
                          hostConfig:_hostConfig];
```

#### 7. Sample JSON Files
**Location:** `/samples/OpenAIAppSamples/`

**What we created:**
- `figma-single-app.json` - Single embedded Figma app example
- `multi-app-example.json` - Multiple apps (Figma + Canva) example
- `README.md` - Complete documentation with usage examples

**Sample Metadata Structure:**
```json
{
  "metadata": {
    "openAIApp": {
      "appId": "figma-design-001",
      "appName": "Figma",
      "appIconUrl": "https://logo.clearbit.com/figma.com",
      "embedUrl": "https://www.figma.com/embed",
      "renderMode": "inline"
    }
  }
}
```

### 🔄 Ready for Testing
- All core functionality implemented
- Demo JSON files ready
- Documentation complete

### ⏭️ Future Enhancements (Post-PoC)
- Task 3: Unit tests for parsing logic
- Task 8: State synchronization between inline and fullscreen views
- Popup/PIP rendering mode
- Custom height limits per app
- Error handling UI improvements
- Loading timeout configuration

---

## How to Use (Quick Start)

### 1. Parse Card with OpenAI App
```swift
let jsonString = """
{
  "type": "AdaptiveCard",
  "version": "1.6",
  "body": [...],
  "metadata": {
    "openAIApp": {
      "appId": "figma-001",
      "appName": "Figma",
      "embedUrl": "https://www.figma.com/embed?embed_host=test",
      "renderMode": "inline"
    }
  }
}
"""

let parseResult = ACOAdaptiveCard.fromJson(jsonString)
if let card = parseResult.card {
    // OpenAI app automatically detected and rendered
    let view = ACRRenderer.render(card, config: hostConfig, widthConstraint: 320)
}
```

### 2. Manual Creation
```swift
if #available(iOS 15.0, *) {
    let appData = OpenAIAppData(
        appId: "test-app",
        appName: "Test App",
        embedUrl: URL(string: "https://example.com/embed")!
    )
    
    let appView = OpenAIAppHostingView.createFromAppData(appData)
    // Add to your view hierarchy
}
```

### 3. Check if Card Has Apps
```swift
if OpenAIAppHostingView.cardHasOpenAIApps(card) {
    print("Card contains OpenAI apps!")
}
```

---

## Testing the PoC

### Option 1: Use Sample JSON Files
```swift
// Load sample
let path = Bundle.main.path(forResource: "figma-single-app", ofType: "json")
let jsonString = try String(contentsOfFile: path!)

// Parse and render
let card = ACOAdaptiveCard.fromJson(jsonString).card!
let view = ACRRenderer.render(card, config: hostConfig, widthConstraint: 320)

// Add to your view controller
view.frame = CGRect(x: 0, y: 0, width: 320, height: 0)
self.view.addSubview(view)
```

### Option 2: Test URLs
Use these iframe-friendly URLs for testing:
- **Figma**: `https://www.figma.com/embed?embed_host=test`
- **CodePen**: `https://codepen.io/team/codepen/embed/PNaGbb`
- **Google Docs**: `https://docs.google.com/document/d/[id]/preview`

### Expected Behavior
1. **Card renders** with normal adaptive card content
2. **OpenAI app appears** at bottom in collapsed state
3. **Tap to expand** - Shows iframe with loading indicator
4. **Content loads** - iframe adjusts height automatically
5. **Tap full screen** - Opens modal with larger view
6. **Collapse** - Returns to compact placeholder

---

## Architecture Summary

```
User Provides Adaptive Card JSON
         ↓
ACOAdaptiveCard.fromJson()
         ↓
   [Detect metadata]
         ↓
ACRRenderer.renderOpenAIApps()
         ↓
OpenAIAppHostingView.createFromCard()
         ↓
┌────────────────────────────┐
│   OpenAIAppView (SwiftUI)  │
│   ┌──────────────────────┐ │
│   │  Collapsed State     │ │
│   │  (Tap to expand)     │ │
│   └──────────────────────┘ │
│          ↓ Expand          │
│   ┌──────────────────────┐ │
│   │  WebViewContainer    │ │
│   │  (WKWebView+height)  │ │
│   └──────────────────────┘ │
│          ↓ Full Screen     │
│   ┌──────────────────────┐ │
│   │  Modal Presentation  │ │
│   └──────────────────────┘ │
└────────────────────────────┘
```

---

**Document Version:** 1.0  
**Last Updated:** October 12, 2025  
**Owner:** Hugo Gonzalez  
**Status:** ✅ PoC Complete - Ready for Demo
