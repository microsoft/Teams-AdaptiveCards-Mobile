package com.example.ac_sdk

import android.text.Layout
import com.example.ac_sdk.objectmodel.*
import kotlinx.serialization.*
import kotlinx.serialization.json.*
import java.io.File
import java.util.*

@Serializable
data class AdaptiveCard(
    var version: String = "",
    var fallbackText: String = "",
    var backgroundImage: BackgroundImage? = null,
    var refresh: Refresh? = null,
    var authentication: Authentication? = null,
    var style: ContainerStyle = ContainerStyle.None,
    var speak: String = "",
    var language: String = "",
    var verticalContentAlignment: VerticalContentAlignment = VerticalContentAlignment.Top,
    var height: HeightType = HeightType.Auto,
    var minHeight: Int = 0,
    var rtl: Boolean? = null,
    var body: MutableList<BaseCardElement> = mutableListOf(),
    var actions: MutableList<BaseActionElement> = mutableListOf(),
    var layouts: MutableList<Layout> = mutableListOf(),
    var selectAction: BaseActionElement? = null,
    var requires: MutableMap<String, SemanticVersion> = mutableMapOf(),
    var fallbackContent: BaseElement? = null,
    var fallbackType: FallbackType = FallbackType.None,
    var additionalProperties: JsonObject = JsonObject(emptyMap())
) {
    val internalId: InternalId = InternalId.next()

    companion object {
        fun deserializeFromFile(jsonFile: String, rendererVersion: String, context: ParseContext = ParseContext()): ParseResult {
            val jsonFileStream = File(jsonFile).readText()
            val root = Json.parseToJsonElement(jsonFileStream).jsonObject
            return deserialize(root, rendererVersion, context)
        }

        fun deserialize(json: JsonObject, rendererVersion: String, context: ParseContext = ParseContext()): ParseResult {
            // Implement deserialization logic here
            // ...
            return ParseResult(AdaptiveCard(), listOf())
        }

        fun deserializeFromString(jsonString: String, rendererVersion: String, context: ParseContext = ParseContext()): ParseResult {
            val root = Json.parseToJsonElement(jsonString).jsonObject
            return deserialize(root, rendererVersion, context)
        }

        fun makeFallbackTextCard(fallbackText: String, language: String, speak: String): AdaptiveCard {
            val textBlock = TextBlock().apply {
                text = fallbackText
                this.language = language
            }
            return AdaptiveCard(
                version = "1.0",
                fallbackText = fallbackText,
                style = ContainerStyle.Default,
                speak = speak,
                language = language,
                body = mutableListOf(textBlock)
            )
        }

        fun getFeaturesSupported(): Map<String, SemanticVersion> {
            return mapOf("responsivelayout" to SemanticVersion("1.0"))
        }

        fun meetsRootRequirements(requiresSet: Map<String, SemanticVersion>): Boolean {
            val featuresSupported = getFeaturesSupported()
            for ((feature, version) in requiresSet) {
                val supportedVersion = featuresSupported[feature.toLowerCase(Locale.ROOT)]
                if (supportedVersion == null || supportedVersion < version) {
                    return false
                }
            }
            return true
        }
    }

    fun serializeToJsonValue(): JsonObject {
        val json = JsonObject(
            mapOf(
                "type" to JsonPrimitive("AdaptiveCard"),
                "version" to JsonPrimitive(version.ifEmpty { "1.0" }),
                "fallbackText" to JsonPrimitive(fallbackText),
                "backgroundImage" to backgroundImage?.serializeToJsonValue(),
                "refresh" to refresh?.serializeToJsonValue(),
                "authentication" to authentication?.serializeToJsonValue(),
                "speak" to JsonPrimitive(speak),
                "language" to JsonPrimitive(language),
                "style" to JsonPrimitive(style.toString()),
                "verticalContentAlignment" to JsonPrimitive(verticalContentAlignment.toString()),
                "minHeight" to JsonPrimitive("${minHeight}px"),
                "rtl" to rtl?.let { JsonPrimitive(it) },
                "height" to JsonPrimitive(height.toString()),
                "body" to JsonArray(body.map { it.serializeToJsonValue() }),
                "actions" to JsonArray(actions.map { it.serializeToJsonValue() })
            ).filterValues { it != null }
        )
        return json
    }

    fun serialize(): String {
        return Json.encodeToString(serializeToJsonValue())
    }

    fun getResourceInformation(): List<RemoteResourceInformation> {
        val resourceVector = mutableListOf<RemoteResourceInformation>()
        backgroundImage?.let {
            resourceVector.add(RemoteResourceInformation(it.url, "image"))
        }
        body.forEach { it.getResourceInformation(resourceVector) }
        actions.forEach { it.getResourceInformation(resourceVector) }
        return resourceVector
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