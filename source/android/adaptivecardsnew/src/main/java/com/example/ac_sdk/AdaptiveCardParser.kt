package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.*
import com.example.ac_sdk.objectmodel.elements.BaseCardElement
import com.example.ac_sdk.objectmodel.elements.BaseElement
import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.elements.Layout
import com.example.ac_sdk.objectmodel.elements.LayoutElements
import com.example.ac_sdk.objectmodel.parser.ParseContext
import com.example.ac_sdk.objectmodel.parser.ParseException
import com.example.ac_sdk.objectmodel.parser.ParseResult
import com.example.ac_sdk.objectmodel.parser.ParseWarning
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.CardElementType
import com.example.ac_sdk.objectmodel.utils.ErrorStatusCode
import com.example.ac_sdk.objectmodel.utils.FallbackType
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.LayoutContainerType
import com.example.ac_sdk.objectmodel.utils.ParseUtil
import com.example.ac_sdk.objectmodel.utils.ParseUtil.expectTypeString
import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import com.example.ac_sdk.objectmodel.utils.Util
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import com.example.ac_sdk.objectmodel.utils.WarningStatusCode
import com.google.android.material.internal.FlowLayout
import kotlinx.serialization.json.*
import java.io.File
import java.util.*
import java.util.regex.Pattern
import kotlin.collections.ArrayList

class AdaptiveCardParser {


