package com.example.ac_sdk.objectmodel

import org.json.JSONArray
import org.json.JSONObject

data class Authentication(
    var text: String = "",
    var connectionName: String = "",
    var tokenExchangeResource: TokenExchangeResource? = null,
    var buttons: List<AuthCardButton> = emptyList()
) {
    fun shouldSerialize(): Boolean {
        return text.isNotEmpty() || connectionName.isNotEmpty() || buttons.isNotEmpty() ||
                (tokenExchangeResource != null && tokenExchangeResource!!.shouldSerialize())
    }

    fun serialize(): String {
        return serializeToJsonValue().toString()
    }

    fun serializeToJsonValue(): JSONObject {
        val root = JSONObject()

        if (text.isNotEmpty()) {
            root.put("text", text)
        }

        if (connectionName.isNotEmpty()) {
            root.put("connectionName", connectionName)
        }

        tokenExchangeResource?.let {
            if (it.shouldSerialize()) {
                root.put("tokenExchangeResource", it.serializeToJsonValue())
            }
        }

        if (buttons.isNotEmpty()) {
            val buttonsArray = JSONArray()
            buttons.forEach { button ->
                if (button.shouldSerialize()) {
                    buttonsArray.put(button.serializeToJsonValue())
                }
            }
            root.put("buttons", buttonsArray)
        }

        return root
    }

    companion object {
        fun deserialize(json: JSONObject): Authentication {
            val text = json.optString("text", "")
            val connectionName = json.optString("connectionName", "")
            val tokenExchangeResource = json.optJSONObject("tokenExchangeResource")?.let {
                TokenExchangeResource.deserialize(it)
            }
            val buttons = json.optJSONArray("buttons")?.let { array ->
                List(array.length()) { index ->
                    AuthCardButton.deserialize(array.getJSONObject(index))
                }
            } ?: emptyList()

            return Authentication(text, connectionName, tokenExchangeResource, buttons)
        }

        fun deserializeFromString(jsonString: String): Authentication {
            return deserialize(JSONObject(jsonString))
        }
    }
}