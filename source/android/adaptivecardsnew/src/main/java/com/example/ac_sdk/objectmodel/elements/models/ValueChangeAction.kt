package com.example.ac_sdk.objectmodel.elements.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
class ValueChangedAction(
    var targetInputIds: List<String> = emptyList(),  // Getters & Setters are auto-generated
    var valueChangedActionType: ValueChangedActionType = ValueChangedActionType.RESET_INPUTS
) {
    fun shouldSerialize(): Boolean = targetInputIds.isNotEmpty()

    fun serialize(): String? = try {
        Json.encodeToString(ValueChangedAction.serializer(),this)
    } catch (e: Exception) {
        null
    }

    companion object {
        fun deserialize(jsonString: String): ValueChangedAction? = try {
            Json.decodeFromString(jsonString)
        } catch (e: Exception) {
            null
        }
    }
}

@Serializable
enum class ValueChangedActionType {
    @SerialName("resetInputs")
    RESET_INPUTS
}