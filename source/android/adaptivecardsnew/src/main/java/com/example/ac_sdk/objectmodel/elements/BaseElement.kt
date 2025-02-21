package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.FallbackType
import com.example.ac_sdk.objectmodel.utils.InternalId
import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

@Serializable
sealed class BaseElement {
    var id: String? = null
    var typeString: String? = null
    var additionalProperties: JsonElement? = null
    var requires: Map<String, SemanticVersion>? = null
    var fallback: BaseElement? = null
    var internalId: InternalId? = InternalId.next()
    var fallbackType: FallbackType? = FallbackType.NONE
    var canFallbackToAncestor: Boolean? = null

    val knownPropertiesSet: Set<AdaptiveCardSchemaKey> by lazy {
        populateKnownPropertiesSet()
    }
    // Each subclass must implement this to return its known properties.
    protected open fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
        return mutableSetOf()
    }

    fun serialize(): String {
        return try {
            Json.encodeToString(this)
        } catch (e: Exception) {
            ""
        }
    }

}