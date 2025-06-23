import SwiftUI

/// SwiftUI view for rendering Chain of Thought UX
@available(iOS 15.0, *)
struct ChainOfThoughtView: View {
    let data: ChainOfThoughtData
    @State private var isExpanded = true  // Start expanded by default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with state and expand/collapse
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    
                    Text(data.state)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Chain of thought entries
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(data.entries.enumerated()), id: \.offset) { index, entry in
                        ChainOfThoughtEntryView(
                            entry: entry,
                            isCompleted: data.isDone || index < data.entries.count - 1,
                            isLast: index == data.entries.count - 1
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 15.0, *)
struct ChainOfThoughtEntryView: View {
    let entry: ChainOfThoughtEntry
    let isCompleted: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? Color.green : Color.orange)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 32)
                        .padding(.top, 4)
                }
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 8) {
                // Header with app info
                HStack(alignment: .center) {
                    Text(entry.header)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if let appInfo = entry.appInfo {
                        HStack(spacing: 4) {
                            AsyncImage(url: URL(string: appInfo.icon)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 16, height: 16)
                            
                            Text(appInfo.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .layoutPriority(1)
                    }
                }
                
                // Content
                Text(entry.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 15.0, *)
struct ChainOfThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = ChainOfThoughtData(
            entries: [
                ChainOfThoughtEntry(
                    header: "Getting tasks with",
                    content: "Starting to pull together relevant sources",
                    appInfo: AppInfo(
                        name: "Asana",
                        icon: "https://res.cdn.office.net/teamsappdata/evergreen-assets/apps/f0e33e18-08fc-4511-a2a7-c6bdff367263_largeImage.png?v=1.2.3"
                    )
                ),
                ChainOfThoughtEntry(
                    header: "Understanding task details like title and assignee",
                    content: "The user provided a structured breakdown for a report on the Researcher agent within Microsoft 365 Copilot, outlining specific sub-questions and terms.",
                    appInfo: nil
                ),
                ChainOfThoughtEntry(
                    header: "Generating ticket status summary...",
                    content: "Compiling the final summary based on all gathered information.",
                    appInfo: nil
                )
            ],
            state: "Thought for 1 min",
            isDone: true
        )
        
        ChainOfThoughtView(data: sampleData)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
