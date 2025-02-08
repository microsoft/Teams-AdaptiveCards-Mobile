package com.example.ac_sdk.objectmodel.elements

import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
sealed class CollectionCoreElement : BaseCardElement() {
    var elements: List<BaseCardElement>? = null
}