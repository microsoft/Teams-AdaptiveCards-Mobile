package com.example.ac_sdk.objectmodel.utils

import com.example.ac_sdk.objectmodel.parser.ParseContext
import com.example.ac_sdk.objectmodel.parser.ParseException
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonPrimitive

object ParseUtil {

    @Throws(ParseException::class)
    fun expectTypeString(json: JsonObject, expectedTypeStr: String) {
        val actualType = getTypeAsString(json)

        if (expectedTypeStr != actualType) {
            throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "The JSON element did not have the correct type. Expected: $expectedTypeStr, Actual: $actualType"
            )
        }
    }

    @Throws(ParseException::class)
    fun getTypeAsString(json: JsonObject): String {
        val typeKey = "type"

        if (!json.containsKey(typeKey)) {
            throw ParseException(
                ErrorStatusCode.RequiredPropertyMissing,
                "The JSON element is missing the following value: $typeKey"
            )
        }

        return json[typeKey]?.jsonPrimitive?.content ?: throw ParseException(
            ErrorStatusCode.RequiredPropertyMissing,
            "The JSON element is missing the following value: $typeKey"
        )
    }

    fun parseRequires(
        context: ParseContext,
        json: JsonObject,
        requiresSet: MutableMap<String, SemanticVersion>
    ) {
        val requiresValue = extractJsonValue(json, AdaptiveCardSchemaKey.REQUIRES, false)
        getParsedRequiresSet(requiresValue, requiresSet)
    }

    private fun extractJsonValue(
        json: JsonObject,
        key: AdaptiveCardSchemaKey,
        isRequired: Boolean
    ): JsonElement {
        val propertyName = key.toString()  // Assuming AdaptiveCardSchemaKey has a proper toString()
        val propertyValue = json[propertyName] ?: JsonNull

        if (isRequired && propertyValue is JsonNull) {
            throw ParseException(
                ErrorStatusCode.RequiredPropertyMissing,
                "Could not extract required key: $propertyName."
            )
        }

        return propertyValue
    }

    // Function to process the requires JSON object and update requiresSet
    private fun getParsedRequiresSet(
        jsonElement: JsonElement?,
        requiresSet: MutableMap<String, SemanticVersion>
    ) {
        if (jsonElement == null || jsonElement is JsonNull) {
            return  // No "requires" field, nothing to parse
        }

        if (jsonElement !is JsonObject) {
            throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Invalid value for requires (should be an object)"
            )
        }

        for ((key, value) in jsonElement) {
            val versionString = value.jsonPrimitive.content
            val semanticVersion = if (versionString == "*") {
                // "*" means any version — treated as "0"
                SemanticVersion(0)
            } else {
                try {
                    SemanticVersion(versionString.toInt())
                } catch (e: Exception) {
                    throw ParseException(
                        ErrorStatusCode.InvalidPropertyValue,
                        "Invalid version in requires value: '$versionString'"
                    )
                }
            }
            requiresSet[key] = semanticVersion
        }
    }


    fun parseFallback(
        context: ParseContext,
        json: JsonObject,
        fallbackData: FallbackData,
        publicId: String,
        internalId: InternalId
    ) {
        // Extract the fallback value from the JSON.
        val fallbackValue = ParseUtil.extractJsonValue(json, AdaptiveCardSchemaKey.Fallback, isRequired = false)
        if (fallbackValue !is JsonNull) {
            // Two valid possibilities: a string "drop", or a JSON object representing fallback content.
            if (fallbackValue is JsonPrimitive && fallbackValue.isString) {
                val fallbackStringValue = fallbackValue.content.lowercase()
                if (fallbackStringValue == "drop") {
                    fallbackData.fallbackType = FallbackType.Drop
                    return
                }
                throw AdaptiveCardParseException(
                    ErrorStatusCode.InvalidPropertyValue,
                    "The only valid string value for the fallback property is 'drop'."
                )
            } else if (fallbackValue is JsonObject) {
                // Fallback is an object: parse it as fallback content.
                context.pushElement(publicId, internalId, isFallback = true)
                // Assume that BaseElement.parseJsonObject is a function that parses the JSON into a BaseElement.
                val fallbackElement = BaseElement.parseJsonObject(context, fallbackValue)
                context.popElement()

                if (fallbackElement != null) {
                    fallbackData.fallbackType = FallbackType.Content
                    fallbackData.fallbackContent = fallbackElement
                    return
                }
                throw AdaptiveCardParseException(
                    ErrorStatusCode.InvalidPropertyValue,
                    "Fallback content did not parse correctly."
                )
            }
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Invalid value for fallback"
            )
        }

}