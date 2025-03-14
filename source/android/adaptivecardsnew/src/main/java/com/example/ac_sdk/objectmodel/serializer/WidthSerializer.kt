package com.example.ac_sdk.objectmodel.serializer

import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.*
import kotlinx.serialization.json.*

object WidthSerializer : KSerializer<String> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("width", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: String) {
        // Always serialize as a JSON string.
        encoder.encodeString(value)
    }

    override fun deserialize(decoder: Decoder): String {
        val jsonDecoder = decoder as? JsonDecoder
            ?: error("WidthSerializer works only with JSON")
        val element = jsonDecoder.decodeJsonElement()
        return when {
            element is JsonPrimitive && element.isString ->
                element.content
            element is JsonPrimitive && element.intOrNull != null ->
                element.int.toString()
            else ->
                error("Unexpected JSON element for width: $element")
        }
    }
}
