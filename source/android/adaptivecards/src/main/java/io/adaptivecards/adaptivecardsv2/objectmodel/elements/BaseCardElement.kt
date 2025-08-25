// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.serializer.HeightTypeSerializer
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HeightType
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HostWidth
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.Spacing
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.TargetWidthType
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

@Serializable
sealed class BaseCardElement: BaseElement() {
    var spacing: Spacing = Spacing.DEFAULT
    var separator: Boolean? = null
    @Serializable(with = HeightTypeSerializer::class)
    var height: HeightType? = null
    var targetWidth: TargetWidthType? = null
    var isVisible: Boolean? = null
    var areaGridName: String? = null
    var nonOptionalAreaGridName: String? = null

    override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
        return super.populateKnownPropertiesSet().apply {
            listOf(
                AdaptiveCardSchemaKey.HEIGHT,
                AdaptiveCardSchemaKey.IS_VISIBLE,
                AdaptiveCardSchemaKey.MIN_HEIGHT,
                AdaptiveCardSchemaKey.TARGET_WIDTH,
                AdaptiveCardSchemaKey.SEPARATOR,
                AdaptiveCardSchemaKey.SPACING
            )
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
//
//        fun parseJsonObject(context: ParseContext, json: Map<String, Any>): BaseCardElement? {
//            val typeString = json["type"] as? String ?: return null
//            val parser = context.elementParserRegistration.getParser(typeString)
//                ?: context.elementParserRegistration.getParser("Unknown")
//                ?: return null
//
//            return parser.deserialize(context, json)
//        }
    }
}


