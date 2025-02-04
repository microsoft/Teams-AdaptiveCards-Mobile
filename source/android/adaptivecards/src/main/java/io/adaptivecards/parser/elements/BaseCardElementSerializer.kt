package io.adaptivecards.parser.elements

import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.JsonContentPolymorphicSerializer
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.SerializationException

object BaseCardElementSerializer : JsonContentPolymorphicSerializer<BaseCardElement>(BaseCardElement::class) {
    override fun selectDeserializer(element: JsonElement): KSerializer<out BaseCardElement> {
        val typeValue = element.jsonObject["type"]?.jsonPrimitive?.content
            ?: throw SerializationException("Missing 'type' field for polymorphic deserialization")

        return when (typeValue) {
            "TextBlock" -> CardElement.TextBlock.serializer()
            "Input.Text" -> InputElement.InputText.serializer()
            "ColumnSet" -> ContainerElement.ColumnSet.serializer()

            // Add more subclasses here if needed
            else -> throw SerializationException("Unknown type: $typeValue")
        }
    }
}


