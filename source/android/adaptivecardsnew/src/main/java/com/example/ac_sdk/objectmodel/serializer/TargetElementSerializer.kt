// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.serializer

import com.example.ac_sdk.objectmodel.elements.TargetElement
import kotlinx.serialization.*
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.*
import kotlinx.serialization.json.*

object TargetElementSerializer : KSerializer<List<TargetElement>> {
    override val descriptor: SerialDescriptor =
        ListSerializer(TargetElement.serializer()).descriptor

    override fun serialize(encoder: Encoder, value: List<TargetElement>) {
        val jsonEncoder = encoder as? JsonEncoder ?: error("TargetElementSerializer works only with JSON")
        val jsonArray = buildJsonArray {
            value.forEach { target ->
                if (target.isVisible == null) {
                    // Serialize as a string when only "elementId" is present
                    add(JsonPrimitive(target.elementId))
                } else {
                    // Serialize as a JSON object when "isVisible" exists
                    add(Json.encodeToJsonElement(TargetElement.serializer(), target))
                }
            }
        }
        jsonEncoder.encodeJsonElement(jsonArray)
    }

    override fun deserialize(decoder: Decoder): List<TargetElement> {
        val jsonDecoder = decoder as? JsonDecoder ?: error("TargetElementSerializer works only with JSON")
        val jsonElement = jsonDecoder.decodeJsonElement()

        return when (jsonElement) {
            is JsonArray -> jsonElement.map { element ->
                when (element) {
                    is JsonPrimitive -> TargetElement(element.content) // If it's a string, treat it as elementId
                    is JsonObject -> Json.decodeFromJsonElement(TargetElement.serializer(), element) // If it's an object, deserialize normally
                    else -> error("Unexpected JSON format for TargetElement: $element")
                }
            }
            else -> error("Expected a JSON array for TargetElement, but got: $jsonElement")
        }
    }
}
