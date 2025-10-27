// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ActionRole
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.Mode
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
    val isEnabled: Boolean = true

    @SerialName("mode")
    val mode: Mode? = null

    @SerialName("role")
    var role: ActionRole? = null

    val rtl: Boolean = false

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
