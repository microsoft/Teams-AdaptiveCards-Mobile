//
//  WebViewContainer.swift
//  AdaptiveCards
//
//  Created on 10/12/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import SwiftUI
import WebKit

/// UIViewRepresentable wrapper for WKWebView with automatic height adjustment
/// Used to embed OpenAI app iframes in SwiftUI views
@available(iOS 15.0, *)
struct WebViewContainer: UIViewRepresentable {
    /// URL to load in the web view
    let url: URL
    
    /// Optional authentication token to pass in headers
    let authToken: String?
    
    /// Optional initial data to inject into the web view
    let initialData: [String: Any]?
    
    /// Binding to track and update content height
    @SwiftUI.Binding var contentHeight: CGFloat
    
    /// Binding to track loading state
    @SwiftUI.Binding var isLoading: Bool
    
    /// Callback when height changes
    var onHeightChange: (() -> Void)?
    
    /// Optional preferred height (overrides auto-sizing)
    let preferredHeight: CGFloat?
    
    /// Maximum height cap to prevent excessive growth
    private let maxHeight: CGFloat = 600.0
    
    /// Minimum height for better UX
    private let minHeight: CGFloat = 200.0
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Enable inline media playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Configure for better iframe support
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        // Create web view
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false // Parent controls scrolling
        webView.scrollView.bounces = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // Inject height observer script
        injectHeightObserverScript(into: webView, coordinator: context.coordinator)
        
        // Inject initial data if provided
        if let initialData = initialData {
            injectInitialData(initialData, into: webView)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load once - prevent reload loops from SwiftUI updates
        guard !context.coordinator.hasLoadedInitialURL else {
            return
        }
        
        context.coordinator.hasLoadedInitialURL = true
        
        var request = URLRequest(url: url)
        
        // Add authentication token if provided
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers for OpenAI app detection
        request.addValue("AdaptiveCards-Mobile-iOS", forHTTPHeaderField: "X-Client")
        request.addValue(Bundle.main.bundleIdentifier ?? "unknown", forHTTPHeaderField: "X-Bundle-ID")
        
        print("🌐 WebViewContainer: Loading URL: \(url.absoluteString)")
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Stop loading to prevent any pending operations
        uiView.stopLoading()
    }
    
    // MARK: - Script Injection
    
