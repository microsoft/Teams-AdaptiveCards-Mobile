// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.serializer

import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HeightType
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonPrimitive

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
