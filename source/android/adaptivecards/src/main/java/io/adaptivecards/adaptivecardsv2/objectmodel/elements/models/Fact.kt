package io.adaptivecards.adaptivecardsv2.objectmodel.elements.models

import kotlinx.serialization.Serializable

@Serializable
data class Fact(
    val title: String,
    val value: String
)
