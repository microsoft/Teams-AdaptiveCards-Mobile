package com.example.ac_sdk.objectmodel.serializer

import com.example.ac_sdk.objectmodel.parser.ParseException
import com.example.ac_sdk.objectmodel.utils.ErrorStatusCode
import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.*
import kotlinx.serialization.json.*

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
