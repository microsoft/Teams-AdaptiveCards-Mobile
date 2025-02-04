package io.adaptivecards.parser.elements

import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

object BaseActionElementSerializer : JsonContentPolymorphicSerializer<BaseActionElement>(BaseActionElement::class) {
    override fun selectDeserializer(element: JsonElement): KSerializer<out BaseActionElement> {
        val typeValue = element.jsonObject["type"]?.jsonPrimitive?.content
            ?: throw SerializationException("Missing 'type' field for polymorphic deserialization")

        return when (typeValue) {
            "Action.Submit" -> ActionElement.ActionSubmit.serializer()

            // Add more subclasses here if needed
            else -> throw SerializationException("Unknown type: $typeValue")
        }
    }
}