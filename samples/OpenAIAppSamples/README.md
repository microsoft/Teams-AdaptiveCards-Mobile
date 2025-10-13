# OpenAI Apps Samples

## Quick Start

OpenAI Apps are embedded in **TextBlock elements** as JSON, following the same pattern as ChainOfThought and StreamingText views.

### Basic Example
```json
{
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    {
      "type": "TextBlock",
      "text": "{\"openAIApp\":{\"appId\":\"figma\",\"appName\":\"Figma\",\"embedUrl\":\"https://www.figma.com/embed?url=...\",\"renderMode\":\"inline\"}}",
      "wrap": true
    }
  ]
}
```

## Sample Files

### Figma Examples
- **figma-textblock.json** - Material Design starter kit embed. **Great for testing layouts!**
- **figma-single-app.json** - Legacy example using metadata (not currently supported)

### OpenAI SDK Examples

#### Pizzaz Demo Suite
Based on OpenAI's official Pizzaz demo showcasing different UI component patterns:

- **pizzaz-map.json** - Interactive map showing pizzerias with markers and routing
- **pizzaz-carousel.json** - Touch-friendly gallery carousel with navigation (300pt height)
- **pizzaz-list.json** - Scrollable ranked list with hero summary (500pt height)
- **pizzaz-video.json** - Video player with transcript and state sync
- **pizzaz-albums.json** - Photo album collection view
- **pizzaz-multi-app.json** - Multi-app switcher showing all components

#### Interactive Demos
- **solar-system.json** - 3D solar system visualization with planet details (480pt height)
- **todo.json** - Task manager with drag-and-drop reordering and date picker (500pt height)

### Legacy Examples
- **multi-app-example.json** - Legacy multi-app using metadata (not currently supported)

## JSON Format

### Single App (Inline)
```json
{
  "openAIApp": {
    "appId": "figma",
    "appName": "Figma",
    "appIconUrl": "https://cdn.example.com/figma-icon.png",
    "embedUrl": "https://www.figma.com/embed?embed_host=astra&url=https://www.figma.com/file/example",
    "authToken": "optional-bearer-token",
    "renderMode": "inline"
  }
}
```

### Multiple Apps
```json
{
  "openAIApps": [
    {
      "appId": "figma",
      "appName": "Figma",
      "embedUrl": "https://figma.com/embed"
    },
    {
      "appId": "canva",
      "appName": "Canva",
      "embedUrl": "https://canva.com/embed"
    }
  ]
}
```

## Fields

| Field | Required | Description |
|-------|----------|-------------|
| `appId` | ✅ | Unique identifier for the app |
| `appName` | ✅ | Display name shown in UI |
| `embedUrl` | ✅ | URL to load in iframe |
| `appIconUrl` | ❌ | Icon shown in collapsed state |
| `authToken` | ❌ | Bearer token for Authorization header |
| `renderMode` | ❌ | "inline" (default), "fullscreen", or "popup" |
| `initialData` | ❌ | JSON object passed to app on load |
| `preferredHeight` | ❌ | Fixed height in points (overrides auto-sizing) |

## Render Modes

### inline (default)
- Appears within card body
- Collapsible placeholder with expand button
- Height auto-adjusts (min: 200pt, max: 600pt) or uses `preferredHeight`
- Full screen button available

**Height Optimization:**
- **Auto-sizing**: Omit `preferredHeight` for dynamic height based on content
- **Fixed height**: Set `preferredHeight` (e.g., 300 for carousel, 500 for lists)
- **Use cases**: 
  - Carousels work best with fixed heights (~300pt)
  - Scrollable lists benefit from taller fixed heights (~500pt)
  - Maps and interactive content can use auto-sizing

### fullscreen
- Opens directly in modal
- Full device height
- Navigation bar with close button

### popup (future)
- Floating window overlay
- Not yet implemented

## Pizzaz Demo Components

