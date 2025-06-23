import UIKit
import SwiftUI

@objc(AdaptiveCardsSharedSwift)
@objcMembers public class AdaptiveCardsSharedSwift: NSObject {
    public static let shared = AdaptiveCardsSharedSwift()
    
    public func testParse(path: String) {
        TestJSONParser().parseAllJSONFiles(in: path)
    }
    
    public func testController() -> UIViewController {
    // Create an instance of your SwiftUI ContentView
        if #available(iOS 15.0, *) {
            let contentView = ContentView()
           // Use a UIHostingController to wrap the SwiftUI view
           let hostingController = UIHostingController(rootView: contentView)

           // Return the UIHostingController to be displayed as a UIKit view controller
           return hostingController
        } else {
            fatalError()
        }
    }
    
    @available(iOS 15.0, *)
    public func parseView(payload: String) -> AnyView {
        guard let payloadData = payload.data(using: .utf8) else {
            debugPrint("unable to load payload data:\n\(payload)")
            return AnyView(ErrorView(message: "Unable to load payload data"))
        }

        do {
            let adaptiveCard = try JSONDecoder().decode(AdaptiveCard.self, from: payloadData)
            debugPrint("successfully loaded adaptive card payload data")
            
            // Return the SwiftUI AdaptiveCardView wrapped in AnyView
            return AnyView(AdaptiveCardView(adaptiveCard: adaptiveCard))
            
        } catch {
            debugPrint("unable to parse adaptive card payload: \(error)\n\(payload)")
            return AnyView(ErrorView(message: "Unable to parse adaptive card payload"))
        }
    }

    
    public func parse(payload: String) -> UIView {
        guard let payloadData = payload.data(using: .utf8) else {
            debugPrint("unable to load payload data:\n\(payload)")
            let testView = UIView(frame: .zero)
            testView.backgroundColor = .red
            return testView
        }
        
        do {
            let adaptiveCard = try JSONDecoder().decode(AdaptiveCard.self, from: payloadData)
            debugPrint("successfully loaded adaptive card payload data")
            
            // Create the SwiftUI view using the parsed AdaptiveCard
            if #available(iOS 15.0, *) {
                let adaptiveCardView = AdaptiveCardView(adaptiveCard: adaptiveCard)
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
            debugPrint("unable to parse adaptive card payload: \(error)\n\(payload)")
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
