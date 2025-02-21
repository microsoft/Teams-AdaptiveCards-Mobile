package com.example.ac_sdk.objectmodel.utils

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.parser.ParseWarning
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import java.util.Locale
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

    fun getVersion(version: String): SemanticVersion {
        val versionPattern =
            Pattern.compile("^([\\d]+)(?:\\.([\\d]+))?(?:\\.([\\d]+))?(?:\\.([\\d]+))?$")
        val matcher = versionPattern.matcher(version)

        if (!matcher.matches()) {
            throw IllegalArgumentException("Semantic version invalid: $version")
        }

        val major = matcher.group(1)?.toIntOrNull() ?: 0
        val minor = matcher.group(2)?.toIntOrNull() ?: 0
        val build = matcher.group(3)?.toIntOrNull() ?: 0
        val revision = matcher.group(4)?.toIntOrNull() ?: 0
        return SemanticVersion(major, minor, build, revision)
    }

    fun meetsRootRequirements(requiresSet: Map<String, SemanticVersion>): Boolean {
        val featuresSupported = getFeaturesSupported()
        for ((feature, version) in requiresSet) {
            val supportedVersion = featuresSupported[feature.lowercase(Locale.ROOT)]
            if (supportedVersion == null || supportedVersion < version) {
                return false
            }
        }
        return true
    }

    fun validateLanguage(language: String, warnings: MutableList<ParseWarning>) {
        try {
            if (language.isEmpty() || language.length == 2 || language.length == 3) {
                // Attempt to create a Locale; in Kotlin we can do:
                Locale(language)
            } else {
                warnings.add(
                    ParseWarning(
                        WarningStatusCode.InvalidLanguage,
                        "Invalid language identifier: $language"
                    )
                )
            }
        } catch (e: RuntimeException) {
            warnings.add(
                ParseWarning(
                    WarningStatusCode.InvalidLanguage,
                    "Invalid language identifier: $language"
                )
            )
        }
    }

    private fun getFeaturesSupported(): Map<String, SemanticVersion> =
        mapOf("responsivelayout" to getVersion("1.0"))
}