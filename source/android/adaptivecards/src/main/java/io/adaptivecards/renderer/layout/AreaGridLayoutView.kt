// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.text.isDigitsOnly
import com.google.android.flexbox.AlignContent
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.objectmodel.AreaGridLayout
import io.adaptivecards.objectmodel.StringVector
import io.adaptivecards.renderer.AreaGridUtil.getAreaAt
import io.adaptivecards.renderer.AreaGridUtil.getColumnsVectorWithAutoFill
import io.adaptivecards.renderer.AreaGridUtil.getFixedWidth
import io.adaptivecards.renderer.AreaGridUtil.getMaxRowsCountFromAreas
import io.adaptivecards.renderer.AreaGridUtil.isAuto
import io.adaptivecards.renderer.AreaGridUtil.isFixedWidth
import io.adaptivecards.renderer.Util

/**
 * View that add FlexBoxLayout like a grid for
 * @AreaGridLayout type of container.
 */
class AreaGridLayoutView(context: Context) : FrameLayout(context) {

    var areaGridAlignContent: Int = AlignContent.FLEX_START

    lateinit var flexboxLayout: FlexboxLayout

    /**
     * Creates an empty grid based on @param layout properties
     */
    fun setUpAreaGrids(layout: AreaGridLayout){
        flexboxLayout = FlexboxLayout(context).apply {
            flexDirection = FlexDirection.ROW
            flexWrap = FlexWrap.WRAP
            this.alignContent = areaGridAlignContent
            layoutParams = FlexboxLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val rowCount = layout.getMaxRowsCountFromAreas()
        val columnsVector = layout.getColumnsVectorWithAutoFill()
        for (row in 0 until rowCount) {
            addColumns(row, flexboxLayout, layout, columnsVector)
        }
        addView(flexboxLayout)
    }

    /**
     * Adds columns for given @param row
     * adjusting columnWidth from @param columnVector
     */
    private fun addColumns(row: Int, flexboxLayout: FlexboxLayout, layout: AreaGridLayout, columnVector: StringVector) {
        val columnCount = columnVector.size
        var isNewRow = true
        // keeps tracks of the columnSpan, if columnSpan>1 then next [nextSkipColumnCount] views needs to be invisible
        // because FlexboxLayout covers that using flexGrow value.
        var nextSkipColumnCount = 0
        for (column in 0 until columnCount) {
            val frameLayout = FrameLayout(context)
            frameLayout.id = column
            flexboxLayout.addView(frameLayout)
            val params = FlexboxLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            layout.getAreaAt(row, column)?.let { area ->
                val areaName = area.GetName()
                frameLayout.setTag(areaName)
                params.apply {
                    isWrapBefore = isNewRow
                    isNewRow = false
                    params.adjustWidthFromColumnVector(columnVector[column], area.GetColumnSpan().toFloat())
                    nextSkipColumnCount = area.GetColumnSpan() - 1
                }
            }?:run{
                // If no area is specified for this cell
                frameLayout.setTag("r_$row c_$column")
                if (nextSkipColumnCount == 0) {
                    // this is an empty cell it needs to be visible and width should be based on column vector
                    //eg for area_row_column vector [area01 area02 area04] area03 is missing so it needs to be visible as an empty cell
                    params.adjustWidthFromColumnVector(columnVector[column], 1.0f)
                } else {
                    //this is an empty cell as previous column has expanded into it because of columnSpan
                    //it should be invisible
                    params.width = 0
                    nextSkipColumnCount--
                }

            }
            frameLayout.layoutParams = params
        }
    }

    private fun FlexboxLayout.LayoutParams.adjustWidthFromColumnVector(columnValue: String, columnSpan: Float){
        if(columnValue.isDigitsOnly()) {
            width = 0
            flexBasisPercent = columnValue.toFloat()/100f
        } else if(columnValue.isFixedWidth()) {
            width = Util.dpToPixels(flexboxLayout.context, columnValue.getFixedWidth())
        } else if(columnValue.isAuto()) {
            width = 0
            flexGrow = columnSpan
        } else {
            FlexboxLayout.LayoutParams.WRAP_CONTENT
        }
    }

    private fun addViewAtTheEnd(view: View) {
        flexboxLayout?.addView(view)
        val param = FlexboxLayout.LayoutParams(FlexboxLayout.LayoutParams.WRAP_CONTENT, FlexboxLayout.LayoutParams.WRAP_CONTENT)
        param.apply {
            width = 0
            flexGrow = 1.0f
        }
        view.layoutParams = param
    }

    fun addAreaView(view: View, areaName: String?, rowSpacing: Int, columnSpacing: Int) {
        this.findViewWithTag<FrameLayout?>(areaName)?.let { areaFrame ->
            val layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
            layoutParams.setMargins(rowSpacing, columnSpacing, rowSpacing, columnSpacing)
            view.layoutParams = layoutParams
            areaFrame.addView(view)
        } ?: run {
            addViewAtTheEnd(view)
        }
    }
}
