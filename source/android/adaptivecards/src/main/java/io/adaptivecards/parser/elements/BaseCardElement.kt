package io.adaptivecards.parser.elements

import io.adaptivecards.parser.parsing.ParseContext
import io.adaptivecards.parser.utils.CardElementType
import io.adaptivecards.parser.utils.HeightType
import io.adaptivecards.parser.utils.Spacing
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

@Serializable(with = BaseCardElementSerializer::class)
@Polymorphic
sealed class BaseCardElement: BaseElement() {
    var type: CardElementType? = null
    var spacing: Spacing? = null
    var separator: Boolean? = null
    var height: HeightType? = null
    var targetWidth: TargetWidthType? = null
    var isVisible: Boolean? = null
    var areaGridName: String? = null
    var nonOptionalAreaGridName: String? = null


    fun serialize(): String {
        return try {
            Json.encodeToString(this)
        } catch (e: Exception) {
            ""
        }
    }

    fun meetsTargetWidthRequirement(hostWidth: HostWidth): Boolean {
        if (targetWidth == TargetWidthType.DEFAULT || hostWidth == HostWidth.DEFAULT) {
            return true
        }
        return when (targetWidth) {
            TargetWidthType.WIDE -> hostWidth == HostWidth.WIDE
            TargetWidthType.STANDARD -> hostWidth == HostWidth.STANDARD
            TargetWidthType.NARROW -> hostWidth == HostWidth.NARROW
            TargetWidthType.VERY_NARROW -> hostWidth == HostWidth.VERY_NARROW
            TargetWidthType.AT_LEAST_WIDE -> hostWidth >= HostWidth.WIDE
            TargetWidthType.AT_LEAST_STANDARD -> hostWidth >= HostWidth.STANDARD
            TargetWidthType.AT_LEAST_NARROW -> hostWidth >= HostWidth.NARROW
            TargetWidthType.AT_LEAST_VERY_NARROW -> hostWidth >= HostWidth.VERY_NARROW
            TargetWidthType.AT_MOST_WIDE -> hostWidth <= HostWidth.WIDE
            TargetWidthType.AT_MOST_STANDARD -> hostWidth <= HostWidth.STANDARD
            TargetWidthType.AT_MOST_NARROW -> hostWidth <= HostWidth.NARROW
            TargetWidthType.AT_MOST_VERY_NARROW -> hostWidth <= HostWidth.VERY_NARROW
            else -> true
        }
    }

    companion object {
        fun deserializeBaseProperties(jsonString: String): BaseCardElement? {
            return try {
                Json.decodeFromString(serializer(), jsonString)
            } catch (e: Exception) {
                null
            }
        }

        fun deserializeBaseProperties(json: Map<String, Any>): BaseCardElement? {
            return try {
                val jsonObject = JsonObject(json.mapValues { Json.parseToJsonElement(it.value.toString()) })
                Json.decodeFromJsonElement(serializer(), jsonObject)
            } catch (e: Exception) {
                null
            }
        }

        fun parseJsonObject(context: ParseContext, json: Map<String, Any>): BaseCardElement? {
            val typeString = json["type"] as? String ?: return null
            val parser = context.elementParserRegistration.getParser(typeString)
                ?: context.elementParserRegistration.getParser("Unknown")
                ?: return null

            return parser.deserialize(context, json)
        }
    }
}

// --- Supporting types for BaseCardElement ---

@Serializable
enum class HostWidth {
    @SerialName("default")
    DEFAULT,

    @SerialName("wide")
    WIDE,

    @SerialName("standard")
    STANDARD,

    @SerialName("narrow")
    NARROW,

    @SerialName("veryNarrow")
    VERY_NARROW;
}

@Serializable
enum class TargetWidthType {
    @SerialName("default")
    DEFAULT,

    @SerialName("wide")
    WIDE,

    @SerialName("standard")
    STANDARD,

    @SerialName("narrow")
    NARROW,

    @SerialName("veryNarrow")
    VERY_NARROW,

    @SerialName("atLeastWide")
    AT_LEAST_WIDE,

    @SerialName("atLeastStandard")
    AT_LEAST_STANDARD,

    @SerialName("atLeastNarrow")
    AT_LEAST_NARROW,

    @SerialName("atLeastVeryNarrow")
    AT_LEAST_VERY_NARROW,

    @SerialName("atMostWide")
    AT_MOST_WIDE,

    @SerialName("atMostStandard")
    AT_MOST_STANDARD,

    @SerialName("atMostNarrow")
    AT_MOST_NARROW,

    @SerialName("atMostVeryNarrow")
    AT_MOST_VERY_NARROW
}