    /// Inject JavaScript to observe height changes
    private func injectHeightObserverScript(into webView: WKWebView, coordinator: Coordinator) {
        let heightScript = """
        (function() {
            console.log('🚀 AdaptiveCards: Height observer script starting');
            
            // Set viewport for mobile rendering
            let viewport = document.querySelector('meta[name="viewport"]');
            if (!viewport) {
                viewport = document.createElement('meta');
                viewport.name = 'viewport';
                viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(viewport);
                console.log('📱 AdaptiveCards: Added mobile viewport meta tag');
            } else {
                console.log('📱 AdaptiveCards: Viewport already exists:', viewport.content);
            }
            
            // Inject global OpenAI-compatible object
            window.oai = window.oai || {};
            window.oai.widget = window.oai.widget || {};
            
            // Set maxHeight if preferred height is provided
            \(preferredHeight != nil ? "window.oai.maxHeight = \(preferredHeight!);" : "")
            \(preferredHeight != nil ? "console.log('📐 AdaptiveCards: Injected maxHeight =', window.oai.maxHeight);" : "console.log('📐 AdaptiveCards: No preferred height specified');")
            
            // Set display mode
            window.oai.displayMode = 'inline';
            console.log('🎨 AdaptiveCards: Set displayMode =', window.oai.displayMode);
            
            // Log the full window.oai object
            console.log('🔍 AdaptiveCards: window.oai =', JSON.stringify(window.oai, null, 2));
            
            // Function to measure and report height
            function updateHeight() {
                let height;
                
                // If maxHeight is set, use it (we're in constrained mode)
                if (window.oai.maxHeight) {
                    height = window.oai.maxHeight;
                    console.log('📏 AdaptiveCards: Using preferred height =', height);
                } else {
                    // Otherwise measure natural content height
                    height = Math.max(
                        document.documentElement.scrollHeight,
                        document.documentElement.offsetHeight,
                        document.body.scrollHeight,
                        document.body.offsetHeight
                    );
                    console.log('📏 AdaptiveCards: Measured natural height =', height);
                }
                
                window.webkit.messageHandlers.heightChanged.postMessage({
                    height: height,
                    timestamp: Date.now()
                });
            }
            
            // Initial height update
            updateHeight();
            
            // Observe DOM changes
            const observer = new ResizeObserver(function(entries) {
                updateHeight();
            });
            
            // Observe body and documentElement
            observer.observe(document.body);
            if (document.documentElement) {
                observer.observe(document.documentElement);
            }
            
            // Also listen to window resize
            window.addEventListener('resize', updateHeight);
            
            // Update on DOM content loaded
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', updateHeight);
            } else {
                updateHeight();
            }
            
            // Periodic check as fallback (every 1s for first 10s)
            let checkCount = 0;
            const intervalId = setInterval(function() {
                updateHeight();
                checkCount++;
                if (checkCount >= 10) {
                    clearInterval(intervalId);
                }
            }, 1000);
            
            console.log('OpenAI App: Height observer initialized, maxHeight:', window.oai.maxHeight);
            
            // Apply height styling if maxHeight is set
            \(preferredHeight != nil ? """
            (function applyHeightStyle() {
                const style = document.createElement('style');
                style.textContent = `
                    html, body {
                        height: \(preferredHeight!)px !important;
                        overflow: hidden !important;
                        margin: 0 !important;
                        padding: 0 !important;
                    }
                    body > div:first-child {
                        height: 100% !important;
                        overflow: auto !important;
                    }
                `;
                document.head.appendChild(style);
                console.log('OpenAI App: Applied simplified height style:', '\(preferredHeight!)px');
            })();
            """ : "")
        })();
        """
        
        let userScript = WKUserScript(
            source: heightScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(coordinator, name: "heightChanged")
        
        // Add console.log capture for debugging
        let consoleScript = """
        (function() {
            const originalLog = console.log;
            console.log = function(...args) {
                originalLog.apply(console, args);
                try {
                    window.webkit.messageHandlers.consoleLog.postMessage(
                        args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ')
                    );
                } catch(e) {
                    originalLog('Failed to send log to native:', e);
                }
            };
            
            const originalWarn = console.warn;
            console.warn = function(...args) {
                originalWarn.apply(console, args);
                try {
                    window.webkit.messageHandlers.consoleLog.postMessage(
                        '⚠️ ' + args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ')
                    );
                } catch(e) {}
            };
            
            const originalError = console.error;
            console.error = function(...args) {
                originalError.apply(console, args);
                try {
                    window.webkit.messageHandlers.consoleLog.postMessage(
                        '❌ ' + args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ')
                    );
                } catch(e) {}
            };
        })();
        """
        
        let consoleUserScript = WKUserScript(
            source: consoleScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(consoleUserScript)
        webView.configuration.userContentController.add(coordinator, name: "consoleLog")
    }
    
    /// Inject initial data into the web view
    private func injectInitialData(_ data: [String: Any], into webView: WKWebView) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("⚠️ WebViewContainer: Failed to serialize initial data")
            return
        }
        
        let dataScript = """
        (function() {
            window.adaptiveCardInitialData = \(jsonString);
            console.log('OpenAI App: Initial data injected');
        })();
        """
        
        let userScript = WKUserScript(
            source: dataScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(userScript)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebViewContainer
        private var lastReportedHeight: CGFloat = 0
        private var heightUpdateCount: Int = 0
        var hasLoadedInitialURL: Bool = false
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        // MARK: WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            print("🌐 WebViewContainer: Started loading")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            print("✅ WebViewContainer: Finished loading")
            
            // Request initial height after load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                    if let height = result as? CGFloat {
                        self.updateHeight(height)
                    }
                }
                
                // Debug: Check window.oai state after React components mount
                let debugScript = """
                console.log('🔍 AdaptiveCards: Post-load window.oai check');
                console.log('  window.oai:', JSON.stringify(window.oai, null, 2));
                console.log('  window.oai.maxHeight:', window.oai?.maxHeight);
                console.log('  window.oai.displayMode:', window.oai?.displayMode);
                console.log('  Document ready state:', document.readyState);
                console.log('  Body height:', document.body.scrollHeight);
                console.log('  Root div:', document.querySelector('body > div:first-child')?.getBoundingClientRect());
                
                // Check computed styles
                const rootDiv = document.querySelector('body > div:first-child');
                if (rootDiv) {
                    const styles = window.getComputedStyle(rootDiv);
                    console.log('  Root div computed styles:');
                    console.log('    height:', styles.height);
                    console.log('    max-height:', styles.maxHeight);
                    console.log('    overflow:', styles.overflow);
                    console.log('    display:', styles.display);
                    console.log('    flex:', styles.flex);
                }
                
                // Check carousel container
                const carousel = document.querySelector('.antialiased');
                if (carousel) {
                    const carouselRect = carousel.getBoundingClientRect();
                    const carouselStyles = window.getComputedStyle(carousel);
                    console.log('  Carousel container:');
                    console.log('    rect:', carouselRect);
                    console.log('    overflow-y:', carouselStyles.overflowY);
                    console.log('    flex:', carouselStyles.flex);
                }
                """
                webView.evaluateJavaScript(debugScript, completionHandler: nil)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            print("❌ WebViewContainer: Failed to load - \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            print("❌ WebViewContainer: Failed provisional navigation - \(error.localizedDescription)")
        }
        
