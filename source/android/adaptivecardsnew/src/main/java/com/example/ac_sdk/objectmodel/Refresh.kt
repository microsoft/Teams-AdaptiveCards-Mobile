package com.example.ac_sdk.objectmodel

import org.json.JSONArray
import org.json.JSONObject

class Refresh(
    private var action: BaseActionElement? = null,
    private var userIds: List<String> = emptyList()
) {

    fun getAction(): BaseActionElement? {
        return action
    }

    fun setAction(action: BaseActionElement?) {
        this.action = action
    }

    fun getUserIds(): List<String> {
        return userIds
    }

    fun setUserIds(userIds: List<String>) {
        this.userIds = userIds
    }

    // Indicates non-default values have been set. If false, serialization can be safely skipped.
    fun shouldSerialize(): Boolean {
        return action != null || userIds.isNotEmpty()
    }

    fun serialize(): String {
        return serializeToJsonValue().toString()
    }

    fun serializeToJsonValue(): JSONObject {
        val root = JSONObject()

        action?.let {
            root.put(AdaptiveCardSchemaKey.Action.toString(), it.serializeToJsonValue())
        }

        if (userIds.isNotEmpty()) {
            val userIdsArray = JSONArray()
            userIds.forEach { userId ->
                userIdsArray.put(userId)
            }
            root.put(AdaptiveCardSchemaKey.UserIds.toString(), userIdsArray)
        }

        return root
    }

    companion object {
        fun deserialize(context: ParseContext, json: JSONObject): Refresh {
            val action = ParseUtil.getAction(context, json, AdaptiveCardSchemaKey.Action)
            val userIds = ParseUtil.getStringArray(json, AdaptiveCardSchemaKey.UserIds)
            return Refresh(action, userIds)
        }

        fun deserializeFromString(context: ParseContext, jsonString: String): Refresh {
            val json = JSONObject(jsonString)
            return deserialize(context, json)
        }
    }
}