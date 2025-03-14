package com.example.ac_sdk.objectmodel.serializer

import com.example.ac_sdk.objectmodel.elements.models.Inline
import com.example.ac_sdk.objectmodel.elements.models.PlainTextInline
import com.example.ac_sdk.objectmodel.elements.models.TextRun
import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerializationException
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonPrimitive

// Custom serializer to handle polymorphic inlines
object InlineSerializer : JsonContentPolymorphicSerializer<Inline>(Inline::class) {
    override fun selectDeserializer(element: JsonElement): KSerializer<out Inline> = when {
        // Handle plain text (string literal) by deserializing it into PlainTextInline
        element is JsonPrimitive && element.isString -> object : KSerializer<Inline> {
            override val descriptor: SerialDescriptor = PrimitiveSerialDescriptor("PlainTextInline", PrimitiveKind.STRING)

            override fun serialize(encoder: Encoder, value: Inline) {
                if (value is PlainTextInline) {
                    encoder.encodeString(value.text)
                } else {
                    throw SerializationException("Expected PlainTextInline, but got ${value::class}")
                }
            }

            override fun deserialize(decoder: Decoder): Inline {
                return PlainTextInline(decoder.decodeString())
            }
        }
        // Handle objects (e.g., TextRun)
        element is JsonObject -> {
            val type = element["type"]?.jsonPrimitive?.content
            when (type) {
                "TextRun" -> TextRun.serializer()
                else -> throw IllegalArgumentException("Unknown type: $type")
            }
        }
        else -> throw IllegalArgumentException("Unsupported JSON element: $element")
    }
}