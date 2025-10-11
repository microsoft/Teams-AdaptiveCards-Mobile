import UIKit
import SwiftUI

@objc(AdaptiveCardsSharedSwift)
@objcMembers public class AdaptiveCardsSharedSwift: NSObject {
    public static let shared = AdaptiveCardsSharedSwift()
    
    public func testParse(path: String) {
        // TestJSONParser().parseAllJSONFiles(in: path)
        print("Test parse functionality not implemented - path: \(path)")
    }
    
    public func testController() -> UIViewController {
        // Create an instance of your SwiftUI ContentView
        if #available(iOS 15.0, *) {
            let contentView = SwiftAdaptiveCardsTestView()
            // Use a UIHostingController to wrap the SwiftUI view
            let hostingController = UIHostingController(rootView: contentView)
            
            // Return the UIHostingController to be displayed as a UIKit view controller
            return hostingController
        } else {
            fatalError("iOS 15.0 or later is required for SwiftAdaptiveCards")
        }
    }
    
    /// Creates a view controller specifically for testing SwiftAdaptiveCards rendering
    @available(iOS 15.0, *)
    public func swiftAdaptiveCardsTestController() -> UIViewController {
        let testView = SwiftAdaptiveCardsTestView()
        let hostingController = UIHostingController(rootView: testView)
        hostingController.title = "SwiftAdaptiveCards Test"
        return hostingController
    }
    
    @available(iOS 15.0, *)
    public func parseView(payload: String) -> AnyView {
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(payload, version: "1.0")
            debugPrint("successfully loaded SwiftAdaptiveCard payload data")
            
            // Return the SwiftUI AdaptiveCardView wrapped in AnyView
            return AnyView(AdaptiveCardView(adaptiveCard: parseResult.adaptiveCard))
            
        } catch {
            debugPrint("unable to parse SwiftAdaptiveCard payload: \(error)\n\(payload)")
            return AnyView(ErrorView(message: "Unable to parse adaptive card payload: \(error.localizedDescription)"))
        }
    }

    
    public func parse(payload: String) -> UIView {
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(payload, version: "1.0")
            debugPrint("successfully loaded SwiftAdaptiveCard payload data")
            
            // Create the SwiftUI view using the parsed SwiftAdaptiveCard
            if #available(iOS 15.0, *) {
                let adaptiveCardView = AdaptiveCardView(adaptiveCard: parseResult.adaptiveCard)
                // Wrap the SwiftUI view inside a UIHostingController
                let hostingController = UIHostingController(rootView: adaptiveCardView)
                
                // Set up the hosting controller's view
                let hostingView = hostingController.view
                hostingView?.backgroundColor = .clear // Optional: Set background if needed
                hostingView?.translatesAutoresizingMaskIntoConstraints = false
                
                return hostingView ?? UIView(frame: .zero)
            } else {
                // Fallback on earlier versions
                let errorView = UIView(frame: .zero)
                errorView.backgroundColor = .yellow
                return errorView
            }
            
        } catch {
            debugPrint("unable to parse SwiftAdaptiveCard payload: \(error)\n\(payload)")
            let errorView = UIView(frame: .zero)
            errorView.backgroundColor = .green
            return errorView
        }
    }
}

@available(iOS 15.0, *)
struct ErrorView: View {
    let message: String

    var body: some View {
        VStack {
            Text("Error")
                .font(.headline)
                .padding(.bottom, 10)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .background(Color.red.opacity(0.3))
        .cornerRadius(8)
    }
}

@available(iOS 15.0, *)
struct SwiftAdaptiveCardsTestView: View {
    @State private var selectedSample = 0
    @State private var customJSON = ""
    @State private var showingCustomInput = false
    