The Pizzaz samples are based on OpenAI's official demo suite showcasing different UI patterns for embedded applications:

### 🗺️ Pizza Map (`pizzaz-map.json`)
- **Component**: Interactive Mapbox-powered map
- **Features**: 
  - Marker placement for 10 SF pizzerias
  - Click markers to view details
  - Sidebar with place listings
  - Inspector panel with reviews (fullscreen mode)
  - Responsive layout (mobile carousel, desktop sidebar)
- **Use Case**: Location-based data visualization

### 🎠 Pizza Carousel (`pizzaz-carousel.json`)
- **Component**: Horizontal scrolling gallery
- **Features**:
  - Touch-friendly embla-carousel
  - Arrow navigation buttons
  - Edge fade gradients
  - Card-based layout with images
- **Use Case**: Content browsing, product galleries

### 📋 Pizza List (`pizzaz-list.json`)
- **Component**: Ranked list with hero section
- **Features**:
  - Hero summary card
  - Scrollable ranked items
  - Rating display
  - Save list action
- **Use Case**: Rankings, itineraries, reports

### 🎥 Pizza Video (`pizzaz-video.json`)
- **Component**: Video player with transcript
- **Features**:
  - Playback controls
  - Transcript with timestamps
  - Summary/transcript tabs (fullscreen)
  - State sync to ChatGPT
  - PiP and fullscreen modes
- **Use Case**: Media presentations, tutorials

### 📸 Pizza Albums (`pizzaz-albums.json`)
- **Component**: Photo album viewer
- **Features**:
  - Grid or gallery layout
  - Lightbox viewing
  - Photo metadata
- **Use Case**: Image collections, portfolios

### 🎛️ Multi-App Switcher (`pizzaz-multi-app.json`)
- **Component**: Horizontal app selector
- **Features**:
  - Tab-based switching between apps
  - Different icon per app
  - Maintains state per app
- **Use Case**: Multi-tool interfaces

## Interactive Demo Components

### 🌌 Solar System (`solar-system.json`)
- **Component**: 3D solar system visualization
- **Features**:
  - Interactive Three.js 3D rendering
  - Navigate between 8 planets
  - Orbit controls and zoom
  - Planet information cards
  - Smooth camera transitions
  - Bloom effects and post-processing
- **Use Case**: Educational content, data visualization, 3D presentations
- **Height**: 480pt (optimal for 3D viewport)

### ✅ Todo List (`todo.json`)
- **Component**: Task management interface
- **Features**:
  - Drag-and-drop reordering (Framer Motion)
  - Add/edit/delete tasks
  - Date picker integration
  - Task filtering and sorting
  - Persistent state
  - Responsive design
- **Use Case**: Task tracking, project management, checklists
- **Height**: 500pt (optimal for scrollable list)

## Testing URLs

### Safe Test URLs (No Auth)
```
https://www.example.com
https://www.figma.com/embed?embed_host=share&url=...
http://localhost:3000/test-iframe.html
```

### Test HTML (Save as test-iframe.html)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Test Iframe</title>
    <style>
        body { font-family: system-ui; padding: 20px; }
        button { padding: 10px 20px; margin: 10px; }
    </style>
</head>
<body>
    <h1>Test OpenAI App Iframe</h1>
    <p>This is a test iframe for the AdaptiveCards OpenAI Apps feature.</p>
    <button onclick="alert('Button clicked!')">Test Button</button>
    <button onclick="document.body.style.height = '400px'">Grow Height</button>
    <button onclick="document.body.style.height = '200px'">Shrink Height</button>
