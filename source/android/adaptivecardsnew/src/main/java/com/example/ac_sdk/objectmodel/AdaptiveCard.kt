package com.example.ac_sdk.objectmodel

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.elements.BaseCardElement
import com.example.ac_sdk.objectmodel.elements.BaseElement
import com.example.ac_sdk.objectmodel.utils.BackgroundImageSerializer
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.ImageFillMode
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class AdaptiveCard(
    @SerialName("\$schema") val schema: String? = null,
    val type: String? = null,
    val version: String? = null,
    val unknown: String? = null,
    val refresh: Refresh? = null,
    var language: String = "",
    var fallbackText: String = "",
    var speak: String = "",
    val minHeight: Int? = null,
    val height: HeightType? = null,
    val verticalAlignment: VerticalAlignment? = null,
    val backgroundImage: BackgroundImage? = null,
    val body: ArrayList<BaseElement> = arrayListOf(),
    val actions: ArrayList<BaseActionElement> = arrayListOf(),
    val authentication: Authentication? = null,
    val rtl: Boolean? = null
)

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
