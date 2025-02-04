package io.adaptivecards.parser.elements

import io.adaptivecards.parser.AdaptiveCard
import kotlinx.serialization.*
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNames

@Serializable
sealed class ActionElement {
    @Serializable
    @SerialName("Action.Submit")
    data class ActionSubmit(
        val data: Map<String, JsonElement>? = null
    ) : BaseActionElement()


    @Serializable
    @SerialName("Action.OpenUrl")
    data class ActionOpenUrl(
        val url: String
    ) : BaseActionElement()

    @Serializable
    @SerialName("Action.ShowCard")
    data class ActionShowCard(
        val card: AdaptiveCard
    ) : BaseActionElement()

    @Serializable
    @SerialName("Action.Execute")
    data class ActionExecute(
        val verb: String
    ) : BaseActionElement()

    @Serializable
    @SerialName("Action.ToggleVisibility")
    data class ActionToggleVisibility(
        val targetElements: List<TargetElement>
    ) : BaseActionElement()
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class TargetElement(
    @JsonNames("elementId") val elementId: String,
    @JsonNames("isVisible") val isVisible: Boolean? = null
)
