package com.example.ac_sdk.objectmodel.elements


import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
sealed class BaseInputElement(
    // Input-specific properties
    val isRequired: Boolean? = null,
    val errorMessage: String? = null,
    val label: String? = null,
    //val valueChangedAction: ValueChangedAction? = null
) : BaseCardElement()

