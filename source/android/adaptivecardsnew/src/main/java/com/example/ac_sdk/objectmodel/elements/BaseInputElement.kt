package com.example.ac_sdk.objectmodel.elements


import com.example.ac_sdk.objectmodel.elements.models.ValueChangedAction
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import kotlinx.serialization.Serializable

@Serializable
sealed class BaseInputElement(
    // Input-specific properties
    val isRequired: Boolean? = null,
    val errorMessage: String? = null,
    val label: String? = null,
    val valueChangedAction: ValueChangedAction? = null
) : BaseCardElement() {

    override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
        return super.populateKnownPropertiesSet().apply {
            listOf(
                AdaptiveCardSchemaKey.ID,
                AdaptiveCardSchemaKey.LABEL,
                AdaptiveCardSchemaKey.ERROR_MESSAGE,
                AdaptiveCardSchemaKey.IS_REQUIRED
            )
        }
    }
}

