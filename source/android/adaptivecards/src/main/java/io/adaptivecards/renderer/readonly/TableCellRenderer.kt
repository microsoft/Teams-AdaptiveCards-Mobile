// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TableLayout
import androidx.core.view.updateLayoutParams
import androidx.fragment.app.FragmentManager
import com.google.android.flexbox.AlignItems
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.objectmodel.*
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.registration.CardRendererRegistration
import android.widget.TableRow as TableRowLayout

open class TableCellRenderArgs(renderArgs: RenderArgs, val table: Table, val tableLayout: TableLayout, val rowIndex: Int, val colIndex: Int, val gridStyle: ContainerStyle) : RenderArgs(renderArgs)

object TableCellRenderer : BaseCardElementRenderer() {
    override fun render(renderedCard: RenderedAdaptiveCard, context: Context, fragmentManager: FragmentManager, viewGroup: ViewGroup, baseCardElement: BaseCardElement, cardActionHandler: ICardActionHandler?, hostConfig: HostConfig, renderArgs: RenderArgs): View {
        if (renderArgs !is TableCellRenderArgs) throw IllegalArgumentException("renderArgs must be instance of TableCellRenderArgs")

        val row = renderArgs.table.GetRows()[renderArgs.rowIndex]
        val col = renderArgs.table.GetColumns()[renderArgs.colIndex]

        val cell = Util.castTo(baseCardElement, TableCell::class.java)

        val layoutToApply = getLayoutToApply(cell, hostConfig)
        val cellLayout = getAppropriateContainerForLayout(context, layoutToApply, cell)

        var stretch = false
        if (col.GetPixelWidth() != null) {
            // Pixel columns are fixed width
            cellLayout.updateLayoutParams<TableRowLayout.LayoutParams> { width = Util.dpToPixels(context, col.GetPixelWidth()!!.toFloat()) }
        } else if (col.GetWidth() != null) {
            // Weighted columns can stretch/shrink
            cellLayout.updateLayoutParams<TableRowLayout.LayoutParams> { weight = col.GetWidth()?.toFloat() ?: 1f }
            stretch = true
        }


        renderArgs.tableLayout.setColumnShrinkable(renderArgs.colIndex, stretch)
        renderArgs.tableLayout.setColumnStretchable(renderArgs.colIndex, stretch)

        val isFirst = renderArgs.colIndex == 0
        val isLast = renderArgs.colIndex == renderArgs.table.GetColumns().size - 1
        applyBorderOrSpacing(cellLayout, renderArgs.table.GetShowGridLines(), renderArgs.gridStyle, isFirst, isLast, cell.GetBleed(), hostConfig)
        applyRtl(cell.GetRtl(), cellLayout)
        setVisibility(cell.GetIsVisible(), cellLayout)
        setMinHeight(cell.GetMinHeight(), cellLayout, context)

        val computedStyle = ContainerRenderer.getLocalContainerStyle(cell, renderArgs.containerStyle)
        ContainerRenderer.applyPadding(computedStyle, renderArgs.containerStyle, cellLayout, hostConfig, renderArgs.table.GetShowGridLines())
        ContainerRenderer.applyContainerStyle(computedStyle, renderArgs.containerStyle, cellLayout, hostConfig)
        ContainerRenderer.applyVerticalContentAlignment(cellLayout,
                computeVerticalContentAlignment(cell.GetVerticalContentAlignment(), row, col, renderArgs.table), layoutToApply)
        ContainerRenderer.setSelectAction(renderedCard, cell.GetSelectAction(), cellLayout, cardActionHandler, renderArgs)

        CardRendererRegistration.getInstance().renderElements(renderedCard,
            context,
            fragmentManager,
            cellLayout,
            cell.GetItems(),
            cardActionHandler,
            hostConfig,
            RenderArgs(renderArgs).apply {
                containerStyle = computedStyle
                horizontalAlignment = computeHorizontalAlignment(row, col, renderArgs.table)
            },
            layoutToApply)

        ContainerRenderer.applyItemFillForFlowLayout(layoutToApply, cellLayout)

        viewGroup.addView(cellLayout)
        return cellLayout
    }

