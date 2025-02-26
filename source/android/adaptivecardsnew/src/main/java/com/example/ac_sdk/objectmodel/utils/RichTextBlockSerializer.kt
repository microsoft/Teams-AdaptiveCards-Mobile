package com.example.ac_sdk.objectmodel.utils

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.elements.models.TextRun
import com.example.ac_sdk.objectmodel.elements.models.isSimple
import kotlinx.serialization.InternalSerializationApi
import kotlinx.serialization.KSerializer
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.*

object RichTextBlockSerializer : KSerializer<CardElements.RichTextBlock> {
    @OptIn(InternalSerializationApi::class)
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("RichTextBlock") {
        element("inlines", ListSerializer(TextRun.serializer()).descriptor)
    }

    override fun deserialize(decoder: Decoder): CardElements.RichTextBlock {
        val jsonDecoder = decoder as? JsonDecoder ?: error("This serializer only works with JSON")
        // Decode the whole JSON element
        val jsonElement = jsonDecoder.decodeJsonElement()
        // Expect the structure to be a JSON object with an "inlines" property
        val jsonObject = jsonElement.jsonObject
        val inlines: List<TextRun> = when (val inlinesElement = jsonObject["inlines"]) {
            null, is JsonNull -> emptyList()
            is JsonArray -> inlinesElement.map { element ->
                when {
                    element is JsonObject ->
                        jsonDecoder.json.decodeFromJsonElement(TextRun.serializer(), element)

                    element is JsonPrimitive && element.isString ->
                        // For a primitive string, create a simple TextRun.
                        TextRun(type = InlineElementType.TextRun.name, text = element.content)

                    else -> error("Unexpected JSON element type for inlines: $element")
                }
            }

            else -> error("Expected a JSON array for inlines, but found: $inlinesElement")
        }
        return CardElements.RichTextBlock(inlines = inlines)
    }

    override fun serialize(encoder: Encoder, value: CardElements.RichTextBlock) {
        val jsonEncoder = encoder as? JsonEncoder ?: error("This serializer only works with JSON")
        val inlinesArray = JsonArray(value.inlines.map { textRun ->
            // If this TextRun is "simple", we can serialize it as a JSON string.
            if (textRun.isSimple()) {
                JsonPrimitive(textRun.text)
            } else {
                jsonEncoder.json.encodeToJsonElement(TextRun.serializer(), textRun)
            }
        })
        val jsonObject = buildJsonObject {
            put("inlines", inlinesArray)
        }
        jsonEncoder.encodeJsonElement(jsonObject)
    }
}