    private let sampleCards = [
        ("Simple Text", simpleTextCard),
        ("Text with Image", textWithImageCard),
        ("Input Form", inputFormCard),
        ("Fact Set", factSetCard),
        ("Table", tableCard),
        ("Custom JSON", "")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Sample Card", selection: $selectedSample) {
                    ForEach(0..<sampleCards.count, id: \.self) { index in
                        Text(sampleCards[index].0).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedSample == sampleCards.count - 1 {
                    // Custom JSON input
                    VStack {
                        Text("Enter Custom Adaptive Card JSON:")
                            .font(.headline)
                            .padding(.top)
                        
                        TextEditor(text: $customJSON)
                            .border(Color.gray, width: 1)
                            .frame(minHeight: 100)
                            .padding()
                        
                        Button("Render Custom Card") {
                            showingCustomInput = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else {
                    // Display selected sample card
                    ScrollView {
                        let cardJSON = sampleCards[selectedSample].1
                        if !cardJSON.isEmpty {
                            renderCard(json: cardJSON)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("SwiftAdaptiveCards Test")
            .sheet(isPresented: $showingCustomInput) {
                NavigationView {
                    ScrollView {
                        renderCard(json: customJSON)
                    }
                    .navigationTitle("Custom Card")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingCustomInput = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderCard(json: String) -> some View {
        if let parseResult = try? SwiftAdaptiveCard.deserializeFromString(json, version: "1.0") {
            AdaptiveCardView(adaptiveCard: parseResult.adaptiveCard)
                .padding()
        } else {
            ErrorView(message: "Failed to parse card")
                .padding()
        }
    }
}

// MARK: - Sample Card JSON Data

private let simpleTextCard = """
{
    "type": "AdaptiveCard",
    "version": "1.0",
    "body": [
        {
            "type": "TextBlock",
            "text": "Hello, SwiftAdaptiveCards!",
            "size": "large",
            "weight": "bolder"
        },
        {
            "type": "TextBlock",
            "text": "This is a simple text block rendered using the new SwiftAdaptiveCards framework.",
            "wrap": true
        }
    ]
}
"""

private let textWithImageCard = """
{
    "type": "AdaptiveCard",
    "version": "1.0",
    "body": [
        {
            "type": "TextBlock",
            "text": "Card with Image",
            "size": "large",
            "weight": "bolder"
        },
        {
            "type": "Image",
            "url": "https://via.placeholder.com/300x200",
            "size": "medium"
        },
        {
            "type": "TextBlock",
            "text": "This card demonstrates text and image elements.",
            "wrap": true
        }
    ]
}
"""

private let inputFormCard = """
{
    "type": "AdaptiveCard",
    "version": "1.0",
    "body": [
        {
            "type": "TextBlock",
            "text": "Input Form Example",
            "size": "large",
            "weight": "bolder"
        },
        {
            "type": "Input.Text",
            "id": "name",
            "label": "Your Name"
        },
        {
            "type": "Input.Number",
            "id": "age",
            "label": "Your Age"
        },
        {
            "type": "Input.Toggle",
            "id": "subscribe",
            "title": "Subscribe to newsletter",
            "valueOn": "yes",
            "valueOff": "no"
        }
    ],
    "actions": [
        {
            "type": "Action.Submit",
            "title": "Submit"
        }
    ]
}
"""

private let factSetCard = """
{
    "type": "AdaptiveCard",
    "version": "1.0",
    "body": [
        {
            "type": "TextBlock",
            "text": "System Information",
            "size": "large",
            "weight": "bolder"
        },
        {
            "type": "FactSet",
            "facts": [
                {
                    "title": "OS:",
                    "value": "iOS"
                },
                {
                    "title": "Framework:",
                    "value": "SwiftAdaptiveCards"
                },
                {
                    "title": "Version:",
                    "value": "1.0"
                }
            ]
        }
    ]
}
"""

private let tableCard = """
{
    "type": "AdaptiveCard",
    "version": "1.0",
    "body": [
        {
            "type": "TextBlock",
            "text": "Table Example",
            "size": "large",
            "weight": "bolder"
        },
        {
            "type": "Table",
            "columns": [
                {
                    "width": 1
                },
                {
                    "width": 1
                }
            ],
            "rows": [
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Name",
                                    "weight": "bolder"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Value",
                                    "weight": "bolder"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Framework"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "SwiftAdaptiveCards"
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
"""
