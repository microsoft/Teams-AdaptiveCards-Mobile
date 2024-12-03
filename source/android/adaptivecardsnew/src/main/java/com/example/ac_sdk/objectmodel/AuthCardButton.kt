package com.example.ac_sdk.objectmodel

import org.json.JSONObject

class AuthCardButton(
    var type: String = "",
    var title: String = "",
    var image: String = "",
    var value: String = ""
) {

    fun getType(): String = type
    fun setType(type: String) {
        this.type = type
    }

    fun getTitle(): String = title
    fun setTitle(title: String) {
        this.title = title
    }

    fun getImage(): String = image
    fun setImage(image: String) {
        this.image = image
    }

    fun getValue(): String = value
    fun setValue(value: String) {
        this.value = value
    }

    fun shouldSerialize(): Boolean {
        return type.isNotEmpty() || title.isNotEmpty() || image.isNotEmpty() || value.isNotEmpty()
    }

    fun serialize(): String {
        return serializeToJson().toString()
    }

    fun serializeToJson(): JSONObject {
        val json = JSONObject()
        if (type.isNotEmpty()) json.put("type", type)
        if (title.isNotEmpty()) json.put("title", title)
        if (image.isNotEmpty()) json.put("image", image)
        if (value.isNotEmpty()) json.put("value", value)
        return json
    }

    companion object {
        fun deserialize(json: JSONObject): AuthCardButton {
            return AuthCardButton(
                type = json.optString("type", ""),
                title = json.optString("title", ""),
                image = json.optString("image", ""),
                value = json.optString("value", "")
            )
        }

        fun deserializeFromString(jsonString: String): AuthCardButton {
            return deserialize(JSONObject(jsonString))
        }
    }
}