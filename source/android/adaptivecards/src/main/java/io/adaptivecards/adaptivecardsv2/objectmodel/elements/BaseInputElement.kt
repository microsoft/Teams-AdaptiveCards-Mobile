// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.models.ValueChangedAction
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
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

