// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import io.adaptivecards.objectmodel.AreaGridLayout
import io.adaptivecards.objectmodel.StringVector

/**
 * Utility methods for [AreaGridLayout]
 */
object AreaGridUtil {

    /**
     * Returns Area at row and column from [AreaGridLayout.GetAreas] vector
     * null if area is not available
     */
    fun AreaGridLayout.getAreaAt(row: Int, column: Int) = this.GetAreas().lastOrNull { it.GetRow()-1 == row && it.GetColumn()-1 == column }

    /**
     * Returns column vector from [AreaGridLayout]
     * if column vector is empty or no. of columns from [AreaGridLayout.GetAreas] vector doesn't match
     * [AreaGridLayout.GetColumns] length, it fills the remaining value with "auto" value
     */
    fun AreaGridLayout.getColumnsVectorWithAutoFill(): StringVector {
        val columnCount = this.getColumnsCount()
        val columns = StringVector()
        if(this.GetColumns() != null) {
            columns.addAll(this.GetColumns())
        }
        val remainingColumns = columnCount - columns.size
        for (i in 0 until remainingColumns) {
            columns.add(DEFAULT_COLUMN_WIDTH)
        }
        return columns
    }

    /**
     * Returns rows count based on max value of row in AreaGridLayout.areas vector
     */
    fun AreaGridLayout.getRowsCount(): Int {
        var rowCount = 0
        for (area in this.GetAreas()) {
            rowCount = if(area.GetRow() > rowCount) area.GetRow() else rowCount
        }
        return rowCount
    }

    /**
     * Returns columns count based on max value of columns in AreaGridLayout.areas vector
     */
    fun AreaGridLayout.getColumnsCount(): Int {
        var columnCount = 0
        for (area in this.GetAreas()){
            columnCount = if (area.GetColumn() > columnCount) area.GetColumn() else columnCount
        }
        return columnCount
    }

    fun String.isFixedWidth() = this.endsWith(PIXEL_SUFFIX)

    fun String.getFixedWidth() = if (this.isFixedWidth()) this.substring(0, this.length - PIXEL_SUFFIX.length).toInt() else 0

    fun  String.isAuto() = this.equals(DEFAULT_COLUMN_WIDTH)

    private const val PIXEL_SUFFIX = "px"
    const val DEFAULT_COLUMN_WIDTH = "auto"
}
