import SwiftUI
import Foundation

/// ViewModel for handling SwiftAdaptiveCards rendering and state management
@available(iOS 15.0, *)
class SwiftAdaptiveCardViewModel: ObservableObject {
    @Published var inputValues: [String: Any] = [:]
    @Published var showModalCard: SwiftAdaptiveCard?
    
    /// Binding for text input elements
    func bindingForInput(_ id: String, defaultValue: String = "") -> Binding<String> {
        return Binding(
            get: { [weak self] in
                return self?.inputValues[id] as? String ?? defaultValue
            },
            set: { [weak self] newValue in
                self?.inputValues[id] = newValue
            }
        )
    }
    
    /// Binding for number input elements
    func bindingForNumberInput(_ id: String, defaultValue: Double = 0) -> Binding<String> {
        return Binding(
            get: { [weak self] in
                if let number = self?.inputValues[id] as? Double {
                    return String(number)
                }
                return String(defaultValue)
            },
            set: { [weak self] newValue in
                if let number = Double(newValue) {
                    self?.inputValues[id] = number
                } else {
                    self?.inputValues[id] = defaultValue
                }
            }
        )
    }
    
    /// Binding for toggle input elements
    func bindingForToggleInput(_ id: String, defaultValue: Bool = false) -> Binding<Bool> {
        return Binding(
            get: { [weak self] in
                return self?.inputValues[id] as? Bool ?? defaultValue
            },
            set: { [weak self] newValue in
                self?.inputValues[id] = newValue
            }
        )
    }
    
    /// Binding for date input elements
    func bindingForDateInput(_ id: String, defaultValue: Date? = nil) -> Binding<Date> {
        return Binding(
            get: { [weak self] in
                if let dateString = self?.inputValues[id] as? String,
                   let date = ISO8601DateFormatter().date(from: dateString) {
                    return date
                }
                return defaultValue ?? Date()
            },
            set: { [weak self] newValue in
                let formatter = ISO8601DateFormatter()
                self?.inputValues[id] = formatter.string(from: newValue)
            }
        )
    }
    
    /// Handle action execution
    func handleAction(_ action: SwiftBaseActionElement) {
        let actionType = SwiftActionType(rawValue: action.typeString) ?? .unknownAction
        
        switch actionType {
        case .submit:
            if let submitAction = action as? SwiftSubmitAction {
                handleSubmitAction(submitAction)
            }
        case .openUrl:
            if let openUrlAction = action as? SwiftOpenUrlAction {
                handleOpenUrlAction(openUrlAction)
            }
        case .showCard:
            if let showCardAction = action as? SwiftShowCardAction {
                handleShowCardAction(showCardAction)
            }
        default:
            print("Unhandled action type: \(actionType)")
        }
    }
    
    private func handleSubmitAction(_ action: SwiftSubmitAction) {
        // Collect input values and handle submission
        print("Submit action triggered with data: \(inputValues)")
        // Add your submit logic here
    }
    
    private func handleOpenUrlAction(_ action: SwiftOpenUrlAction) {
        if let url = URL(string: action.url) {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    private func handleShowCardAction(_ action: SwiftShowCardAction) {
        if let card = action.card {
            showModalCard = card
        }
    }
    
    /// Get all input values for submission
    func getAllInputValues() -> [String: Any] {
        return inputValues
    }
    
    /// Clear all input values
    func clearInputValues() {
        inputValues.removeAll()
    }
}
