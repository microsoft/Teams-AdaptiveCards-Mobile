import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardTableView: View {
    let table: SwiftTable
    @EnvironmentObject var viewModel: SwiftAdaptiveCardViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(table.rows.indices, id: \.self) { rowIndex in
                let row = table.rows[rowIndex]
                tableRowView(row)
            }
        }
    }

    @ViewBuilder
    func tableRowView(_ row: SwiftTableRow) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(row.cells.enumerated()), id: \.offset) { cellIndex, cell in
                let columnWidth = table.columns.indices.contains(cellIndex) ? table.columns[cellIndex].width?.description : nil
                tableCellView(cell, columnWidth: columnWidth, row: row)
            }
        }
    }

    @ViewBuilder
    func tableCellView(_ cell: SwiftTableCell, columnWidth: String?, row: SwiftTableRow) -> some View {
        let horizontalAlignment = horizontalAlignmentFromEnum(
            row.horizontalCellContentAlignment ??
            table.horizontalCellContentAlignment
        )

        let verticalAlignment = verticalAlignmentFromEnum(
            row.verticalCellContentAlignment ??
            table.verticalCellContentAlignment
        )

        let alignment = Alignment(horizontal: horizontalAlignment, vertical: verticalAlignment)

        VStack(alignment: horizontalAlignment, spacing: 0) {
            ForEach(cell.items.indices, id: \.self) { itemIndex in
                AdaptiveCardElementView(element: cell.items[itemIndex])
                    .environmentObject(viewModel)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding()
        .background(colorForStyle(cell.style ?? row.style ?? table.gridStyle))
        .border((table.showGridLines) ? Color.gray : Color.clear, width: (table.showGridLines) ? 1 : 0)
    }
    
    // Helper functions
    func horizontalAlignmentFromEnum(_ alignment: SwiftHorizontalAlignment?) -> HorizontalAlignment {
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

    func verticalAlignmentFromEnum(_ alignment: SwiftVerticalContentAlignment?) -> VerticalAlignment {
        guard let alignment = alignment else { return .center }
        switch alignment {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }
    
    func colorForStyle(_ style: SwiftContainerStyle?) -> Color {
        guard let style = style else { return .clear }
        switch style {
        case .accent:
            return .blue.opacity(0.1)
        case .good:
            return .green.opacity(0.1)
        case .warning:
            return .yellow.opacity(0.1)
        case .attention:
            return .red.opacity(0.1)
        case .none:
            return .clear
        case .emphasis:
            return .gray.opacity(0.1)
        case .default:
            return .clear
        }
    }
}
