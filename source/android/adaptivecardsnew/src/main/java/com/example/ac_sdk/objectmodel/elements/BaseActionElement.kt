package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.ActionRole
import com.example.ac_sdk.objectmodel.utils.ActionType
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.Mode
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class BaseActionElement : BaseElement() {

    @SerialName("title")
    val title: String? = null

    @SerialName("iconUrl")
    val iconUrl: String? = null

    @SerialName("style")
    val style: String? = null

    @SerialName("tooltip")
    val tooltip: String? = null

    @SerialName("isEnabled")
    val isEnabled: Boolean? = null

    @SerialName("mode")
    val mode: Mode? = null

    @SerialName("role")
    val role: ActionRole? = null

    override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
        return super.populateKnownPropertiesSet().apply {
            listOf(
                AdaptiveCardSchemaKey.TITLE,
                AdaptiveCardSchemaKey.ICON_URL,
                AdaptiveCardSchemaKey.STYLE,
                AdaptiveCardSchemaKey.TOOLTIP,
                AdaptiveCardSchemaKey.IS_ENABLED,
                AdaptiveCardSchemaKey.MODE,
                AdaptiveCardSchemaKey.ACTION_ROLE
            )
        }
    }
}
