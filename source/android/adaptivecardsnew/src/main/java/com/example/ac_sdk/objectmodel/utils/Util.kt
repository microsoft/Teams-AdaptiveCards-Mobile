package com.example.ac_sdk.objectmodel.utils

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.parser.ParseWarning
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import java.util.regex.Pattern

object Util {

    fun validateColor(backgroundColor: String, warnings: MutableList<ParseWarning>): String {
        if (backgroundColor.isEmpty()) {
            return backgroundColor
        }

        val backgroundColorLength = backgroundColor.length
        var isValidColor = (backgroundColor[0] == '#' && (backgroundColorLength == 7 || backgroundColorLength == 9))
        for (i in 1 until backgroundColorLength) {
            if (!isValidColor) break
            isValidColor = backgroundColor[i].isDigit() || backgroundColor[i] in 'a'..'f' || backgroundColor[i] in 'A'..'F'
        }

        if (!isValidColor) {
            warnings.add(ParseWarning(
                WarningStatusCode.InvalidColorFormat,
                "Image background color specified, but doesn't follow #AARRGGBB or #RRGGBB format"
            ))
            return "#00000000"
        }

        return if (backgroundColorLength == 7) {
            "#FF${backgroundColor.substring(1, 7)}"
        } else {
            backgroundColor
        }
    }

    fun validateUserInputForDimensionWithUnit(
        unit: String,
        requestedDimension: String,
        parsedDimension: MutableList<Int?>,
        warnings: MutableList<ParseWarning>?
    ) {
        val warningMessage = "expected input argument to be specified as \\d+(\\.\\d+)?px with no spaces, but received "
        val stringPattern = "^([1-9]+\\d*)(\\.\\d+)?($unit)$"
        val pattern = Pattern.compile(stringPattern)
        val matcher = pattern.matcher(requestedDimension)

        if (matcher.find()) {
            try {
                parsedDimension[0] = matcher.group(1).toInt()
            } catch (e: NumberFormatException) {
                warnings?.add(ParseWarning(
                    WarningStatusCode.InvalidDimensionSpecified, warningMessage + requestedDimension
                ))
            }
        } else {
            warnings?.add(ParseWarning(
                WarningStatusCode.InvalidDimensionSpecified, warningMessage + requestedDimension
            ))
        }
    }

    fun shouldParseForExplicitDimension(input: String): Boolean {
        if (input.isEmpty()) {
            return false
        }

        val ch = input[0]
        if (ch == '-' || ch == '.') {
            return true
        }

        var hasDigit = false
        for (c in input) {
            if (c.isDigit()) {
                hasDigit = true
            }
            if (hasDigit && (c.isLetter() || c == '.')) {
                return true
            }
        }
        return false
    }

    fun parseSizeForPixelSize(sizeString: String, warnings: MutableList<ParseWarning>?): Int? {
        val parsedSize = mutableListOf<Int?>()
        if (shouldParseForExplicitDimension(sizeString)) {
            val unit = "px"
            validateUserInputForDimensionWithUnit(unit, sizeString, parsedSize, warnings)
        }
        return parsedSize[0]
    }

    fun ensureShowCardVersions(actions: List<BaseActionElement>, version: String) {
        for (action in actions) {
            if (action is ActionElements.ActionShowCard) {
                val showCardAction = action
                if (showCardAction.card.version?.isEmpty() == true) {
                    showCardAction.card.version = version
                }
            }
        }
    }

    fun handleUnknownProperties(
        json: JsonObject,
        knownProperties: Set<AdaptiveCardSchemaKey>
    ): JsonObject {
        // Build a new JsonObject combining existing unknown properties and new ones
        return buildJsonObject {
            // Add new unknown properties from 'json' that are not in 'knownProperties'
            for ((key, value) in json) {
                if (key !in knownProperties.map { it.toString() }) {
                    put(key, value)
                }
            }
        }
    }
}