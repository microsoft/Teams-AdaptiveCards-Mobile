// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.Util
import com.example.ac_sdk.objectmodel.serializer.WidthSerializer
import com.example.ac_sdk.objectmodel.utils.PageAnimation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class CollectionElement {
    @Serializable
    @SerialName("Container")
    data class Container(
        val items: List<BaseCardElement>? = null,
        val width: String? = null,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null,
        val layouts: List<Layout>? = null
    ) : StyledCollectionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.ITEMS,
                        AdaptiveCardSchemaKey.SELECT_ACTION,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.VERTICAL_CONTENT_ALIGNMENT,
                        AdaptiveCardSchemaKey.BLEED,
                        AdaptiveCardSchemaKey.BACKGROUND_IMAGE,
                        AdaptiveCardSchemaKey.MIN_HEIGHT,
                        AdaptiveCardSchemaKey.RTL
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("ColumnSet")
    data class ColumnSet(
        val columns: List<Column>? = null
    ) : StyledCollectionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.BLEED,
                        AdaptiveCardSchemaKey.COLUMNS,
                        AdaptiveCardSchemaKey.SELECT_ACTION,
                        AdaptiveCardSchemaKey.STYLE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Column")
    data class Column(
        @Serializable(with = WidthSerializer::class)
        var width: String = "Auto",
        var pixelWidth: Int = 0,
        var items: List<BaseCardElement> = emptyList(),
        var rtl: Boolean? = null,
        var layouts: List<Layout> = emptyList()
    ) : StyledCollectionElement() {

        init {
            setFlexibleWidth(width)
        }
        // In Kotlin, you can add helper methods if needed (e.g. a setter that sets pixelWidth based on width)
        private fun setFlexibleWidth(value: String) {
            width = value.lowercase()
            pixelWidth = Util.parseSizeForPixelSize(width, null) ?: 0
        }

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.WIDTH,
                        AdaptiveCardSchemaKey.RTL,
                        AdaptiveCardSchemaKey.LAYOUTS
                    )
                )
            }
        }
    }

    @Serializable
    data class TableCell(
        val items: List<BaseCardElement>? = null,
        val width: String? = null,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null,
        val layouts: List<Layout>? = null
    ) : StyledCollectionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.WIDTH,
                        AdaptiveCardSchemaKey.BLEED,
                        AdaptiveCardSchemaKey.RTL
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("CarouselPage")
    data class CarouselPage(
        val items: List<BaseCardElement> = emptyList(),
        val layouts: List<Layout> = emptyList(),
        val rtl: Boolean? = null
    ) : StyledCollectionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.LAYOUTS,
                        AdaptiveCardSchemaKey.RTL
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Carousel")
    data class Carousel(
        val pages: List<CarouselPage> = emptyList(),
        val pageAnimation: PageAnimation = PageAnimation.SLIDE
    ) : StyledCollectionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.PAGES,
                        AdaptiveCardSchemaKey.PAGE_ANIMATION
                    )
                )
            }
        }
    }

}


@Serializable
@SerialName("Table")
data class Table(
    val columns: List<TableColumnDefinition>,
    val rows: List<CardElement.TableRow>,
    val firstRowAsHeaders: Boolean? = null,
    val showGridLines: Boolean? = null,
    val gridStyle: String? = null,
    val horizontalCellContentAlignment: String? = null,
    val verticalCellContentAlignment: String? = null,
) : CollectionCoreElement()


@Serializable
data class TableColumnDefinition(
    @Serializable(with = WidthSerializer::class)
    val width: String? = null
)