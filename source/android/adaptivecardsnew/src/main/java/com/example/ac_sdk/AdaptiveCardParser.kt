package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.*
import kotlinx.serialization.PolymorphicSerializer
import kotlinx.serialization.json.*
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.modules.subclass
import java.util.*
import java.util.regex.Pattern

class AdaptiveCardParser {
    companion object {
//        fun deserializeFromFile(jsonFile: String, rendererVersion: String, context: ParseContext = ParseContext()): AdaptiveCard {
//            val jsonFileStream = File(jsonFile).readText()
//            val root = Json.parseToJsonElement(jsonFileStream).jsonObject
//            return deserialize(root, rendererVersion, context)
//        }

        //@Throws(AdaptiveCardParseException::class)
        fun deserialize(jsonObject: JsonObject, rendererVersion: String, context: ParseContext): AdaptiveCard {
            throwIfNotJsonObject(jsonObject)

            val enforceVersion = rendererVersion.isNotEmpty()
//
//            val ACModule = SerializersModule {
//                polymorphic(CardElement::class) {
//                    subclass(CardElement.TextBlockElement::class, CardElement.TextBlockElement.serializer())
//                }
//                polymorphic(BaseCardElement::class) {
//                    subclass(TextBlock::class, TextBlock.serializer())
//                }
//            }

            val ACModule = SerializersModule {
//                polymorphic(CardElement::class) {
//                    subclass(CardElement.TextBlockElement::class)
//                }
                polymorphic(BaseCardElement::class) {
                    subclass(BaseCardElement.TextBlock::class)
                    subclass(BaseCardElement.StyledCollectionElement::class)
                    subclass(BaseCardElement.ColumnSet::class)
                    subclass(BaseCardElement.Column::class)
                    subclass(BaseCardElement.Container::class)
                }
                polymorphic(BaseCardElement.StyledCollectionElement::class) {
                    subclass(BaseCardElement.ColumnSet::class)
                    subclass(BaseCardElement.Column::class)
                    subclass(BaseCardElement.Container::class)
                }
            }

            val json = Json {
                serializersModule = ACModule
                classDiscriminator = "type"
                decodeEnumsCaseInsensitive = true
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

                    context.warnings.add(AdaptiveCardParseWarning(WarningStatusCode.UnsupportedSchemaVersion, "Schema version not supported"))
                    return makeFallbackTextCard(adaptiveCard.fallbackText, adaptiveCard.language, adaptiveCard.speak)
                }
            }

//            if (adaptiveCard.layoutArray.isNotEmpty()) {
//                for (layoutJson in adaptiveCard.layoutArray) {
//                    val layout = Layout.deserialize(layoutJson)
//                    when (layout.getLayoutContainerType()) {
//                        LayoutContainerType.Flow -> layouts.add(FlowLayout.deserialize(layoutJson))
//                        LayoutContainerType.AreaGrid -> {
//                            val areaGridLayout = AreaGridLayout.deserialize(layoutJson)
//                            if (areaGridLayout.getAreas().isEmpty() && areaGridLayout.getColumns().isEmpty()) {
//                                val stackLayout = Layout()
//                                stackLayout.setLayoutContainerType(LayoutContainerType.Stack)
//                                layouts.add(stackLayout)
//                            } else if (areaGridLayout.getAreas().isEmpty()) {
//                                val flowLayout = FlowLayout()
//                                flowLayout.setLayoutContainerType(LayoutContainerType.Flow)
//                                layouts.add(flowLayout)
//                            } else {
//                                layouts.add(areaGridLayout)
//                            }
//                        }
//                    }
//                }
//            }

            // Parse required if present
            val requiresSet = mutableMapOf<String, SemanticVersion>()
            //ParseUtil.parseRequires(context, json, requiresSet)

            // Parse fallback if present
            var fallbackBaseElement: BaseCardElement? = null
            var fallbackType = FallbackType.NONE
//            ParseUtil.parseFallback(context, json, fallbackType, fallbackBaseElement, "rootFallbackId", InternalId.current())

            if (meetsRootRequirements(requiresSet)) {
                return adaptiveCard
            } else if (fallbackBaseElement == null) {
                val fallbackText = "We're sorry, this card couldn't be displayed"
                context.warnings.add(AdaptiveCardParseWarning(WarningStatusCode.UnsupportedSchemaVersion, "Requirements not met and root Fallback parsing failed"))
                return makeFallbackTextCard(fallbackText, adaptiveCard.language, adaptiveCard.speak)
            } else {
                // Convert parsed fallback to collection of BaseCardElement
                val fallbackCardElement = fallbackBaseElement
                val fallbackVector = listOf(fallbackCardElement)

                return adaptiveCard
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

        fun deserializeFromString(jsonString: String, rendererVersion: String, context: ParseContext = ParseContext()): AdaptiveCard {
            val root = Json.parseToJsonElement(jsonString).jsonObject
            return deserialize(root, rendererVersion, context)
        }

        private fun getFeaturesSupported(): Map<String, SemanticVersion> {
            return mapOf("responsivelayout" to getVersion("1.0"))
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
                throw AdaptiveCardParseException(ErrorStatusCode.InvalidJson, "Expected JSON Object\n")
            }
        }


        private fun makeFallbackTextCard(fallbackText: String, language: String, speak: String): AdaptiveCard {
            val fallbackCard = AdaptiveCard(version="1.0", fallbackText=fallbackText, speak=speak, language=language,
                verticalAlignment=VerticalAlignment.TOP, height=HeightType.AUTO, minHeight=0)

//            fallbackCard.body.add(
//                CardElement.TextBlockElement(
//                    TextBlock(
//                        text = fallbackText,
//                        language = language
//                    )
//                )
//            )

            return fallbackCard
        }
    }

    private fun validateLanguage(language: String, warnings: MutableList<AdaptiveCardParseWarning>) {
        try {
            if (language.isEmpty() || language.length == 2 || language.length == 3) {
                Locale(language)
            } else {
                warnings.add(AdaptiveCardParseWarning(WarningStatusCode.InvalidLanguage, "Invalid language identifier: $language"))
            }
        } catch (e: RuntimeException) {
            warnings.add(AdaptiveCardParseWarning(WarningStatusCode.InvalidLanguage, "Invalid language identifier: $language"))
        }
    }
}