package com.example.ac_sdk.objectmodel.elements.models

import kotlinx.serialization.Serializable

@Serializable
data class Fact(
    val title: String,
    val value: String
)
