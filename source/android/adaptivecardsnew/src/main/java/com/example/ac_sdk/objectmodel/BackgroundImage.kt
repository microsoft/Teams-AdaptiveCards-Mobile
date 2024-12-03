package com.example.ac_sdk.objectmodel

import org.json.JSONObject

data class BackgroundImage(
    var url: String = "",
    var fillMode: ImageFillMode = ImageFillMode.Cover,
    var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.Left,
    var verticalAlignment: VerticalAlignment = VerticalAlignment.Top
) {

    fun shouldSerialize(): Boolean {
        return url.isNotEmpty()
    }

    fun serialize(): String {
        return serializeToJsonValue().toString()
    }

    fun serializeToJsonValue(): JSONObject {
        val json = JSONObject()

        if (url.isNotEmpty() && fillMode == ImageFillMode.Cover && horizontalAlignment == HorizontalAlignment.Left && verticalAlignment == VerticalAlignment.Top) {
            json.put("url", url)
        } else {
            if (url.isNotEmpty()) {
                json.put("url", url)
            }
            if (fillMode != ImageFillMode.Cover) {
                json.put("fillMode", fillMode.name)
            }
            if (horizontalAlignment != HorizontalAlignment.Left) {
                json.put("horizontalAlignment", horizontalAlignment.name)
            }
            if (verticalAlignment != VerticalAlignment.Top) {
                json.put("verticalAlignment", verticalAlignment.name)
            }
        }

        return json
    }

    companion object {
        fun deserialize(json: JSONObject): BackgroundImage? {
            if (json.length() == 0) {
                return null
            }

            val url = json.optString("url", "")
            val fillMode = ImageFillMode.valueOf(json.optString("fillMode", ImageFillMode.Cover.name))
            val horizontalAlignment = HorizontalAlignment.valueOf(json.optString("horizontalAlignment", HorizontalAlignment.Left.name))
            val verticalAlignment = VerticalAlignment.valueOf(json.optString("verticalAlignment", VerticalAlignment.Top.name))

            return BackgroundImage(url, fillMode, horizontalAlignment, verticalAlignment)
        }

        fun deserializeFromString(jsonString: String): BackgroundImage? {
            return deserialize(JSONObject(jsonString))
        }
    }
}