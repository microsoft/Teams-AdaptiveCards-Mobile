// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.ActionElement
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.BaseActionElement
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.BaseElement
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.Layout
import io.adaptivecards.adaptivecardsv2.objectmodel.serializer.BackgroundImageSerializer
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ContainerStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HeightType
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HorizontalAlignment
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ImageFillMode
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

@kotlinx.serialization.Serializable
data class AdaptiveCard(
    @SerialName("\$schema") val schema: String? = null,
    val type: String? = null,
    var version: String? = "",
    val unknown: String? = null,
    val refresh: Refresh? = null,
    var language: String = "",
    var fallbackText: String = "",
    val fallback: BaseElement? = null,
    var speak: String = "",
    var minHeight: String? = 0.toString(),
    val height: HeightType? = HeightType.Auto,
    val verticalAlignment: VerticalAlignment? = VerticalAlignment.TOP,
    val style: ContainerStyle? = ContainerStyle.NONE,
    val backgroundImage: BackgroundImage? = null,
    val body: ArrayList<BaseElement> = arrayListOf(),
    val actions: ArrayList<BaseActionElement> = arrayListOf(),
    val authentication: Authentication? = null,
    val rtl: Boolean? = null,
    val layouts: ArrayList<Layout>? = null,
    val selectAction: BaseActionElement? = null,
) {

    val knownProperties: Set<AdaptiveCardSchemaKey> by lazy {
        setOf(
            AdaptiveCardSchemaKey.TYPE,
            AdaptiveCardSchemaKey.VERSION,
            AdaptiveCardSchemaKey.BODY,
            AdaptiveCardSchemaKey.ACTIONS,
            AdaptiveCardSchemaKey.FALLBACK_TEXT,
            AdaptiveCardSchemaKey.BACKGROUND_IMAGE,
            AdaptiveCardSchemaKey.REFRESH,
            AdaptiveCardSchemaKey.AUTHENTICATION,
            AdaptiveCardSchemaKey.MIN_HEIGHT,
            AdaptiveCardSchemaKey.SPEAK,
            AdaptiveCardSchemaKey.LANGUAGE,
            AdaptiveCardSchemaKey.VERTICAL_CONTENT_ALIGNMENT,
            AdaptiveCardSchemaKey.STYLE,
            AdaptiveCardSchemaKey.SELECT_ACTION,
            AdaptiveCardSchemaKey.HEIGHT,
            AdaptiveCardSchemaKey.SCHEMA,
            AdaptiveCardSchemaKey.REQUIRES,
            AdaptiveCardSchemaKey.FALLBACK
        )
    }

    var additionalProperties: JsonElement? = null

    fun serialize(): String {
        return Json.encodeToString(serializer(), this)
    }
}

@Serializable
data class BackgroundImageObj(
    val url: String? = null,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@kotlinx.serialization.Serializable(with = BackgroundImageSerializer::class)
data class BackgroundImage(
    val url: String,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@kotlinx.serialization.Serializable
data class Authentication(
    val connectionName: String,
    val text: String,
    val tokenExchangeResource: TokenExchangeResource,
    val buttons: List<AuthCardButton>
)

@kotlinx.serialization.Serializable
data class Refresh(
    val action: ActionElement.ActionExecute,
    val userIds: List<String>
)

@kotlinx.serialization.Serializable
data class TokenExchangeResource(
    val id: String,
    val providerId: String,
    val uri: String
)

@kotlinx.serialization.Serializable
data class AuthCardButton(
    val type: String,
    val title: String,
    val image: String? = null,
    val value: String? = null
)
