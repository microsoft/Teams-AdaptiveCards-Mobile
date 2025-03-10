package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.parser.ParseWarning
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.Util
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
        val rtl: Boolean? = null
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
    data class Column(
        var width: String = "auto",
        var pixelWidth: Int = 0,
        var items: List<BaseCardElement> = emptyList(),
        var rtl: Boolean? = null,
        var layouts: List<Layout> = emptyList()
    ) : StyledCollectionElement() {

        // In Kotlin, you can add helper methods if needed (e.g. a setter that sets pixelWidth based on width)
        fun setWidth(value: String, warnings: MutableList<ParseWarning>? = null) {
            width = value.lowercase()
            pixelWidth = Util.parseSizeForPixelSize(width, warnings) ?: 0
        }

        fun setExplicitPixelWidth(value: Int) {
            pixelWidth = value
            width = "${value}px"
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
        val rtl: Boolean? = null
    ) : StyledCollectionElement()
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
    val width: String? = null
)