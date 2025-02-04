package io.adaptivecards.parser.elements

import kotlinx.serialization.Serializable

@Serializable
sealed class ContainerElement {
    @Serializable
    data class Container(
        val items: List<BaseCardElement>? = null,
        val width: String? = null,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null
    ) : StyledCollectionElement()

    @Serializable
    data class ColumnSet(
        val columns: List<Column>? = null
    ) : StyledCollectionElement()

    @Serializable
    data class Column(
        val items: List<BaseCardElement>? = null,
        val width: String? = null
    ) : StyledCollectionElement()

    @Serializable
    data class FactSet(
        val facts: List<Fact>
    ) : BaseCardElement()

    @Serializable
    data class Fact(
        val title: String,
        val value: String
    )

    @Serializable
    data class ImageSet(
        val images: List<CardElement.Image>? = null,
        val imageSize: String? = null
    ) : BaseCardElement()
}