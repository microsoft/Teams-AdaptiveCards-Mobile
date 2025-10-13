//
//  OpenAIAppView.swift
//  AdaptiveCards
//
//  Created on 10/12/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import SwiftUI

/// SwiftUI view for rendering OpenAI embedded applications
/// Supports inline and full screen modes with collapsible state
@available(iOS 15.0, *)
struct OpenAIAppView: View {
    /// App configuration data
    let appData: OpenAIAppData
    
    /// Callback when view height changes
    var onHeightChange: (() -> Void)? = nil
    
    /// Collapsed/expanded state
    @State private var isCollapsed: Bool = true
    
    /// Loading state
    @State private var isLoading: Bool = false
    
    /// Current content height for inline view
    @State private var contentHeight: CGFloat = 300
    
    /// Full screen modal presentation
    @State private var showFullScreen: Bool = false
    
    /// Error state
    @State private var loadError: String? = nil
    
    var body: some View {
        Group {
            if !isCollapsed {
                expandedInlineView
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                collapsedAppPlaceholder
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isCollapsed)
        .animation(.easeInOut(duration: 0.25), value: contentHeight)
        .onAppear {
            ACDiagnosticLogger.log("OpenAIAppView appeared - App: \(appData.appName)", category: "Lifecycle")
        }
        .onChange(of: isCollapsed) { newValue in
            ACDiagnosticLogger.log("State changed - isCollapsed: \(newValue)", category: "Lifecycle")
            // Trigger height recalculation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onHeightChange?()
            }
        }
        .onChange(of: showFullScreen) { newValue in
            ACDiagnosticLogger.log("State changed - showFullScreen: \(newValue)", category: "Lifecycle")
            // When returning from fullscreen, force layout update
            if !newValue {
                ACDiagnosticLogger.log("Returned from fullscreen, forcing layout update", category: "Lifecycle")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onHeightChange?()
                }
            }
        }
        .onChange(of: contentHeight) { newHeight in
            ACDiagnosticLogger.log("Content height changed to: \(newHeight)pt", category: "Rendering")
            onHeightChange?()
        }
        .sheet(isPresented: $showFullScreen) {
            OpenAIAppFullScreenView(appData: appData)
                .onDisappear {
                    ACDiagnosticLogger.log("Fullscreen dismissed", category: "Lifecycle")
                }
        }
    }
    
    // MARK: - Collapsed View
    
    @ViewBuilder
    private var collapsedAppPlaceholder: some View {
        Button(action: {
            ACDiagnosticLogger.log("Expanding app: \(appData.appName)", category: "Lifecycle")
            withAnimation(.easeInOut(duration: 0.3)) {
                isCollapsed = false
            }
            
            // Notify height change after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                onHeightChange?()
            }
        }) {
            HStack(spacing: 12) {
                // App icon
                if let iconUrl = appData.appIconUrl {
                    AsyncImage(url: URL(string: iconUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        appIconPlaceholder
                    }
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
                } else {
                    appIconPlaceholder
                }
                
                // App info
                VStack(alignment: .leading, spacing: 4) {
                    Text(appData.appName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Tap to open embedded app")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Expand icon
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var appIconPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.blue.opacity(0.2))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "app.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            )
    }
    
    // MARK: - Expanded Inline View
    
    @ViewBuilder
    private var expandedInlineView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            appHeader
            
            // Error display (if any)
            if let error = loadError {
                errorView(message: error)
            } else {
                // Web content
                inlineWebContent
            }
            
            // Footer with actions
            appFooter
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var appHeader: some View {
        HStack(spacing: 12) {
            // App icon (smaller in header)
            if let iconUrl = appData.appIconUrl {
                AsyncImage(url: URL(string: iconUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    appIconPlaceholder
                }
                .frame(width: 24, height: 24)
                .cornerRadius(4)
            }
            
            // App name
            Text(appData.appName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Loading indicator
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            // Collapse button
            Button(action: {
                ACDiagnosticLogger.log("Collapsing app: \(appData.appName)", category: "Lifecycle")
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onHeightChange?()
                }
            }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder
    private var inlineWebContent: some View {
        WebViewContainer(
            url: appData.embedUrl,
            authToken: appData.authToken,
            initialData: appData.initialData,
            contentHeight: $contentHeight,
            isLoading: $isLoading,
            onHeightChange: onHeightChange
        )
        .frame(maxWidth: .infinity)
        .frame(height: contentHeight)
        .clipped()
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var appFooter: some View {
        HStack(spacing: 12) {
            // Full screen button
            Button(action: {
                ACDiagnosticLogger.log("Opening fullscreen for app: \(appData.appName)", category: "Lifecycle")
                showFullScreen = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .medium))
                    Text("Full Screen")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showFullScreen) {
                OpenAIAppFullScreenView(appData: appData)
            }
            
            Spacer()
            
            // App ID (debug info)
            Text("ID: \(appData.appId)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Failed to Load")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Full Screen View

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
                    authToken: appData.authToken,
                    isLoading: $isLoading
                )
                
                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Loading \(appData.appName)...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle(appData.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                            Text("Close")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let iconUrl = appData.appIconUrl {
                        AsyncImage(url: URL(string: iconUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            EmptyView()
                        }
                        .frame(width: 24, height: 24)
                        .cornerRadius(4)
                    }
                }
            }
        }
    }
}

// MARK: - Multi-App Container

/// Container view for rendering multiple OpenAI apps
@available(iOS 15.0, *)
struct OpenAIAppsContainerView: View {
    let apps: [OpenAIAppData]
    var onHeightChange: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            if apps.count > 1 {
                HStack {
                    Image(systemName: "app.connected.to.app.below.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    
                    Text("Embedded Apps (\(apps.count))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 4)
            }
            
            // Individual app views
            ForEach(Array(apps.enumerated()), id: \.offset) { index, app in
                OpenAIAppView(
                    appData: app,
                    onHeightChange: onHeightChange
                )
            }
        }
    }
}

// MARK: - Previews

@available(iOS 15.0, *)
struct OpenAIAppView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Single app
                OpenAIAppView(appData: OpenAIAppData(
                    appId: "figma-123",
                    appName: "Figma",
                    appIconUrl: "https://logo.clearbit.com/figma.com",
                    embedUrl: URL(string: "https://www.figma.com/embed?embed_host=teams")!,
                    renderMode: .inline
                ))
                
                // Multiple apps
                OpenAIAppsContainerView(apps: [
                    OpenAIAppData(
                        appId: "figma-1",
                        appName: "Figma Design A",
                        appIconUrl: "https://logo.clearbit.com/figma.com",
                        embedUrl: URL(string: "https://www.figma.com/embed/a")!
                    ),
                    OpenAIAppData(
                        appId: "canva-1",
                        appName: "Canva Presentation",
                        appIconUrl: "https://logo.clearbit.com/canva.com",
                        embedUrl: URL(string: "https://www.canva.com/embed/b")!
                    )
                ])
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
