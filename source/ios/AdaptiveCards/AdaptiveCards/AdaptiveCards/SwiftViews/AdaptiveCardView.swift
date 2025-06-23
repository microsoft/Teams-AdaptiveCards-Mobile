import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardView: View {
    let adaptiveCard: AdaptiveCard
    @StateObject private var viewModel = AdaptiveCardViewModel()

    var body: some View {
        VStack {
            if let body = adaptiveCard.body {
                ForEach(body.indices, id: \.self) { index in
                    AdaptiveCardElementView(element: body[index])
                        .environmentObject(viewModel)
                }
            }
            if let actions = adaptiveCard.actions {
                ForEach(actions.indices, id: \.self) { index in
                    actionButton(for: actions[index])
                }
            }
        }
        .padding()
        .sheet(item: $viewModel.showModalCard) { card in
            AdaptiveCardView(adaptiveCard: card)
        }
    }

    @ViewBuilder
    func actionButton(for action: Action) -> some View {
        Button(action.title ?? "Action") {
            viewModel.handleAction(action)
        }
        .frame(maxWidth: .infinity) // Make the button take the full width of its container
        .padding(.horizontal, 20)  // Add horizontal padding to constrain the button size
        .padding(.vertical, 10)    // Add vertical padding for height
        .background(Color.blue)    // Button background color
        .foregroundColor(.white)   // Button text color
        .font(.system(size: 16, weight: .semibold)) // Text styling
        .cornerRadius(8)           // Rounded corners
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2) // Subtle shadow
    }
}
