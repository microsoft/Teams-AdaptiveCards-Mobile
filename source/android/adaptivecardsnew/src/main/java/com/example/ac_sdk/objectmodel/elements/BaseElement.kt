package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.FallbackType
import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

@Serializable
@Polymorphic
sealed class BaseElement {
    var id: String? = null
    var typeString: String? = null
    var additionalProperties: Map<String, JsonElement>? = null
    var requires: Map<String, SemanticVersion>? = null
    var fallback: BaseElement? = null
    var internalId: InternalId? = InternalId.next()
    var fallbackType: FallbackType? = FallbackType.NONE
    var canFallbackToAncestor: Boolean? = null

    fun serialize(): String {
        return try {
            Json.encodeToString(this)
        } catch (e: Exception) {
            ""
        }
    }
}


// --- Supporting types ---

@Serializable
data class InternalId(val id: UInt) {
    companion object {
        private var currentId: UInt = 1u
        fun current(): InternalId = InternalId(currentId)
        fun next(): InternalId {
            currentId++
            return current()
        }
    }
}