    /**
     * Configure how cell should appear distinct from adjacent cells: border, spacing, or no spacing (bleed)
     * @param cellLayout cell View to configure
     * @param showGridLines true if cell should show a border
     * @param borderStyle style to apply to border, if shown
     * @param isFirst true if first cell in its row
     * @param isLast true if last cell in its row
     * @param bleed true if cell should bleed into margins
     */
    private fun applyBorderOrSpacing(cellLayout: View, showGridLines: Boolean, borderStyle: ContainerStyle, isFirst: Boolean, isLast: Boolean, bleed: Boolean, hostConfig: HostConfig) {
        cellLayout.updateLayoutParams<ViewGroup.MarginLayoutParams> {
            if (showGridLines) {
                // For grid lines, draw rectangle
                cellLayout.background = GradientDrawable().apply {
                    shape = GradientDrawable.RECTANGLE
                    setColor(Color.TRANSPARENT)

                    // Use configured color for given border style
                    val color = Color.parseColor(hostConfig.GetBorderColor(borderStyle))
                    setStroke(Util.dpToPixels(cellLayout.context, 1f), color)
                }
            } else if (bleed) {
                // To bleed, set negative margins on first/last cells to cancel out parent's padding
                val padding = Util.dpToPixels(cellLayout.context, hostConfig.GetSpacing().paddingSpacing.toFloat())
                if (isFirst) marginStart = -padding
                if (isLast) marginEnd = -padding
            } else {
                // Otherwise, add spacing between cells
                val spacing = Util.dpToPixels(cellLayout.context, hostConfig.GetTable().cellSpacing.toFloat())
                if (!isFirst) marginStart = spacing / 2
                if (!isLast) marginEnd = spacing / 2
            }
        }
    }

    private fun computeVerticalContentAlignment(declaredAlignment: VerticalContentAlignment?, row: TableRow, col: TableColumnDefinition, table: Table): VerticalContentAlignment {
        // Innermost declaration overrides any outer declaration (cell > row > col > table > default)
        return declaredAlignment
                ?: row.GetVerticalCellContentAlignment()
                ?: col.GetVerticalCellContentAlignment()
                ?: table.GetVerticalCellContentAlignment()
                ?: VerticalContentAlignment.Top
    }

    private fun computeHorizontalAlignment(row: TableRow, col: TableColumnDefinition, table: Table): HorizontalAlignment {
        // Innermost declaration overrides any outer declaration (row > col > table > default)
        return row.GetHorizontalCellContentAlignment()
                ?: col.GetHorizontalCellContentAlignment()
                ?: table.GetHorizontalCellContentAlignment()
                ?: HorizontalAlignment.Left
    }

    /**
     * returns the layout to apply to the container
     */
    private fun getLayoutToApply(tableCell: TableCell, hostConfig: HostConfig): Layout {
        var layoutToApply = Layout()
        layoutToApply.SetLayoutContainerType(LayoutContainerType.Stack)
        layoutToApply.SetTargetWidth(TargetWidthType.Default)

        val hostWidthConfig = hostConfig.hostWidth
        val hostCardContainer = CardRendererRegistration.getInstance().hostCardContainer
        val hostWidth = Util.convertHostCardContainerToHostWidth(hostCardContainer, hostWidthConfig)
        val layouts = tableCell.GetLayouts()
        if (!layouts.isEmpty()) {
            for (i in layouts.indices) {
                val currentLayout = layouts[i]
                if (currentLayout.GetLayoutContainerType() == LayoutContainerType.None) {
                    continue
                }

                if (currentLayout.MeetsTargetWidthRequirement(hostWidth)) {
                    layoutToApply = currentLayout
                    break
                } else if (currentLayout.GetTargetWidth() == TargetWidthType.Default) {
                    layoutToApply = currentLayout
                }
            }
        }
        val layoutContainerType = layoutToApply.GetLayoutContainerType()
        return if ((layoutContainerType == LayoutContainerType.Flow && Util.isFlowLayoutEnabled()) ||
            (layoutContainerType == LayoutContainerType.AreaGrid && Util.isGridLayoutEnabled())
        ) {
            layoutToApply
        } else {
            Layout().apply {
                SetLayoutContainerType(LayoutContainerType.Stack)
                SetTargetWidth(TargetWidthType.Default)
            }
        }
    }

    private fun getAppropriateContainerForLayout(
        context: Context,
        layoutToApply: Layout,
        tableCell: TableCell
    ): ViewGroup {
        val layoutContainer: ViewGroup
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow) {
            val flexboxLayout = FlexboxLayout(context).apply {
                flexDirection = FlexDirection.ROW
                flexWrap = FlexWrap.WRAP
                tag = TagContent(tableCell)
                layoutParams = TableRowLayout.LayoutParams(0, TableLayout.LayoutParams.MATCH_PARENT)
                alignItems = AlignItems.CENTER
            }
            Util.setHorizontalAlignmentForFlowLayout(flexboxLayout, layoutToApply)
            layoutContainer = flexboxLayout
        } else if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.AreaGrid) {
            // not supported yet, return default stack layout
            val cellLayout = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                tag = TagContent(tableCell)
                layoutParams = TableRowLayout.LayoutParams(0, TableLayout.LayoutParams.MATCH_PARENT)
            }
            layoutContainer = cellLayout
        } else {
            val cellLayout = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                tag = TagContent(tableCell)
                layoutParams = TableRowLayout.LayoutParams(0, TableLayout.LayoutParams.MATCH_PARENT)
            }
            layoutContainer = cellLayout
        }
        return layoutContainer
    }
}