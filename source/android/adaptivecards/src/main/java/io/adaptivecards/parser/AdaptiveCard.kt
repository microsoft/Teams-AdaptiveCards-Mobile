package io.adaptivecards.parser

import io.adaptivecards.parser.elements.ActionElement
import io.adaptivecards.parser.elements.BaseActionElement
import io.adaptivecards.parser.elements.BaseCardElement
import io.adaptivecards.parser.utils.HorizontalAlignment
import io.adaptivecards.parser.utils.ImageFillMode
import io.adaptivecards.parser.utils.VerticalAlignment
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive

@Serializable
data class AdaptiveCard(
    @SerialName("\$schema")
    val schema: String? = null,
    val type: String? = null,
    val version: String? = null,
    val unknown: String? = null,
    val refresh: Refresh? = null,
    val lang: String? = null,
    val fallbackText: String? = null,
    val speak: String? = null,
    val minHeight: String? = null,
    val verticalContentAlignment: VerticalAlignment? = null,
    val backgroundImage: BackgroundImage? = null,
    val body: List<BaseCardElement>,
    val actions: List<BaseActionElement>? = null,
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
sealed class BackgroundImage {
    @Serializable
    data class ImageUrl(val value: String) : BackgroundImage()

    @Serializable
    data class Obj(val value: BackgroundImageObj) : BackgroundImage()
}

object BackgroundImageSerializer : JsonContentPolymorphicSerializer<BackgroundImage>(BackgroundImage::class) {
    override fun selectDeserializer(element: JsonElement): kotlinx.serialization.DeserializationStrategy<out BackgroundImage> {
        return if (element is JsonPrimitive && element.isString) {
            BackgroundImage.ImageUrl.serializer()
        } else if (element is JsonObject) {
            BackgroundImage.Obj.serializer()
        } else {
            throw SerializationException("Unexpected JSON for BackgroundImage: $element")
        }
    }
}

@Serializable
data class Authentication(
    val connectionName: String,
    val text: String,
    val tokenExchangeResource: TokenExchangeResource,
    val buttons: List<AuthCardButton>
)

@Serializable
data class Refresh(
    val action: ActionElement.ActionExecute,
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