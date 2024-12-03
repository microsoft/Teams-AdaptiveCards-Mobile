package com.example.ac_sdk.objectmodel

import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import java.util.*
import kotlin.collections.HashMap

object ParseUtil {

    fun jsonToString(json: JsonObject): String {
        return json.toString()
    }

    fun throwIfNotJsonObject(json: JsonElement) {
        if (json !is JsonObject) {
            throw AdaptiveCardParseException(ErrorStatusCode.InvalidJson, "Expected JSON Object\n")
        }
    }

    fun getTypeAsString(json: JsonObject): String {
        val typeKey = "type"
        return json[typeKey]?.asString ?: throw AdaptiveCardParseException(
            ErrorStatusCode.RequiredPropertyMissing, "The JSON element is missing the following value: $typeKey"
        )
    }

    fun tryGetTypeAsString(json: JsonObject): String {
        return try {
            getTypeAsString(json)
        } catch (e: AdaptiveCardParseException) {
            ""
        }
    }

    fun tryGetString(json: JsonObject, key: AdaptiveCardSchemaKey): String {
        return try {
            getString(json, key)
        } catch (e: Exception) {
            ""
        }
    }

    fun getString(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): String {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]?.asString
        if (propertyValue.isNullOrEmpty()) {
            if (isRequired) {
                throw AdaptiveCardParseException(
                    ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: $propertyName"
                )
            } else {
                return ""
            }
        }
        return propertyValue
    }

    fun getString(json: JsonObject, key: AdaptiveCardSchemaKey, defaultValue: String, isRequired: Boolean = false): String {
        val parseResult = getString(json, key, isRequired)
        return if (parseResult.isEmpty()) defaultValue else parseResult
    }

    fun getJsonString(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): String {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            if (isRequired) {
                throw AdaptiveCardParseException(
                    ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: $propertyName"
                )
            } else {
                return ""
            }
        }
        return propertyValue.toString()
    }

    fun getValueAsString(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): String {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            if (isRequired) {
                throw AdaptiveCardParseException(
                    ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: $propertyName"
                )
            } else {
                return ""
            }
        }
        return propertyValue.toString()
    }

    fun getBool(json: JsonObject, key: AdaptiveCardSchemaKey, defaultValue: Boolean, isRequired: Boolean = false): Boolean {
        val optionalBool = getOptionalBool(json, key)
        if (isRequired && optionalBool == null) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: ${key.toString()}"
            )
        }
        return optionalBool ?: defaultValue
    }

    fun getOptionalBool(json: JsonObject, key: AdaptiveCardSchemaKey): Boolean? {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            return null
        }
        if (propertyValue !is JsonPrimitive || !propertyValue.isBoolean) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Value for property $propertyName was invalid. Expected type bool."
            )
        }
        return propertyValue.asBoolean
    }

    fun getUInt(json: JsonObject, key: AdaptiveCardSchemaKey, defaultValue: UInt, isRequired: Boolean = false): UInt {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            if (isRequired) {
                throw AdaptiveCardParseException(
                    ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: $propertyName"
                )
            } else {
                return defaultValue
            }
        }
        if (propertyValue !is JsonPrimitive || !propertyValue.isNumber) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Value for property $propertyName was invalid. Expected type uInt."
            )
        }
        return propertyValue.asUInt
    }

    fun getInt(json: JsonObject, key: AdaptiveCardSchemaKey, defaultValue: Int, isRequired: Boolean = false): Int {
        val optionalInt = getOptionalInt(json, key)
        if (isRequired && optionalInt == null) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: ${key.toString()}"
            )
        }
        return optionalInt ?: defaultValue
    }

    fun getOptionalInt(json: JsonObject, key: AdaptiveCardSchemaKey): Int? {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            return null
        }
        if (propertyValue !is JsonPrimitive || !propertyValue.isNumber) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Value for property $propertyName was invalid. Expected type int."
            )
        }
        return propertyValue.asInt
    }

    fun getDouble(json: JsonObject, key: AdaptiveCardSchemaKey, defaultValue: Double, isRequired: Boolean = false): Double {
        val optionalDouble = getOptionalDouble(json, key)
        if (isRequired && optionalDouble == null) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "Property is required but was found empty: ${key.toString()}"
            )
        }
        return optionalDouble ?: defaultValue
    }

    fun getOptionalDouble(json: JsonObject, key: AdaptiveCardSchemaKey): Double? {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            return null
        }
        if (propertyValue !is JsonPrimitive || !propertyValue.isNumber) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Value for property $propertyName was invalid. Expected type double."
            )
        }
        return propertyValue.asDouble
    }

    fun getOptionalString(json: JsonObject, key: AdaptiveCardSchemaKey): String? {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (propertyValue == null) {
            return null
        }
        if (propertyValue !is JsonPrimitive || !propertyValue.isString) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Value for property $propertyName was invalid. Expected type String."
            )
        }
        return propertyValue.asString
    }

    fun expectTypeString(json: JsonObject, expectedTypeStr: String) {
        val actualType = getTypeAsString(json)
        if (expectedTypeStr != actualType) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "The JSON element did not have the correct type. Expected: $expectedTypeStr, Actual: $actualType"
            )
        }
    }

    fun expectTypeString(json: JsonObject, bodyType: CardElementType) {
        expectTypeString(json, bodyType.toString())
    }

    fun expectKeyAndValueType(json: JsonObject, expectedKey: String, throwIfWrongType: (JsonElement) -> Unit) {
        if (!json.has(expectedKey)) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "The JSON element is missing the following key: $expectedKey"
            )
        }
        val value = json[expectedKey]
        throwIfWrongType(value)
    }

    fun getArray(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): JsonArray {
        val propertyName = key.toString()
        val elementArray = json[propertyName]
        if (elementArray !is JsonArray) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Could not parse specified key: $propertyName. It was not an array"
            )
        }
        if (isRequired && elementArray.isEmpty()) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "Could not parse required key: $propertyName. It was not found"
            )
        }
        return elementArray
    }

    fun getStringArray(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): List<String> {
        val jsonArray = getArray(json, key, isRequired)
        return jsonArray.map { it.asString }
    }

    fun getJsonValueFromString(jsonString: String): JsonObject {
        return JsonParser.parseString(jsonString).asJsonObject
    }

    fun extractJsonValue(json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): JsonElement {
        val propertyName = key.toString()
        val propertyValue = json[propertyName]
        if (isRequired && propertyValue == null) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.RequiredPropertyMissing, "Could not extract required key: $propertyName."
            )
        }
        return propertyValue
    }

    fun toLowercase(value: String): String {
        return value.lowercase(Locale.getDefault())
    }

    fun getActionFromJsonValue(context: ParseContext, json: JsonObject): BaseActionElement? {
        if (json.isEmpty || !json.isJsonObject) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Expected a Json object to extract Action element"
            )
        }
        val typeString = getTypeAsString(json)
        val parser = context.actionParserRegistration.getParser(typeString)
            ?: context.actionParserRegistration.getParser("UnknownAction")
        return parser?.deserialize(context, json)
    }

    fun getActionCollection(context: ParseContext, json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): List<BaseActionElement> {
        val elementArray = getArray(json, key, isRequired)
        return elementArray.mapNotNull { getActionFromJsonValue(context, it.asJsonObject) }
    }

    fun getAction(context: ParseContext, json: JsonObject, key: AdaptiveCardSchemaKey, isRequired: Boolean = false): BaseActionElement? {
        val selectAction = extractJsonValue(json, key, isRequired)
        return if (!selectAction.isJsonNull) getActionFromJsonValue(context, selectAction.asJsonObject) else null
    }

    fun getLabelFromJsonValue(context: ParseContext, json: JsonObject): BaseCardElement? {
        if (json.isEmpty || !json.isJsonObject) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Expected a Json object to extract Label element"
            )
        }
        val typeString = toLowercase(getTypeAsString(json))
        if (typeString != toLowercase(AdaptiveCardSchemaKey.TextBlock.toString()) &&
            typeString != toLowercase(AdaptiveCardSchemaKey.RichTextBlock.toString())
        ) {
            throw AdaptiveCardParseException(
                ErrorStatusCode.InvalidPropertyValue, "Element type is not a string, TextBlock or RichTextBlock"
            )
        }
        val parser = context.elementParserRegistration.getParser(typeString)
        return parser?.deserialize(context, json)
    }

    fun getLabel(context: ParseContext, json: JsonObject, key: AdaptiveCardSchemaKey): BaseCardElement? {
        val label = extractJsonValue(json, key)
        return if (!label.isJsonNull) getLabelFromJsonValue(context, label.asJsonObject) else null
    }

    fun parseRequires(context: ParseContext, json: JsonObject, requiresSet: MutableMap<String, SemanticVersion>) {
        val requiresValue = extractJsonValue(json, AdaptiveCardSchemaKey.Requires, false)
        getParsedRequiresSet(requiresValue.asJsonObject, requiresSet)
    }

    fun getParsedRequiresSet(json: JsonObject, requiresSet: MutableMap<String, SemanticVersion>) {
        if (!json.isJsonNull) {
            if (json.isJsonObject) {
                json.entrySet().forEach { (memberName, memberValue) ->
                    val version = if (memberValue.asString == "*") "0" else memberValue.asString
                    try {
                        requiresSet[memberName] = SemanticVersion(version)
                    } catch (e: AdaptiveCardParseException) {
                        throw AdaptiveCardParseException(
                            ErrorStatusCode.InvalidPropertyValue, "Invalid version in requires value: '$version'"
                        )
                    }
                }
            } else {
                throw AdaptiveCardParseException(
                    ErrorStatusCode.InvalidPropertyValue, "Invalid value for requires (should be object)"
                )
            }
        }
    }
}