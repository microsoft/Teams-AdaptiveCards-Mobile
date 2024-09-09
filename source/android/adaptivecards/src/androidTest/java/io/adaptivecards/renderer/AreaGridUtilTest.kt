// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import io.adaptivecards.objectmodel.AreaGridLayout
import io.adaptivecards.objectmodel.GridArea
import io.adaptivecards.objectmodel.GridAreaVector
import io.adaptivecards.objectmodel.StringVector
import io.adaptivecards.renderer.AreaGridUtil.getAreaAt
import io.adaptivecards.renderer.AreaGridUtil.getColumnsVectorWithAutoFill
import io.adaptivecards.renderer.AreaGridUtil.getFixedWidth
import io.adaptivecards.renderer.AreaGridUtil.getMaxRowsCountFromAreas
import io.adaptivecards.renderer.AreaGridUtil.isAuto
import io.adaptivecards.renderer.AreaGridUtil.isFixedWidth
import junit.framework.TestCase
import org.junit.Test

/**
 * Unit test for [AreaGridUtil]
 */
class AreaGridUtilTest : TestCase() {

    @Test
    fun test_getAreaAt_for_existing_area_should_return_area(){
        val area = mock_AreaGridLayout(mock_ColumnVector(), mock_GridAreaVector()).getAreaAt(1,1)
        assertNotNull(area)
        assertEquals("one_one", area?.GetName())
    }

    @Test
    fun test_getAreaAt_for_non_existing_area_should_return_null(){
        val area = mock_AreaGridLayout(mock_ColumnVector(), mock_GridAreaVector()).getAreaAt(2,1)
        assertNull(area)
    }

    @Test
    fun test_getColumnsVectorWithAutoFill_empty_column_should_return_auto(){
        val columnsVector = mock_AreaGridLayout(StringVector(), mock_GridAreaVector()).getColumnsVectorWithAutoFill()
        assertNotNull(columnsVector)
        assertTrue(columnsVector.isNotEmpty())
        assertEquals(3, columnsVector.size)
        assertEquals(AreaGridUtil.DEFAULT_COLUMN_WIDTH, columnsVector[0])
    }

    @Test
    fun test_getColumnsVectorWithAutoFill_column_should_return_values(){
        val columnsVector = mock_AreaGridLayout(mock_ColumnVector(), mock_GridAreaVector()).getColumnsVectorWithAutoFill()
        assertNotNull(columnsVector)
        assertTrue(columnsVector.isNotEmpty())
        assertEquals(3, columnsVector.size)
        assertEquals("35", columnsVector[0])
    }

    @Test
    fun test_getRowsCount_should_return_max_row(){
        val areaGridLayout = mock_AreaGridLayout(mock_ColumnVector(), mock_GridAreaVector())
        assertEquals(2, areaGridLayout.getMaxRowsCountFromAreas())
    }

    @Test
    fun test_getColumnCount_should_return_max_row(){
        val areaGridLayout = mock_AreaGridLayout(mock_ColumnVector(), mock_GridAreaVector())
        assertEquals(3, areaGridLayout.getMaxRowsCountFromAreas())
    }

    @Test
    fun test_getColumnCount_with_empty_column_should_return_max_row(){
        val areaGridLayout = mock_AreaGridLayout(StringVector(), mock_GridAreaVector())
        assertEquals(3, areaGridLayout.getMaxRowsCountFromAreas())
    }

    @Test
    fun test_isFixedWidth(){
        assertTrue("100px".isFixedWidth())
        assertFalse("35".isFixedWidth())
        assertFalse("auto".isFixedWidth())
    }

    @Test
    fun test_isAuto(){
        assertTrue("auto".isAuto())
        assertFalse("35".isFixedWidth())
        assertFalse("100px".isFixedWidth())
    }

    @Test
    fun test_getFixedWidth(){
        assertEquals(100, "100px".getFixedWidth())
        assertEquals(0, "35".getFixedWidth())
        assertEquals(0, "auto".getFixedWidth())
    }

    fun mock_AreaGridLayout(columnVector: StringVector, areaVector: GridAreaVector): AreaGridLayout{
        val areaGridLayout = AreaGridLayout()
        areaGridLayout.SetAreas(areaVector)
        areaGridLayout.SetColumns(columnVector)
        return areaGridLayout
    }

    fun mock_ColumnVector() : StringVector {
        val columnVector = StringVector()
        columnVector.add("35")
        columnVector.add("100px")
        columnVector.add("auto")
        return columnVector
    }

    fun mock_GridAreaVector(): GridAreaVector {
        val areasVector = GridAreaVector()
        areasVector.add(mock_gridArea(0, 0, "zero_zero"))
        areasVector.add(mock_gridArea(0, 1, "zero_one"))
        areasVector.add(mock_gridArea(0, 2, "zero_two"))
        areasVector.add(mock_gridArea(1, 0, "one_zero"))
        areasVector.add(mock_gridArea(1, 1, "one_one"))
        return areasVector
    }

    fun mock_gridArea(row: Int, column: Int, name: String): GridArea {
        return GridArea().apply {
            SetColumn(column+1)
            SetColumn(row+1)
            SetName(name)
        }
    }
}