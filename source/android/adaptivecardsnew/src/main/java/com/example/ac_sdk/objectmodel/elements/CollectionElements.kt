package com.example.ac_sdk.objectmodel.elements

import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class CollectionElement {
    @Serializable
    data class Container(
        val items: List<BaseCardElement>? = null,
        val width: String? = null,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null
    ) : StyledCollectionElement()

    @Serializable
    @SerialName("ColumnSet")
    data class ColumnSet(
        val columns: List<Column>? = null
    ) : StyledCollectionElement()

    @Serializable
    data class Column(
        val items: List<BaseCardElement>? = null,
        val width: String? = null
    ) : StyledCollectionElement()

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
    val rows: List<CardElements.TableRow>,
    val firstRowAsHeaders: Boolean? = null,
    val showGridLines: Boolean? = null,
    val gridStyle: String? = null,
    val horizontalCellContentAlignment: String? = null,
    val verticalCellContentAlignment: String? = null
) : CollectionCoreElement()


@Serializable
data class TableColumnDefinition(
    val width: String? = null
)