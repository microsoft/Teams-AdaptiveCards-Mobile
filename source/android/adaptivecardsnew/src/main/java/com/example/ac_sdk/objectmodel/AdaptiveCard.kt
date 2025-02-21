package com.example.ac_sdk.objectmodel

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.elements.BaseElement
import com.example.ac_sdk.objectmodel.elements.Layout
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.BackgroundImageSerializer
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.ImageFillMode
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class AdaptiveCard(
    @SerialName("\$schema") val schema: String? = null,
    val type: String? = null,
    var version: String? = null,
    val unknown: String? = null,
    val refresh: Refresh? = null,
    var language: String = "",
    var fallbackText: String = "",
    val fallback: BaseElement? = null,
    var speak: String = "",
    var minHeight: String? = null,
    val height: HeightType? = null,
    val verticalAlignment: VerticalAlignment? = null,
    val backgroundImage: BackgroundImage? = null,
    val body: ArrayList<BaseElement> = arrayListOf(),
    val actions: ArrayList<BaseActionElement> = arrayListOf(),
    val authentication: Authentication? = null,
    val rtl: Boolean? = null,
    val layoutArray: ArrayList<Layout>? = null,
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
}

@Serializable
data class BackgroundImageObj(
    val url: String? = null,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@Serializable(with = BackgroundImageSerializer::class)
data class BackgroundImage(
    val url: String,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@Serializable
data class Authentication(
    val connectionName: String,
    val text: String,
    val tokenExchangeResource: TokenExchangeResource,
    val buttons: List<AuthCardButton>
)

@Serializable
data class Refresh(
    val action: ActionElements.ActionExecute,
    val userIds: List<String>
)

@Serializable
data class TokenExchangeResource(
    val id: String,
    val providerId: String,
    val uri: String
)

@Serializable
data class AuthCardButton(
    val type: String,
    val title: String
)