        // MARK: WKScriptMessageHandler
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "heightChanged" {
                if let messageBody = message.body as? [String: Any],
                   let height = messageBody["height"] as? CGFloat {
                    updateHeight(height)
                } else if let height = message.body as? CGFloat {
                    updateHeight(height)
                }
            } else if message.name == "consoleLog" {
                if let logMessage = message.body as? String {
                    print("🌐 JS Console: \(logMessage)")
                }
            }
        }
        
        // MARK: Height Management
        
        private func updateHeight(_ newHeight: CGFloat) {
            // If preferred height is set, use it instead of dynamic height
            let targetHeight: CGFloat
            if let preferred = parent.preferredHeight {
                targetHeight = preferred
            } else {
                // Apply bounds for dynamic height
                targetHeight = min(max(newHeight, parent.minHeight), parent.maxHeight)
            }
            
            // Only update if changed significantly (avoid jitter)
            let heightDifference = abs(targetHeight - lastReportedHeight)
            guard heightDifference > 5.0 else { return }
            
            heightUpdateCount += 1
            lastReportedHeight = targetHeight
            
            let heightType = parent.preferredHeight != nil ? "preferred" : "dynamic"
            print("📏 WebViewContainer: Height update #\(heightUpdateCount) - \(Int(targetHeight))pt (\(heightType), raw: \(Int(newHeight))pt)")
            
            DispatchQueue.main.async {
                self.parent.contentHeight = targetHeight
                
                // Notify parent of height change after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.parent.onHeightChange?()
                }
            }
        }
    }
}

// MARK: - Full Screen Web View (No Height Restriction)

/// Full screen version of WebViewContainer for modal presentation
@available(iOS 15.0, *)
struct FullScreenWebView: UIViewRepresentable {
    /// URL to load
    let url: URL
    
    /// Optional authentication token
    let authToken: String?
    
    /// Loading state binding
    @SwiftUI.Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true // Allow scrolling in full screen
        webView.backgroundColor = .systemBackground
        
        // Add viewport and console logging injection for fullscreen
        injectFullscreenScripts(into: webView, coordinator: context.coordinator)
        
        return webView
    }
    
    /// Inject viewport meta tag and console logging for fullscreen
    private func injectFullscreenScripts(into webView: WKWebView, coordinator: Coordinator) {
        let fullscreenScript = """
        (function() {
            console.log('🚀 AdaptiveCards Fullscreen: Initializing');
            
            // Set viewport for mobile rendering
            let viewport = document.querySelector('meta[name="viewport"]');
            if (!viewport) {
                viewport = document.createElement('meta');
                viewport.name = 'viewport';
                viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
                document.head.appendChild(viewport);
                console.log('📱 AdaptiveCards Fullscreen: Added mobile viewport meta tag');
            }
            
            // Set OpenAI globals for fullscreen mode
            window.oai = window.oai || {};
            window.oai.displayMode = 'fullscreen';
            console.log('🎨 AdaptiveCards Fullscreen: Set displayMode = fullscreen');
        })();
        """
        
        let userScript = WKUserScript(
            source: fullscreenScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(userScript)
        
        // Add console.log capture
        let consoleScript = """
        (function() {
            const originalLog = console.log;
            console.log = function(...args) {
                originalLog.apply(console, args);
                try {
                    window.webkit.messageHandlers.consoleLog.postMessage(
                        args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ')
                    );
                } catch(e) {}
            };
        })();
        """
        
        let consoleUserScript = WKUserScript(
            source: consoleScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(consoleUserScript)
        webView.configuration.userContentController.add(coordinator, name: "consoleLog")
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load once - prevent reload loops from SwiftUI updates
        guard !context.coordinator.hasLoadedInitialURL else {
            return
        }
        
        context.coordinator.hasLoadedInitialURL = true
        
        var request = URLRequest(url: url)
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("AdaptiveCards-Mobile-iOS-Fullscreen", forHTTPHeaderField: "X-Client")
        
        print("🌐 FullScreenWebView: Loading URL: \(url.absoluteString)")
        webView.load(request)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Stop loading to prevent any pending operations
        uiView.stopLoading()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: FullScreenWebView
        var hasLoadedInitialURL: Bool = false
        
        init(_ parent: FullScreenWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            print("✅ FullScreenWebView: Finished loading")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
            print("❌ FullScreenWebView: Failed - \(error.localizedDescription)")
        }
        
        // MARK: WKScriptMessageHandler
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "consoleLog" {
                if let logMessage = message.body as? String {
                    print("🌐 Fullscreen JS Console: \(logMessage)")
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 15.0, *)
struct WebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Web View Container Preview")
                .font(.headline)
                .padding()
            
            WebViewContainer(
                url: URL(string: "https://www.example.com")!,
                authToken: nil,
                initialData: nil,
                contentHeight: .constant(400),
                isLoading: .constant(false),
                preferredHeight: nil
            )
            .frame(height: 400)
            .border(Color.gray, width: 1)
            .padding()
        }
    }
}
