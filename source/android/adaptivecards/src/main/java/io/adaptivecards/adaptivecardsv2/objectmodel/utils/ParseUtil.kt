package io.adaptivecards.adaptivecardsv2.objectmodel.utils

import io.adaptivecards.adaptivecardsv2.objectmodel.parser.ParseContext
import io.adaptivecards.adaptivecardsv2.objectmodel.parser.ParseException
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonPrimitive

object ParseUtil {

    /** Maximum accepted length for a single string property. */
    const val MAX_STRING_LENGTH = 4 * 1024 * 1024

    /** Maximum accepted size for a single JSON collection. */
    const val MAX_ARRAY_SIZE = 1000

    /** Maximum accepted size, in bytes, for a whole card payload. */
    const val MAX_JSON_PAYLOAD_BYTES = 10 * 1024 * 1024

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

        val typeValue = json[typeKey] ?: throw ParseException(
            ErrorStatusCode.RequiredPropertyMissing,
            "The JSON element is missing the following value: $typeKey"
        )

        // jsonPrimitive throws IllegalArgumentException for objects and arrays, which would escape
        // as an unexpected exception type, so the shape is checked explicitly first.
        if (typeValue !is JsonPrimitive || !typeValue.isString) {
            throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Value for property $typeKey was invalid. Expected type string."
            )
        }

        return typeValue.content
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

        if (isRequired && isAbsentOrBlank(propertyValue)) {
            throw ParseException(
                ErrorStatusCode.RequiredPropertyMissing,
                "Could not extract required key: $propertyName."
            )
        }

        if (propertyValue is JsonPrimitive && propertyValue.isString &&
            propertyValue.content.length > MAX_STRING_LENGTH
        ) {
            throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Value for property $propertyName exceeds the maximum supported length of $MAX_STRING_LENGTH"
            )
        }

        return propertyValue
    }

    /**
     * A required property is considered missing when it is absent, null, or an empty/whitespace
     * only string, matching the shared C++ object model.
     */
    private fun isAbsentOrBlank(value: JsonElement): Boolean {
        if (value is JsonNull) {
            return true
        }

        return value is JsonPrimitive && value.isString && value.content.isBlank()
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
            if (value !is JsonPrimitive || !value.isString) {
                throw ParseException(
                    ErrorStatusCode.InvalidPropertyValue,
                    "Invalid version in requires value for '$key'"
                )
            }

            val versionString = value.content
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

}