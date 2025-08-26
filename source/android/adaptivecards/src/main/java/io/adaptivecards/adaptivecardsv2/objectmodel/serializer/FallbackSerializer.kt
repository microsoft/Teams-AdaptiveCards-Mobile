// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.serializer

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.BaseElement
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.DropElement
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive

object FallbackSerializer : KSerializer<BaseElement?> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("Fallback")

    @OptIn(ExperimentalSerializationApi::class)
    override fun serialize(encoder: Encoder, value: BaseElement?) {
        val jsonEncoder = encoder as? JsonEncoder ?: error("FallbackSerializer works only with JSON")

        when (value) {
            null -> jsonEncoder.encodeNull() // If fallback is NONE, serialize as null.
            is DropElement -> jsonEncoder.encodeString("drop") // "drop" is just a string.
            else -> jsonEncoder.encodeJsonElement(Json.encodeToJsonElement(BaseElement.serializer(), value))
        }
    }

    override fun deserialize(decoder: Decoder): BaseElement? {
        val jsonDecoder = decoder as? JsonDecoder ?: error("FallbackSerializer works only with JSON")
        return when (val element = jsonDecoder.decodeJsonElement()) {
            is JsonPrimitive -> {
                if (element.content == "drop") DropElement // If it's "drop", return DropElement instance
                else null // Any unknown string defaults to null
            }
            is JsonObject -> Json.decodeFromJsonElement(BaseElement.serializer(), element) // "content" -> Deserialize BaseElement
            else -> null
        }
    }
}
