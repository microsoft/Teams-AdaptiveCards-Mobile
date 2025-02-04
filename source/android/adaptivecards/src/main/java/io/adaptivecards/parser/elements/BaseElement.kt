package io.adaptivecards.parser.elements

import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
@Polymorphic
sealed class BaseElement {
    var id: String? = null
    var typeString: String? = null
    var additionalProperties: Map<String, JsonElement>? = null
    var requires: Map<String, SemanticVersion>? = null
    var fallback: CardElement? = null
    var internalId: InternalId? = InternalId.next()
    var fallbackType: FallbackType? = FallbackType.NONE
    var canFallbackToAncestor: Boolean? = null
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

@Serializable
enum class FallbackType {
    @SerialName("none")
    NONE,

    @SerialName("content")
    CONTENT
}

@Serializable
data class SemanticVersion(val major: Int, val minor: Int, val patch: Int)
