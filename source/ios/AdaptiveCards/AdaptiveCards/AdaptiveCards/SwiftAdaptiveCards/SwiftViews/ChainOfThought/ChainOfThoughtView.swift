import SwiftUI

/// SwiftUI view for rendering Chain of Thought UX
@available(iOS 15.0, *)
struct ChainOfThoughtView: View {
    let data: ChainOfThoughtData
    @State private var expandedSteps = Set<Int>()
    var onHeightChange: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with state (non-collapsible)
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                Text(data.state)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Chain of thought entries
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(data.entries.enumerated()), id: \.offset) { index, entry in
                    ChainOfThoughtEntryView(
                        entry: entry,
                        stepIndex: index,
                        isCompleted: data.isDone || index < data.entries.count - 1,
                        isLast: index == data.entries.count - 1,
                        isExpanded: expandedSteps.contains(index),
                        onToggleExpanded: {
                            // Notify immediately before animation
                            onHeightChange?()
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if expandedSteps.contains(index) {
                                    expandedSteps.remove(index)
                                } else {
                                    expandedSteps.insert(index)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            // Start with the first step expanded
            if !data.entries.isEmpty {
                expandedSteps.insert(0)
            }
        }
        .onChange(of: expandedSteps) { _ in
            // Notify of layout changes when expansion state changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                onHeightChange?()
            }
        }
    }
}

@available(iOS 15.0, *)
struct ChainOfThoughtEntryView: View {
    let entry: ChainOfThoughtEntry
    let stepIndex: Int
    let isCompleted: Bool
    let isLast: Bool
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    
    // Pre-calculate text height to prevent layout changes during animation
    @State private var titleHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step header with checkmark and chevron (always visible)
            Button(action: onToggleExpanded) {
                HStack(alignment: .top, spacing: 12) {
                    // Status indicator with connecting line
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if !isLast {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2, height: 24)
                                .padding(.top, 4)
                        }
                    }
                    .frame(width: 12)
                    
                    // Header content
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center) {
                            // Use overlay to measure text height and prevent reflow
                            Text(entry.header)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(height: titleHeight > 0 ? titleHeight : nil, alignment: .top)
                                .background(
                                    // Hidden text for measuring
                                    Text(entry.header)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .background(GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    if titleHeight == 0 {
                                                        titleHeight = geometry.size.height
                                                    }
                                                }
                                        })
                                        .hidden()
                                )
                            
                            Spacer()
                            
                            // App info (if available)
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
                            }
                            
                            // Chevron
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 8)
            
            // Expanded content
            if isExpanded {
                HStack(alignment: .top, spacing: 12) {
                    // Spacer to align with content
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 12)
                        
                        if !isLast {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2)
                        }
                    }
                    .frame(width: 12)
                    
                    // Content
                    Text(entry.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.98, anchor: .top)),
                    removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.98, anchor: .top))
                ))
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
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
                    content: "Starting to pull together relevant sources from Asana to understand current task assignments and priorities.",
                    appInfo: AppInfo(
                        name: "Asana",
                        icon: "https://res.cdn.office.net/teamsappdata/evergreen-assets/apps/f0e33e18-08fc-4511-a2a7-c6bdff367263_largeImage.png?v=1.2.3"
                    )
                ),
                ChainOfThoughtEntry(
                    header: "Understanding task details like title and assignee",
                    content: "The user provided a structured breakdown for a report on the Researcher agent within Microsoft 365 Copilot, outlining specific sub-questions and terms that need to be addressed in the analysis.",
                    appInfo: nil
                ),
                ChainOfThoughtEntry(
                    header: "Generating ticket status summary...",
                    content: "Compiling the final summary based on all gathered information from various sources to provide a comprehensive overview.",
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
