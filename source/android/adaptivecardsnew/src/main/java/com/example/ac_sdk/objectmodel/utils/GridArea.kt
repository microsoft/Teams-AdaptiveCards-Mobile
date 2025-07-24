package com.example.ac_sdk.objectmodel.utils

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

@Serializable
data class GridArea(
    val name: String,
    val row: Int,
    val rowSpan: Int,
    val column: Int,
    val columnSpan: Int
) {

    companion object {
        fun deserialize(json: JsonElement): GridArea {
            return Json.decodeFromJsonElement(serializer(), json)
        }

        fun deserializeFromString(jsonString: String): GridArea {
            return Json.decodeFromString(serializer(), jsonString)
        }
    }
}