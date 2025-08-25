// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.serializer

import io.adaptivecards.adaptivecardsv2.objectmodel.parser.ParseException
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ErrorStatusCode
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.SemanticVersion
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

object SemanticVersionSerializer : KSerializer<SemanticVersion> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("SemanticVersion") {
        element<Int>("major")
        element<Int>("minor")
        element<Int>("build")
        element<Int>("revision")
    }

    private val versionRegex = Regex("""^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?$""")

    override fun serialize(encoder: Encoder, value: SemanticVersion) {
        val jsonEncoder = encoder as? JsonEncoder ?: error("SemanticVersionSerializer works only with JSON")
        val jsonObject = buildJsonObject {
            put("major", value.major)
            put("minor", value.minor)
            put("build", value.build)
            put("revision", value.revision)
        }
        jsonEncoder.encodeJsonElement(jsonObject)
    }

    override fun deserialize(decoder: Decoder): SemanticVersion {
        val jsonDecoder = decoder as? JsonDecoder ?: error("SemanticVersionSerializer works only with JSON")
        val element = jsonDecoder.decodeJsonElement()

        return when (element) {
            is JsonObject -> Json.decodeFromJsonElement(SemanticVersion.serializer(), element)
            is JsonPrimitive -> {
                val versionString = element.content

                if (versionString == "*") {
                    return SemanticVersion(0, 0, 0, 0)
                }

                // Match the regex pattern to extract version components
                val matchResult = versionRegex.matchEntire(versionString)
                    ?: throw ParseException(
                        ErrorStatusCode.InvalidPropertyValue,
                        "Semantic version invalid: $versionString"
                    )

                return try {
                    val major = matchResult.groupValues.getOrNull(1)?.toInt() ?: 0
                    val minor = matchResult.groupValues.getOrNull(2)?.toInt() ?: 0
                    val build = matchResult.groupValues.getOrNull(3)?.toInt() ?: 0
                    val revision = matchResult.groupValues.getOrNull(4)?.toInt() ?: 0
                    SemanticVersion(major, minor, build, revision)
                } catch (e: Exception) {
                    throw ParseException(
                        ErrorStatusCode.InvalidPropertyValue,
                        "Semantic version invalid: $versionString"
                    )
                }
            }
            else -> throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Unexpected JSON format for SemanticVersion: $element"
            )
        }
    }
}
