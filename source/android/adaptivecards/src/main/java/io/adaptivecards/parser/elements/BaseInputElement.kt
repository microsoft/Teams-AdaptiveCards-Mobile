package io.adaptivecards.parser.elements


import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
@Polymorphic
open class BaseInputElement(
    // Input-specific properties
    val isRequired: Boolean? = null,
    val errorMessage: String? = null,
    val label: String? = null,
    //val valueChangedAction: ValueChangedAction? = null
) : BaseCardElement()