</body>
</html>
```

## Testing in Visualizer

1. Open `ADCIOSVisualizer.xcodeproj` in Xcode
2. Run the app on iPhone 16 simulator
3. Navigate to `samples/OpenAIAppSamples/figma-textblock.json`
4. Verify:
   - ✅ Collapsed placeholder appears with app name
   - ✅ Tap placeholder expands to show iframe
   - ✅ Collapse button returns to placeholder
   - ✅ Full screen button launches modal
   - ✅ Height adjusts automatically
   - ✅ Close button in modal works

## Architecture

### Integration Pattern
Follows the **exact same pattern** as ChainOfThought and StreamingText:

1. **TextBlock Rendering**: ACRTextBlockRenderer checks text content
2. **Factory Detection**: `[OpenAIAppViewFactory isOpenAIAppContent:]` checks for JSON
3. **View Creation**: `[OpenAIAppViewFactory createOpenAIAppViewFromTextContent:]` creates UIView
4. **Layout Integration**: View added to viewGroup with `addArrangedSubview:`

### Components
- **OpenAIAppModels.swift**: Data structures (OpenAIAppData, RenderMode)
- **OpenAIAppView.swift**: SwiftUI UI (collapsed, expanded, fullscreen)
- **WebViewContainer.swift**: WKWebView wrapper with auto-height
- **OpenAIAppHostingView.swift**: UIKit bridge + factory
- **ACRTextBlockRenderer.mm**: Integration point (3 lines added)

## Debugging

### Check Factory Registration
```objectivec
Class factory = NSClassFromString(@"OpenAIAppViewFactory");
NSLog(@"Factory exists: %@", factory ? @"YES" : @"NO");
```

### Verify JSON Parsing
```swift
let json = """
{"openAIApp":{"appId":"test","appName":"Test","embedUrl":"https://example.com"}}
"""
let isValid = OpenAIAppViewFactory.isOpenAIAppContent(json)
print("Valid JSON: \(isValid)")
```

### Enable WebView Debugging
```swift
// In WebViewContainer.swift makeUIView()
webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
```

Then: Safari > Develop > Simulator > [Your WebView]

## Known Issues

1. **State Loss**: Collapsing/expanding recreates WebView (state lost)
   - **Workaround**: Keep expanded, use full screen for complex interactions
   - **Future**: WKWebView pool or PostMessage bridge

2. **Height Limits**: Inline mode capped at 600pt
   - **Workaround**: Use fullscreen mode for tall content

3. **iOS 15.0+ Required**: Uses SwiftUI features
   - **Fallback**: Returns nil, renders as empty space

4. **JSON Visible on Error**: If parsing fails, JSON string shows in card
   - **Workaround**: Validate JSON before sending
   - **Future**: Hide TextBlock on successful parse

## Future Enhancements

- [ ] Move to card metadata instead of TextBlock
- [ ] State synchronization across expand/collapse
- [ ] OAuth flow integration
- [ ] WKWebView preloading for performance
- [ ] Lazy loading for off-screen apps
- [ ] PostMessage API for app communication

## Questions?

See `OPENAI_APPS_IMPLEMENTATION.md` in repo root for full architecture details.


## Sample Files

### 1. figma-single-app.json
Demonstrates a single embedded Figma app within an Adaptive Card.

**Features:**
- Single OpenAI app in metadata
- Design review scenario
- Inline rendering mode
- Full card with text, facts, and actions

**Usage:**
```swift
let jsonString = try String(contentsOfFile: "figma-single-app.json")
let parseResult = ACOAdaptiveCard.fromJson(jsonString)
if let card = parseResult.card {
    let view = ACRRenderer.render(card, config: hostConfig, widthConstraint: 320)
    // OpenAI app will automatically render at the bottom
}
```

### 2. multi-app-example.json
Demonstrates multiple embedded apps (Figma and Canva) in a single card.

**Features:**
- Multiple OpenAI apps in metadata (`openAIApps` array)
- Marketing campaign comparison scenario
- Both apps render inline, stacked vertically
- Demonstrates container view for multiple apps

## Metadata Structure

### Single App
```json
{
  "metadata": {
    "openAIApp": {
      "appId": "unique-app-id",
      "appName": "App Display Name",
      "appIconUrl": "https://example.com/icon.png",
      "embedUrl": "https://app.example.com/embed",
      "authToken": "optional-bearer-token",
      "initialData": {
        "optional": "data-to-inject"
      },
      "renderMode": "inline"
    }
  }
}
```

### Multiple Apps
```json
{
  "metadata": {
    "openAIApps": [
      { "appId": "app1", "appName": "App 1", ... },
      { "appId": "app2", "appName": "App 2", ... }
    ]
  }
}
```

## Required Fields

- **appId** (string): Unique identifier for the app instance
- **appName** (string): Display name shown in UI
- **embedUrl** (string): URL to load in iframe

## Optional Fields

- **appIconUrl** (string): Icon URL (shown in collapsed state and header)
- **authToken** (string): Bearer token sent in Authorization header
- **initialData** (object): Data injected into web view via JavaScript
- **renderMode** (string): "inline" | "popup" | "fullscreen" (default: "inline")

## Render Modes

### inline (Default)
- Renders embedded in the card
- Collapsible placeholder that expands to show iframe
- Height auto-adjusts based on content (max 600pt)
- Full screen button available

### popup
- Not yet implemented (future enhancement)
- Will show as floating overlay (picture-in-picture)

### fullscreen
- Opens directly in modal presentation
- No inline view, just full screen button

## Testing URLs

For testing, you can use these public embed-friendly URLs:

### Figma
```
https://www.figma.com/embed?embed_host=test
```

### Canva
```
https://www.canva.com/design/[design-id]/view?embed
```

### Google Docs (Viewer)
```
https://docs.google.com/document/d/[doc-id]/preview
```

### CodePen
```
https://codepen.io/[user]/embed/[pen-id]
```

## Demo Scenarios

### Design Review (Single App)
- Designer shares Figma mockup for review
- Reviewers can interact with design directly in Teams
- Approve/reject actions in card

### A/B Testing (Multiple Apps)
- Compare two design options side-by-side
- Each app loads different content
- Submit action to record preference

### Documentation (With Auth)
- Load private document with auth token
- Secure iframe with authentication
- Read-only or edit mode based on permissions

## Implementation Notes

### Height Management
- Default min height: 200pt
- Default max height: 600pt
- Auto-adjusts via JavaScript height observer
- Prevents excessive vertical growth

### Security
- WebViews run in isolated context
- Authentication tokens sent via headers (not in URL)
- Can restrict navigation to specific domains

### Performance
- Collapsed by default (on-demand loading)
- Single WebView per app (shared between inline/fullscreen)
- Height updates throttled to prevent layout thrashing

## Browser Support

The embedded WebView (WKWebView) supports:
- Modern web standards (ES6+, CSS3)
- LocalStorage and SessionStorage
- PostMessage for communication
- Most HTML5 APIs (Canvas, Audio, Video, etc.)

## Debugging

Enable logging in Xcode console:
```
🌐 WebViewContainer: Loading URL: ...
📏 WebViewContainer: Height update #1 - 450pt
✅ WebViewContainer: Finished loading
```

Check for OpenAI app detection:
```
✅ Parsed single OpenAI app: Figma
✅ OpenAI app view added to card
```

## Known Limitations

1. **State Persistence**: Currently each view creates its own WebView. State isn't shared between inline and fullscreen views (enhancement planned).

2. **Popup Mode**: Not yet implemented. Only inline and fullscreen modes supported.

3. **Navigation**: WebView doesn't allow arbitrary navigation. Links may open in Safari.

4. **CORS**: Some apps may not allow embedding. Test with iframe-friendly URLs.

## Next Steps

- [ ] Add state synchronization between inline and fullscreen
- [ ] Implement popup/PIP mode
- [ ] Add error handling UI for failed loads
- [ ] Support custom height limits per app
- [ ] Add loading timeout configuration

---

**Last Updated:** October 12, 2025  
**Version:** 1.0 (PoC)
