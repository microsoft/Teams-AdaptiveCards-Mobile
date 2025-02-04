package io.adaptivecards.parser.elements

import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
@Polymorphic
sealed class CollectionCoreElement : BaseCardElement() {
    var elements: List<BaseCardElement>? = null
}