    companion object {


        fun getFeaturesSupported(): Map<String, SemanticVersion> =
             mapOf("responsivelayout" to getVersion("1.0"))

        fun deserializeFromFile(jsonFile: String, rendererVersion: String): ParseResult {
            val context = ParseContext()
            return deserializeFromFile(jsonFile, rendererVersion, context)
        }

        fun deserializeFromFile(jsonFile: String, rendererVersion: String, context: ParseContext): ParseResult {
            val jsonText = File(jsonFile).readText()
            val json = Json.parseToJsonElement(jsonText)
            return deserialize(json.jsonObject, rendererVersion, context)
        }

        private fun _validateLanguage(language: String, warnings: MutableList<ParseWarning>) {
            try {
                if (language.isEmpty() || language.length == 2 || language.length == 3) {
                    // Attempt to create a Locale; in Kotlin we can do:
                    Locale(language)
                } else {
                    warnings.add(
                        ParseWarning(WarningStatusCode.InvalidLanguage, "Invalid language identifier: $language")
                    )
                }
            } catch (e: RuntimeException) {
                warnings.add(
                    ParseWarning(WarningStatusCode.InvalidLanguage, "Invalid language identifier: $language")
                )
            }
        }


        //@Throws(AdaptiveCardParseException::class)
        fun deserialize(jsonObject: JsonObject, rendererVersion: String, context: ParseContext): ParseResult {
            throwIfNotJsonObject(jsonObject)

            val enforceVersion = rendererVersion.isNotEmpty()
//


            val json = Json {
                classDiscriminator = "type"
                ignoreUnknownKeys = true
                encodeDefaults = true
            }
            val adaptiveCard = json.decodeFromJsonElement<AdaptiveCard>(jsonObject)

            if (adaptiveCard.language.isNotEmpty()) {
                context.setLanguage(adaptiveCard.language)
            } else {
                adaptiveCard.language = context.getLanguage()
            }

            // Perform version validation
            if (enforceVersion) {
                val rendererMaxVersion = getVersion(rendererVersion)
                val cardVersion = adaptiveCard.version?.let { getVersion(it) }

                if (cardVersion != null && rendererMaxVersion < cardVersion) {
                    if (adaptiveCard.fallbackText.isEmpty()) {
                        adaptiveCard.fallbackText = "We're sorry, this card couldn't be displayed"
                    }

                    if (adaptiveCard.speak.isEmpty()) {
                        adaptiveCard.speak = adaptiveCard.fallbackText
                    }

                    context.warnings.add(ParseWarning(WarningStatusCode.UnsupportedSchemaVersion, "Schema version not supported"))
                    return ParseResult(makeFallbackTextCard(adaptiveCard.fallbackText, adaptiveCard.language, adaptiveCard.speak), context.warnings)
                }
            }

            if (adaptiveCard.layoutArray?.isNotEmpty() == true) {
                for ((index, layout) in adaptiveCard.layoutArray.withIndex()) {
                    when (layout.layoutContainerType) {
                        LayoutContainerType.AREAGRID -> {
                            val areaGridLayout = layout as LayoutElements.AreaGridLayout
                            if (areaGridLayout.areas.isEmpty() && areaGridLayout.columns.isEmpty()) {
                                val stackLayout = LayoutElements.StackLayout().apply {
                                    layoutContainerType = LayoutContainerType.STACK
                                }
                                adaptiveCard.layoutArray[index] = stackLayout
                            } else if (areaGridLayout.areas.isEmpty()) {
                                val flowLayout = LayoutElements.FlowLayout().apply {
                                    layoutContainerType = LayoutContainerType.FLOW
                                }
                                adaptiveCard.layoutArray[index] = flowLayout
                            }
                        }
                        else -> {

                        }
                    }
                }
            }

            adaptiveCard.minHeight = adaptiveCard.minHeight?.let {
                Util.parseSizeForPixelSize(it, context.warnings)
            }.toString()


            // Parse required if present
            val requiresSet = mutableMapOf<String, SemanticVersion>()
            ParseUtil.parseRequires(context, jsonObject, requiresSet)

            // Parse fallback if present
            val fallbackBaseElement = adaptiveCard.fallback

            if (meetsRootRequirements(requiresSet)) {
                adaptiveCard.additionalProperties = Util.handleUnknownProperties(jsonObject, adaptiveCard.knownProperties)
                return ParseResult(adaptiveCard, context.warnings)
            } else if (fallbackBaseElement == null) {
                val fallbackText = "We're sorry, this card couldn't be displayed"
                context.warnings.add(ParseWarning(WarningStatusCode.UnsupportedSchemaVersion, "Requirements not met and root Fallback parsing failed"))
                return ParseResult(makeFallbackTextCard(fallbackText, adaptiveCard.language, adaptiveCard.speak), context.warnings)
            } else {
                // Convert parsed fallback to collection of BaseCardElement
                val fallbackCardElement = fallbackBaseElement
                val fallback = AdaptiveCard(adaptiveCard.schema,
                    adaptiveCard.type,
                    adaptiveCard.version,
                    adaptiveCard.unknown,
                    adaptiveCard.refresh,
                    adaptiveCard.language,
                    "",
                    null,
                    adaptiveCard.speak,
                    adaptiveCard.minHeight,
                    adaptiveCard.height,
                    adaptiveCard.verticalAlignment,
                    adaptiveCard.backgroundImage,
                    arrayListOf(fallbackBaseElement),
                    adaptiveCard.actions,
                    adaptiveCard.authentication,
                    adaptiveCard.rtl,
                    adaptiveCard.layoutArray
                )
                fallback.additionalProperties =
                    Util.handleUnknownProperties(jsonObject, fallback.knownProperties)
                return ParseResult(adaptiveCard, context.warnings)
            }
        }

        private fun getVersion(version: String): SemanticVersion {
            val versionPattern = Pattern.compile("^([\\d]+)(?:\\.([\\d]+))?(?:\\.([\\d]+))?(?:\\.([\\d]+))?$")
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

        private fun meetsRootRequirements(requiresSet: Map<String, SemanticVersion>): Boolean {
            val featuresSupported = getFeaturesSupported()
            for ((feature, version) in requiresSet) {
                val supportedVersion = featuresSupported[feature.lowercase(Locale.ROOT)]
                if (supportedVersion == null || supportedVersion < version) {
                    return false
                }
            }
            return true
        }


        private fun throwIfNotJsonObject(json: JsonElement) {
            if (json !is JsonObject) {
                throw ParseException(ErrorStatusCode.InvalidJson, "Expected JSON Object\n")
            }
        }


        private fun makeFallbackTextCard(
            fallbackText: String,
            language: String,
            speak: String
        ): AdaptiveCard {
            val fallbackCard = AdaptiveCard(
                version = "1.0",
                fallbackText = fallbackText,
                fallback = null,
                speak = speak,
                language = language,
                verticalAlignment = VerticalAlignment.TOP,
                height = HeightType.AUTO,
                minHeight = "0"
            )
            fallbackCard.body.add(

                CardElements.TextBlock(
                    text = fallbackText,
                    language = language
                )
            )

            return fallbackCard
        }
    }
}