// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.parser

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.StyledCollectionElement
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ContainerBleedDirection
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ContainerStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ErrorStatusCode
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.InternalId
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.InternalId.Companion.INVALID

class ParseContext {

    private var elementParserRegistration: ElementParserRegistration = ElementParserRegistration()
    private var actionParserRegistration: ActionParserRegistration = ActionParserRegistration()
    val warnings: MutableList<ParseWarning> = mutableListOf()

    // A list of triples: (id JSON property, internal ID, isFallback)
    private val idStack: MutableList<Triple<String, InternalId, Boolean>> = mutableListOf()

    // Simulate a multimap of element IDs to an InternalId. (Multiple entries per id may occur.)
    private val elementIds: MutableList<Pair<String, InternalId>> = mutableListOf()

    private val parentalContainerStyles: MutableList<ContainerStyle> = mutableListOf()
    private val parentalPadding: MutableList<InternalId> = mutableListOf()
    private val parentalBleedDirection: MutableList<ContainerBleedDirection> = mutableListOf()

    var canFallbackToAncestor: Boolean = false
    private var language: String = ""

    // Default constructor
    constructor()

    // Constructor with registrations; if null, defaults are used.
    constructor(
        elementRegistration: ElementParserRegistration?,
        actionRegistration: ActionParserRegistration?
    ) {
        elementParserRegistration = elementRegistration ?: ElementParserRegistration()
        actionParserRegistration = actionRegistration ?: ActionParserRegistration()
    }

    // Push the provided state onto our ID stack.
    fun pushElement(idJsonProperty: String, internalId: InternalId, isFallback: Boolean = false) {
        if (internalId.internalId == INVALID) {
            throw ParseException(
                ErrorStatusCode.InvalidPropertyValue,
                "Attempting to push an element on to the stack with an invalid ID"
            )
        }
        idStack.add(Triple(idJsonProperty, internalId, isFallback))
    }

    // Pop the last ID off our stack and perform collision detection.
    fun popElement() {
        if (idStack.isEmpty()) return

        // Destructure the last element.
        val (elementId, elementInternalId, isFallback) = idStack.last()
        if (elementId.isNotEmpty()) {
            var haveCollision = false
            val nearestFallbackId = getNearestFallbackId(elementInternalId)

            // Walk through the list of elements we've seen with this ID.
            elementIds.filter { it.first == elementId }.forEach { entry ->
                val entryFallbackId = entry.second

                // If the element we're about to pop is the fallback parent for this entry, no collision.
                if (entryFallbackId == elementInternalId) {
                    haveCollision = false
                    return@forEach // Break out of this iteration.
                }

                // Try to get the parent element in the stack (if any).
                try {
                    val previousInStack = idStack[idStack.size - 2]
                    if (previousInStack.second == entryFallbackId) {
                        // This entry belongs to our parent’s fallback content.
                        return@forEach
                    }
                } catch (e: IndexOutOfBoundsException) {
                    // We're at the top level.
                }

                // If the current element is fallback, skip checking further.
                if (isFallback) {
                    return@forEach
                }

                // Otherwise, mark a collision.
                haveCollision = true
            }

            if (haveCollision) {
                throw ParseException(
                    ErrorStatusCode.IdCollision,
                    "Collision detected for id '$elementId'"
                )
            }

            // For non-fallback elements, add an entry for future collision checking.
            if (!isFallback) {
                elementIds.add(Pair(elementId, nearestFallbackId))
            }
        }
        idStack.removeAt(idStack.lastIndex)
    }

    // Walk the ID stack in reverse looking for the first element marked as fallback (skipping skipId).
    fun getNearestFallbackId(skipId: InternalId): InternalId {
        for (entry in idStack.asReversed()) {
            if (entry.third) { // isFallback == true
                if (entry.second != skipId) {
                    return entry.second
                }
            }
        }
        return InternalId()
    }

    fun getParentalContainerStyle(): ContainerStyle {
        return if (parentalContainerStyles.isNotEmpty()) {
            parentalContainerStyles.last()
        } else {
            ContainerStyle.DEFAULT
        }
    }

    fun setParentalContainerStyle(style: ContainerStyle) {
        if (style != ContainerStyle.NONE) {
            parentalContainerStyles.add(style)
        }
    }

    fun paddingParentInternalId(): InternalId {
        return if (parentalPadding.isNotEmpty()) {
            parentalPadding.last()
        } else {
            InternalId()
        }
    }

    fun saveContextForStyledCollectionElement(current: StyledCollectionElement) {
        // Save the current style value if not "None"
        if (current.style != ContainerStyle.NONE) {
            current.style?.let { parentalContainerStyles.add(it) }
        }
        // Save the current element's internal ID if it has padding.
        if (current.hasPadding == true) {
            pushBleedDirection(ContainerBleedDirection.BleedAll)
            current.internalId?.let { parentalPadding.add(it) }
        }
    }

    fun restoreContextForStyledCollectionElement(current: StyledCollectionElement) {
        // Pop the container style if applicable.
        if (parentalContainerStyles.isNotEmpty() && current.style != ContainerStyle.NONE) {
            parentalContainerStyles.removeAt(parentalContainerStyles.lastIndex)
        }
        // Restore parent's padding and bleed direction.
        if (current.hasPadding == true) {
            if (parentalPadding.isNotEmpty()) {
                parentalPadding.removeAt(parentalPadding.lastIndex)
            }
            popBleedDirection()
        }
    }

    fun getBleedDirection(): ContainerBleedDirection {
        return if (parentalBleedDirection.isNotEmpty()) {
            parentalBleedDirection.last()
        } else {
            ContainerBleedDirection.BleedAll
        }
    }

    fun pushBleedDirection(direction: ContainerBleedDirection) {
        parentalBleedDirection.add(direction)
    }

    fun popBleedDirection() {
        if (parentalBleedDirection.isNotEmpty()) {
            parentalBleedDirection.removeAt(parentalBleedDirection.lastIndex)
        }
    }

    fun setLanguage(value: String) {
        language = value
    }

    fun getLanguage(): String = language
}
