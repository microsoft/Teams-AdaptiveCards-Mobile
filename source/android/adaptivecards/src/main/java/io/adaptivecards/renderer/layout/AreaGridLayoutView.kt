package io.adaptivecards.renderer.layout

import android.content.Context
import android.util.Log
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.core.text.isDigitsOnly
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.objectmodel.AreaGridLayout
import io.adaptivecards.objectmodel.ColumnVector
import io.adaptivecards.objectmodel.GridArea
import io.adaptivecards.objectmodel.StringVector

class StretchableGridLayout(context: Context) : FrameLayout(context) {
    fun setUpGrids(layout: AreaGridLayout){
        val flexboxLayout = FlexboxLayout(context).apply {
            flexDirection = FlexDirection.ROW
            flexWrap = FlexWrap.WRAP
            layoutParams = FlexboxLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val rowCount = layout.getRowsCount()
        val columnsVector = layout.getColumnsVectorWithAutoFill()
        for (row in 0 until rowCount) {
            addColumns(row, flexboxLayout, layout, columnsVector)
        }
        addView(flexboxLayout)
    }

    private fun addColumns(row: Int, flexboxLayout: FlexboxLayout, layout: AreaGridLayout, columnVector: StringVector) {

        val columnCount = columnVector.size
        var isNewRow = true
        for (column in 0 until columnCount) {
            val frameLayout = FrameLayout(context)
            frameLayout.id = column
            flexboxLayout.addView(frameLayout)
            val params = FlexboxLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            layout.getAreaAt(row, column)?.let { area ->
                val areaName = area.GetName()
                frameLayout.setTag(areaName)
                params.apply {
                    val columnValue = columnVector[column]
                    isWrapBefore = isNewRow
                    isNewRow = false
                    width = when {
                        columnValue.isDigitsOnly() -> 0
                        columnValue.endsWith("px") -> columnValue.substring(
                            0,
                            columnValue.length - 2
                        ).toInt()

                        columnValue.equals("auto") -> 0
                        else -> FlexboxLayout.LayoutParams.WRAP_CONTENT
                    }
                    flexBasisPercent  = columnValue.isDigitsOnly() columnValue.toFloat() / 100f

                    if (columnValue.isDigitsOnly()) {
                        flexBasisPercent =
                    } else if (columnValue.equals("auto")) {
                        flexGrow = area?.GetColumnSpan()?.toFloat()
                    }
                }
            }?:run{
                params.width = 0
            }
            frameLayout.setTag("r_$row c_$column")
            frameLayout.layoutParams = params
        }
    }
    private fun AreaGridLayout.getAreaAt(row: Int, column: Int) = this.GetAreas().lastOrNull { it.GetRow()-1 == row && it.GetColumn()-1 == column }
    private fun AreaGridLayout.getColumnsVectorWithAutoFill(): StringVector {
        val columnCount = this.getColumnsCount()
        val columns = StringVector()
        if(this.GetColumns() != null) {
            columns.addAll(this.GetColumns())
        }
        val remainingColumns = columnCount - columns.size
        for (i in 0 until remainingColumns) {
            columns.add("auto")
        }
        return columns
    }
    private fun AreaGridLayout.getRowsCount(): Int {
        var rowCount = 0
        for (area in this.GetAreas()) {
            rowCount = if(area.GetRow() > rowCount) area.GetRow() else rowCount
        }
        return rowCount
    }

    private fun AreaGridLayout.getColumnsCount(): Int {
        var columnCount = 0
        for (area in this.GetAreas()){
            columnCount = if (area.GetColumn() > columnCount) area.GetColumn() else columnCount
        }
        return columnCount
    }

}