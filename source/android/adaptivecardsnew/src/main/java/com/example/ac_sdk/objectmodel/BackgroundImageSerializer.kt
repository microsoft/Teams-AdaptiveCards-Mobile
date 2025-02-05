package com.example.ac_sdk.objectmodel

import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.descriptors.buildClassSerialDescriptor
import kotlinx.serialization.descriptors.element
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.encoding.decodeStructure
import kotlinx.serialization.encoding.encodeStructure
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonPrimitive

object BackgroundImageSerializer : KSerializer<BackgroundImage> {
    override val descriptor: SerialDescriptor = buildClassSerialDescriptor("BackgroundImage") {
        element<String>("url")
        element<ImageFillMode>("fillMode")
        element<HorizontalAlignment>("horizontalAlignment")
        element<VerticalAlignment>("verticalAlignment")
    }

    override fun serialize(encoder: Encoder, value: BackgroundImage) {
        encoder.encodeStructure(descriptor) {
            encodeStringElement(descriptor, 0, value.url)
            encodeSerializableElement(descriptor, 1, ImageFillMode.serializer(), value.fillMode ?: ImageFillMode.COVER)
            encodeSerializableElement(descriptor, 2, HorizontalAlignment.serializer(), value.horizontalAlignment ?: HorizontalAlignment.LEFT)
            encodeSerializableElement(descriptor, 3, VerticalAlignment.serializer(), value.verticalAlignment ?: VerticalAlignment.TOP)
        }
    }

    override fun deserialize(decoder: Decoder): BackgroundImage {
        return if (decoder is JsonDecoder) {
            val jsonElement = decoder.decodeJsonElement()
            if (jsonElement is JsonPrimitive) {
                BackgroundImage(url = jsonElement.content)
            } else {
                decoder.decodeStructure(descriptor) {
                    var url = ""
                    var fillMode = ImageFillMode.COVER
                    var horizontalAlignment = HorizontalAlignment.LEFT
                    var verticalAlignment = VerticalAlignment.TOP

                    while (true) {
                        when (decodeElementIndex(descriptor)) {
                            0 -> url = decodeStringElement(descriptor, 0)
                            1 -> fillMode = decodeSerializableElement(descriptor, 1, ImageFillMode.serializer())
                            2 -> horizontalAlignment = decodeSerializableElement(descriptor, 2, HorizontalAlignment.serializer())
                            3 -> verticalAlignment = decodeSerializableElement(descriptor, 3, VerticalAlignment.serializer())
                            else -> break
                        }
                    }
                    BackgroundImage(url, fillMode, horizontalAlignment, verticalAlignment)
                }
            }
        } else {
            throw IllegalStateException("Unexpected decoder type")
        }
    }
}