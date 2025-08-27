// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.AdaptiveCard
import io.adaptivecards.adaptivecardsv2.objectmodel.serializer.TargetElementSerializer
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ActionRole
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AssociatedInputs
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNames

@Serializable
sealed class ActionElement {
    @Serializable
    @SerialName("Action.Submit")
    data class ActionSubmit(
        val data: Map<String, JsonElement>? = null,
        val conditionallyEnabled: Boolean? = false,
        val associatedInputs: AssociatedInputs? = AssociatedInputs.NONE
    ) : BaseActionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                listOf(
                    AdaptiveCardSchemaKey.DATA
                )
            }
        }
    }

    @Serializable
    @SerialName("Action.OpenUrl")
    data class ActionOpenUrl(
        val url: String,
    ) : BaseActionElement() {
        init {
            takeIf { role == null }?.let {
                role = ActionRole.LINK
            }
        }
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                listOf(
                    AdaptiveCardSchemaKey.URL
                )
            }
        }
    }

    @Serializable
    @SerialName("Action.ShowCard")
    data class ActionShowCard(
        val card: AdaptiveCard
    ) : BaseActionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                listOf(
                    AdaptiveCardSchemaKey.CARD
                )
            }
        }
    }

    @Serializable
    @SerialName("Action.Execute")
    data class ActionExecute(
        val verb: String,
        val conditionallyEnabled: Boolean? = false,
        val data: Map<String, JsonElement>? = null,
        val associatedInputs: AssociatedInputs? = AssociatedInputs.NONE
    ) : BaseActionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                listOf(
                    AdaptiveCardSchemaKey.VERB
                )
            }
        }
    }

    @Serializable
    @SerialName("Action.ToggleVisibility")
    data class ActionToggleVisibility(
        @Serializable(with = TargetElementSerializer::class)
        val targetElements: List<TargetElement>
    ) : BaseActionElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                listOf(
                    AdaptiveCardSchemaKey.TARGET_ELEMENTS
                )
            }
        }
    }
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class TargetElement(
    @JsonNames("elementId") val elementId: String,
    @JsonNames("isVisible") val isVisible: Boolean? = null
)
