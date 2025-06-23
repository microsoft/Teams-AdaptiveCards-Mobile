import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardTableView: View {
    let table: TableComponent
    @EnvironmentObject var viewModel: AdaptiveCardViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(table.rows.indices, id: \.self) { rowIndex in
                let row = table.rows[rowIndex]
                tableRowView(row)
            }
        }
    }

    @ViewBuilder
    func tableRowView(_ row: TableRowComponent) -> some View {
        HStack(spacing: 0) {
            ForEach(row.cells.indices, id: \.self) { cellIndex in
                let cell = row.cells[cellIndex]
                let columnWidth = table.columns.indices.contains(cellIndex) ? table.columns[cellIndex].width : nil
                tableCellView(cell, columnWidth: columnWidth, row: row)
            }
        }
    }

    @ViewBuilder
    func tableCellView(_ cell: TableCell, columnWidth: Double?, row: TableRowComponent) -> some View {
        let horizontalAlignment = horizontalAlignmentFromString(
            cell.horizontalContentAlignment ??
            row.horizontalCellContentAlignment ??
            table.horizontalCellContentAlignment
        )

        let verticalAlignment = verticalAlignmentFromString(
            cell.verticalContentAlignment ??
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
        .border((table.showGridLines ?? true) ? Color.gray : Color.clear, width: (table.showGridLines ?? true) ? 1 : 0)
    }
    
    // Helper functions
    func horizontalAlignmentFromString(_ alignment: String?) -> HorizontalAlignment {
        switch alignment?.lowercased() {
        case "left":
            return .leading
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }

    func verticalAlignmentFromString(_ alignment: String?) -> VerticalAlignment {
        switch alignment?.lowercased() {
        case "top":
            return .top
        case "center":
            return .center
        case "bottom":
            return .bottom
        default:
            return .center
        }
    }
    
    func colorForStyle(_ style: String?) -> Color {
        switch style?.lowercased() {
        case "accent":
            return .blue.opacity(0.1)
        case "good":
            return .green.opacity(0.1)
        case "warning":
            return .yellow.opacity(0.1)
        case "attention":
            return .red.opacity(0.1)
        default:
            return .clear
        }
    }
}
