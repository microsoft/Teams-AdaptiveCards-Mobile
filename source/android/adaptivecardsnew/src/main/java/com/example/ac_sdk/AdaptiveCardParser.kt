package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.elements.CardElement
import com.example.ac_sdk.objectmodel.elements.LayoutElement
import com.example.ac_sdk.objectmodel.parser.ParseContext
import com.example.ac_sdk.objectmodel.parser.ParseException
import com.example.ac_sdk.objectmodel.parser.ParseResult
import com.example.ac_sdk.objectmodel.parser.ParseWarning
import com.example.ac_sdk.objectmodel.utils.ErrorStatusCode
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.LayoutContainerType
import com.example.ac_sdk.objectmodel.utils.ParseUtil
import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import com.example.ac_sdk.objectmodel.utils.Util
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import com.example.ac_sdk.objectmodel.utils.WarningStatusCode
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.jsonObject
import java.io.File

class AdaptiveCardParser {


    companion object {

        fun deserializeFromString(
            jsonText: String,
            rendererVersion: String,
            context: ParseContext
        ): ParseResult {
            val json = Json.parseToJsonElement(jsonText)
            return deserialize(json.jsonObject, rendererVersion, context)
        }

        fun deserializeFromFile(jsonFile: String, rendererVersion: String): ParseResult {
            val context = ParseContext()
            return deserializeFromFile(jsonFile, rendererVersion, context)
        }

        fun deserializeFromFile(
            jsonFile: String,
            rendererVersion: String,
            context: ParseContext
        ): ParseResult {
            val jsonText = File(jsonFile).readText()
            val json = Json.parseToJsonElement(jsonText)
            return deserialize(json.jsonObject, rendererVersion, context)
        }


        //@Throws(AdaptiveCardParseException::class)
        @OptIn(ExperimentalSerializationApi::class)
        fun deserialize(
            jsonObject: JsonObject,
            rendererVersion: String,
            context: ParseContext
        ): ParseResult {
            throwIfNotJsonObject(jsonObject)

            val enforceVersion = rendererVersion.isNotEmpty()


            val json = Json {
                classDiscriminator = "type"
                ignoreUnknownKeys = true
                encodeDefaults = true
                decodeEnumsCaseInsensitive = true
            }
            val adaptiveCard = json.decodeFromJsonElement<AdaptiveCard>(jsonObject)

            Util.validateLanguage(adaptiveCard.language, context.warnings)
            if (adaptiveCard.language.isNotEmpty()) {
                context.setLanguage(adaptiveCard.language)
            } else {
                adaptiveCard.language = context.getLanguage()
            }

            // Perform version validation
            if (enforceVersion && !isCardVersionSupported(rendererVersion, adaptiveCard, context)) {
                return ParseResult(
                    makeFallbackTextCard(
                        adaptiveCard.fallbackText,
                        adaptiveCard.language,
                        adaptiveCard.speak
                    ),
                    context.warnings
                )
            }

            if (adaptiveCard.layouts?.isNotEmpty() == true) {
                for ((index, layout) in adaptiveCard.layouts.withIndex()) {
                    when (layout.layoutContainerType) {
                        LayoutContainerType.AREAGRID -> {
                            val areaGridLayout = layout as LayoutElement.AreaGridLayout
                            if (areaGridLayout.areas.isEmpty() && areaGridLayout.columns.isEmpty()) {
                                val stackLayout = LayoutElement.StackLayout().apply {
                                    layoutContainerType = LayoutContainerType.STACK
                                }
                                adaptiveCard.layouts[index] = stackLayout
                            } else if (areaGridLayout.areas.isEmpty()) {
                                val flowLayout = LayoutElement.FlowLayout().apply {
                                    layoutContainerType = LayoutContainerType.FLOW
                                }
                                adaptiveCard.layouts[index] = flowLayout
                            }
                        }

                        else -> {

                        }
                    }
                }
            }

            adaptiveCard.minHeight = adaptiveCard.minHeight?.let {
                Util.parseSizeForPixelSize(it.toString(), context.warnings)
            }.toString()


            // Parse required if present
            val requiresSet = mutableMapOf<String, SemanticVersion>()
            ParseUtil.parseRequires(context, jsonObject, requiresSet)

            // Parse fallback if present
            val fallbackBaseElement = adaptiveCard.fallback

            if (Util.meetsRootRequirements(requiresSet)) {
//                adaptiveCard.additionalProperties =
//                    Util.handleUnknownProperties(jsonObject, adaptiveCard.knownProperties)
                return ParseResult(adaptiveCard, context.warnings)
            } else if (fallbackBaseElement == null) {
                val fallbackText = "We're sorry, this card couldn't be displayed"
                context.warnings.add(
                    ParseWarning(
                        WarningStatusCode.UnsupportedSchemaVersion,
                        "Requirements not met and root Fallback parsing failed"
                    )
                )
                return ParseResult(
                    makeFallbackTextCard(
                        fallbackText,
                        adaptiveCard.language,
                        adaptiveCard.speak
                    ), context.warnings
                )
            } else {
                val fallback = AdaptiveCard(
                    adaptiveCard.schema,
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
                    adaptiveCard.style,
                    adaptiveCard.backgroundImage,
                    arrayListOf(fallbackBaseElement),
                    adaptiveCard.actions,
                    adaptiveCard.authentication,
                    adaptiveCard.rtl,
                    adaptiveCard.layouts
                )
                fallback.additionalProperties =
                    Util.handleUnknownProperties(jsonObject, fallback.knownProperties)
                return ParseResult(adaptiveCard, context.warnings)
            }
        }

        private fun isCardVersionSupported(
            rendererVersion: String,
            adaptiveCard: AdaptiveCard,
            context: ParseContext
        ): Boolean {
            val rendererMaxVersion = Util.getVersion(rendererVersion)
            val cardVersion = adaptiveCard.version?.let { Util.getVersion(it) }

            if (cardVersion != null && rendererMaxVersion < cardVersion) {
                if (adaptiveCard.fallbackText.isEmpty()) {
                    adaptiveCard.fallbackText = "We're sorry, this card couldn't be displayed"
                }

                if (adaptiveCard.speak.isEmpty()) {
                    adaptiveCard.speak = adaptiveCard.fallbackText
                }

                context.warnings.add(
                    ParseWarning(
                        WarningStatusCode.UnsupportedSchemaVersion,
                        "Schema version not supported"
                    )
                )
                return false
            }
            return true
        }


        private fun throwIfNotJsonObject(json: JsonElement) {
            if (json !is JsonObject) {
                throw ParseException(ErrorStatusCode.InvalidJson, "Expected JSON Object\n")
            }
        }


        public fun makeFallbackTextCard(
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
                height = HeightType.Auto,
                minHeight = "0"
            )
            fallbackCard.body.add(

                CardElement.TextBlock(
                    text = fallbackText,
                    language = language
                )
            )

            return fallbackCard
        }
    }
}