// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.serializer.FallbackSerializer
import io.adaptivecards.adaptivecardsv2.objectmodel.serializer.SemanticVersionMapSerializer
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.InternalId
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.SemanticVersion
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

@Serializable
sealed class BaseElement(
    var id: String? = null,
    var typeString: String? = null,
    var additionalProperties: JsonElement? = null,

    @Serializable(with = SemanticVersionMapSerializer::class)
    var requires: Map<String, SemanticVersion>? = null,

    @Serializable(with = FallbackSerializer::class)
    var fallback: BaseElement? = null,

    @Transient var internalId: InternalId? = InternalId.next(),
    //var fallbackType: FallbackType? = FallbackType.NONE,
    var canFallbackToAncestor: Boolean? = null
) {

    val knownPropertiesSet: Set<AdaptiveCardSchemaKey> by lazy {
        populateKnownPropertiesSet()
    }

    // Each subclass must implement this to return its known properties.
    protected open fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
        return mutableSetOf()
    }

    open fun serialize(): String? {
        return try {
            Json.encodeToString(serializer(), this)
        } catch (e: Exception) {
            ""
        }
    }
}

@Serializable
data object DropElement : BaseElement()