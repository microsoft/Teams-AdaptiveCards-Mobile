// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.serializer

import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.int
import kotlinx.serialization.json.intOrNull

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
