package com.example.ac_sdk.objectmodel.serializer

import com.example.ac_sdk.objectmodel.utils.HeightType
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.*
import kotlinx.serialization.json.*

object HeightTypeSerializer : KSerializer<HeightType> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("HeightType", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: HeightType) {
        // Serialize by converting the HeightType to a string.
        encoder.encodeString(value.toString())
    }

    override fun deserialize(decoder: Decoder): HeightType {
        val jsonDecoder = decoder as? JsonDecoder
            ?: error("HeightTypeSerializer only works with JSON")
        val element = jsonDecoder.decodeJsonElement()
        if (element is JsonPrimitive && element.isString) {
            val content = element.content
            return HeightType.fromString(content)
        } else {
            error("Expected a JSON string for height, got: $element")
        }
    }
}
