// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.GridArea
import com.example.ac_sdk.objectmodel.utils.HorizontalItemsAlignment
import com.example.ac_sdk.objectmodel.utils.ItemFit
import com.example.ac_sdk.objectmodel.utils.Spacing
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class LayoutElement {

    @Serializable
    @SerialName("Layout.Flow")
    class FlowLayout (
        val itemFit: ItemFit = ItemFit.Fit,
        val itemWidth: String? = null,
        val minItemWidth: String? = null,
        val maxItemWidth: String? = null,
        val pixelItemWidth: Int = 0,
        val itemMinPixelWidth: Int = 0,
        val itemMaxPixelWidth: Int = 0,
        val rowSpacing: Spacing = Spacing.DEFAULT,
        val columnSpacing: Spacing = Spacing.DEFAULT,
        val horizontalItemsAlignment: HorizontalItemsAlignment = HorizontalItemsAlignment.CENTER
    ): Layout()

    @Serializable
    @SerialName("Layout.Grid")
    class AreaGridLayout(
        val rowSpacing: Spacing = Spacing.DEFAULT,
        val columnSpacing: Spacing = Spacing.DEFAULT,
        val columns: List<String> = emptyList(),
        val areas: List<GridArea> = emptyList()
    ): Layout()

    @Serializable
    class StackLayout(
    ): Layout()
}