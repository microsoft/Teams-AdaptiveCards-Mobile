package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.serializer.TargetElementSerializer
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.AssociatedInputs
import kotlinx.serialization.*
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
        val url: String
    ) : BaseActionElement() {
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
