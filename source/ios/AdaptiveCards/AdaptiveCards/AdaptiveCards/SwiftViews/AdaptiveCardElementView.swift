import SwiftUI
import AVKit

@available(iOS 15.0, *)
struct AdaptiveCardElementView: View {
    let element: SwiftBaseCardElement
    @EnvironmentObject var viewModel: SwiftAdaptiveCardViewModel

    var body: some View {
        renderElement()
    }
    
    @ViewBuilder
    private func renderElement() -> some View {
        switch element.type {
        case .textBlock, .image, .textInput, .numberInput:
            renderBasicElements()
        case .dateInput, .timeInput, .toggleInput, .choiceSetInput:
            renderInputElements()
        case .table, .media, .actionSet:
            renderComplexElements()
        case .container, .factSet, .columnSet, .imageSet:
            renderContainerElements()
        default:
            renderUnsupportedElement()
        }
    }
    
    @ViewBuilder
    private func renderBasicElements() -> some View {
        switch element.type {
        case .textBlock:
            if let textBlock = element as? SwiftTextBlock {
                textBlockView(textBlock)
            }
        case .image:
            if let image = element as? SwiftImage {
                imageView(image)
            }
        case .textInput:
            if let textInput = element as? SwiftTextInput {
                textInputView(textInput)
            }
        case .numberInput:
            if let numberInput = element as? SwiftNumberInput {
                numberInputView(numberInput)
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func renderInputElements() -> some View {
        switch element.type {
        case .dateInput:
            if let dateInput = element as? SwiftDateInput {
                dateInputView(dateInput)
            }
        case .timeInput:
            if let timeInput = element as? SwiftTimeInput {
                timeInputView(timeInput)
            }
        case .toggleInput:
            if let toggleInput = element as? SwiftToggleInput {
                toggleInputView(toggleInput)
            }
        case .choiceSetInput:
            if let choiceSetInput = element as? SwiftChoiceSetInput {
                choiceSetInputView(choiceSetInput)
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func renderComplexElements() -> some View {
        switch element.type {
        case .table:
            if let table = element as? SwiftTable {
                AdaptiveCardTableView(table: table)
                    .environmentObject(viewModel)
            }
        case .media:
            if let media = element as? SwiftMedia {
                mediaView(media)
            }
        case .actionSet:
            if let actionSet = element as? SwiftActionSet {
                actionSetView(actionSet)
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func renderContainerElements() -> some View {
        switch element.type {
        case .container:
            if let container = element as? SwiftContainer {
                containerView(container)
            }
        case .factSet:
            if let factSet = element as? SwiftFactSet {
                factSetView(factSet)
            }
        case .columnSet:
            if let columnSet = element as? SwiftColumnSet {
                columnSetView(columnSet)
            }
        case .imageSet:
            if let imageSet = element as? SwiftImageSet {
                imageSetView(imageSet)
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func renderUnsupportedElement() -> some View {
        Text("Unsupported element type: \(element.type.rawValue)")
            .foregroundColor(.gray)
            .italic()
    }
    
    // MARK: - Individual Element Views
    
    @ViewBuilder
    func textBlockView(_ textBlock: SwiftTextBlock) -> some View {
        Text(textBlock.text)
            .font(fontForSize(textBlock.textSize))
            .fontWeight(fontWeightFor(textBlock.textWeight))
            .multilineTextAlignment(alignmentForHorizontal(textBlock.horizontalAlignment))
            .lineLimit(textBlock.wrap ? (textBlock.maxLines > 0 ? Int(textBlock.maxLines) : nil) : 1)
            .fixedSize(horizontal: false, vertical: textBlock.wrap)
            .foregroundColor(colorFor(textBlock.textColor))
            .padding(.top, spacingValue(element.spacing))
            .padding(.bottom, spacingValue(element.spacing))
    }
    
    @ViewBuilder
    func imageView(_ image: SwiftImage) -> some View {
        if let url = URL(string: image.url) {
            AsyncImage(url: url) { loadedImage in
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize(for: image.imageSize), height: imageSize(for: image.imageSize))
                    .clipped()
            } placeholder: {
                ProgressView()
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func textInputView(_ textInput: SwiftTextInput) -> some View {
        TextField(textInput.label ?? textInput.id ?? "Text Input", 
                 text: viewModel.bindingForInput(textInput.id ?? "", defaultValue: textInput.value ?? ""))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    @ViewBuilder
    func numberInputView(_ numberInput: SwiftNumberInput) -> some View {
        TextField(numberInput.label ?? numberInput.id ?? "Number Input", 
                 text: viewModel.bindingForNumberInput(numberInput.id ?? "", defaultValue: numberInput.value ?? 0))
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    @ViewBuilder
    func dateInputView(_ dateInput: SwiftDateInput) -> some View {
        DatePicker(selection: viewModel.bindingForDateInput(dateInput.id ?? "", defaultValue: nil), 
                  displayedComponents: .date) {
            Text(dateInput.label ?? dateInput.id ?? "Date Input")
        }
        .padding()
    }
    
    @ViewBuilder
    func timeInputView(_ timeInput: SwiftTimeInput) -> some View {
        DatePicker(selection: viewModel.bindingForDateInput(timeInput.id ?? "", defaultValue: nil), 
                  displayedComponents: .hourAndMinute) {
            Text(timeInput.label ?? timeInput.id ?? "Time Input")
        }
        .padding()
    }
    
    @ViewBuilder
    func toggleInputView(_ toggleInput: SwiftToggleInput) -> some View {
        Toggle(isOn: viewModel.bindingForToggleInput(toggleInput.id ?? "", 
                                                    defaultValue: toggleInput.value == toggleInput.valueOn)) {
            Text(toggleInput.title ?? toggleInput.id ?? "Toggle")
        }
        .padding()
    }
    
    @ViewBuilder
    func choiceSetInputView(_ choiceSetInput: SwiftChoiceSetInput) -> some View {
        if choiceSetInput.isMultiSelect {
            Text("Multi-select choice sets are not yet implemented")
        } else {
            Picker(selection: viewModel.bindingForInput(choiceSetInput.id ?? "", defaultValue: choiceSetInput.value ?? ""), 
                  label: Text(choiceSetInput.label ?? choiceSetInput.id ?? "Choice Set")) {
                ForEach(choiceSetInput.choices.indices, id: \.self) { index in
                    let choice = choiceSetInput.choices[index]
                    Text(choice.title).tag(choice.value)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }
    
    @ViewBuilder
    func actionSetView(_ actionSet: SwiftActionSet) -> some View {
        ForEach(actionSet.actions.indices, id: \.self) { index in
            actionButton(for: actionSet.actions[index])
        }
    }
    
    @ViewBuilder
    func containerView(_ container: SwiftContainer) -> some View {
        VStack {
            ForEach(container.items.indices, id: \.self) { index in
                AdaptiveCardElementView(element: container.items[index])
                    .environmentObject(viewModel)
            }
        }
    }
    
    @ViewBuilder
    func factSetView(_ factSet: SwiftFactSet) -> some View {
        VStack(alignment: .leading) {
            ForEach(factSet.facts.indices, id: \.self) { index in
                let fact = factSet.facts[index]
                HStack(alignment: .top) {
                    Text(fact.title)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .leading)
                    Text(fact.value)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func columnSetView(_ columnSet: SwiftColumnSet) -> some View {
        HStack(alignment: .top, spacing: 0) {
            let totalWeight = columnSet.columns.reduce(0) { total, column in
                total + (columnWidthToWeight(column.width) ?? 1)
            }
            ForEach(columnSet.columns.indices, id: \.self) { index in
                let column = columnSet.columns[index]
                AdaptiveCardColumnView(column: column, totalWeight: totalWeight)
                    .environmentObject(viewModel)
            }
        }
    }
    
    @ViewBuilder
    func imageSetView(_ imageSet: SwiftImageSet) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
            ForEach(imageSet.images.indices, id: \.self) { index in
                let image = imageSet.images[index]
                imageView(image)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Views
    
    struct AdaptiveCardColumnView: View {
        let column: SwiftColumn
        let totalWeight: Int
        @EnvironmentObject var viewModel: SwiftAdaptiveCardViewModel

        var body: some View {
            let weight = columnWidthToWeight(column.width) ?? 1
            VStack(alignment: .leading, spacing: 0) {
                ForEach(column.items.indices, id: \.self) { index in
                    AdaptiveCardElementView(element: column.items[index])
                        .environmentObject(viewModel)
                }
            }
            .frame(maxWidth: .infinity)
            .layoutPriority(Double(weight))
        }
        
        func columnWidthToWeight(_ width: String?) -> Int? {
            guard let width = width else { return nil }
            let lowercasedWidth = width.lowercased()
            
            if lowercasedWidth == "auto" || lowercasedWidth == "stretch" {
                return 1
            } else if lowercasedWidth.hasSuffix("px") {
                let pixelValue = String(lowercasedWidth.dropLast(2))
                if let value = Int(pixelValue) {
                    return value / 10 // Convert pixels to a reasonable weight
                }
            } else if let value = Int(width) {
                return value // Direct weight value
            }
            
            return 1
        }
    }

    // MARK: - Helper Functions

    func fontForSize(_ size: SwiftTextSize?) -> Font {
        guard let size = size else { return .body }
        switch size {
        case .extraLarge:
            return .largeTitle
        case .large:
            return .title
        case .medium:
            return .title2
        case .small:
            return .body
        case .defaultSize:
            return .body
        }
    }
    
    func fontWeightFor(_ weight: SwiftTextWeight?) -> Font.Weight {
        guard let weight = weight else { return .regular }
        switch weight {
        case .defaultWeight:
            return .regular
        case .lighter:
            return .light
        case .bolder:
            return .bold
        }
    }
    
    func colorFor(_ color: SwiftForegroundColor?) -> Color {
        guard let color = color else { return .primary }
        switch color {
        case .default:
            return .primary
        case .dark:
            return .black
        case .light:
            return .gray
        case .accent:
            return .blue
        case .good:
            return .green
        case .warning:
            return .yellow
        case .attention:
            return .red
        }
    }

    func alignmentForHorizontal(_ alignment: SwiftHorizontalAlignment?) -> TextAlignment {
        guard let alignment = alignment else { return .leading }
        switch alignment {
        case .left:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }

    func spacingValue(_ spacing: SwiftSpacing) -> CGFloat {
        switch spacing {
        case .none:
            return 0
        case .small:
            return 4
        case .default:
            return 8
        case .medium:
            return 8
        case .large:
            return 16
        case .extraLarge:
            return 32
        case .padding:
            return 16
        }
    }

    func imageSize(for size: SwiftImageSize?) -> CGFloat {
        guard let size = size else { return 100 }
        switch size {
        case .none:
            return 100
        case .auto:
            return 100
        case .stretch:
            return UIScreen.main.bounds.width
        case .small:
            return 40
        case .medium:
            return 80
        case .large:
            return 160
        }
    }
    
    func columnWidthToWeight(_ width: String?) -> Int? {
        guard let width = width else { return nil }
        let lowercasedWidth = width.lowercased()
        
        if lowercasedWidth == "auto" || lowercasedWidth == "stretch" {
            return 1
        } else if lowercasedWidth.hasSuffix("px") {
            let pixelValue = String(lowercasedWidth.dropLast(2))
            if let value = Int(pixelValue) {
                return value / 10 // Convert pixels to a reasonable weight
            }
        } else if let value = Int(width) {
            return value // Direct weight value
        }
        
        return 1
    }
    
    @ViewBuilder
    func mediaView(_ media: SwiftMedia) -> some View {
        if let source = media.sources.first, let url = URL(string: source.url) {
            let player = AVPlayer(url: url)
            if let mimeType = source.mimeType, mimeType.starts(with: "video/") {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Text(media.altText ?? "")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .padding(),
                        alignment: .bottomLeading
                    )
            } else if let mimeType = source.mimeType, mimeType.starts(with: "audio/") {
                VStack {
                    if let posterUrl = media.poster, let imageUrl = URL(string: posterUrl) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    HStack {
                        Button(action: {
                            player.play()
                        }) {
                            Text("Play")
                        }
                        Button(action: {
                            player.pause()
                        }) {
                            Text("Pause")
                        }
                    }
                }
            } else {
                Text("Unsupported media type")
            }
        } else {
            Text("No media source available")
        }
    }

    @ViewBuilder
    func actionButton(for action: SwiftBaseActionElement) -> some View {
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
