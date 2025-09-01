// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.utils.GridArea
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HorizontalItemsAlignment
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ItemFit
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.Spacing
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@kotlinx.serialization.Serializable
sealed class LayoutElement {

    @kotlinx.serialization.Serializable
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

    @kotlinx.serialization.Serializable
    class StackLayout(
    ): Layout()
}