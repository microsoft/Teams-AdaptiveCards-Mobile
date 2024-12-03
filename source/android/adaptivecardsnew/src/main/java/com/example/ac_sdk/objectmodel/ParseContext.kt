package com.example.ac_sdk.objectmodel

import java.util.*

class ParseContext(
    var elementParserRegistration: ElementParserRegistration = ElementParserRegistration(),
    var actionParserRegistration: ActionParserRegistration = ActionParserRegistration()
) {
    var warnings: MutableList<AdaptiveCardParseWarning> = mutableListOf()
    private val elementIds: MutableMap<String, InternalId> = mutableMapOf()
    private val idStack: Stack<Triple<String, InternalId, Boolean>> = Stack()
    private val parentalContainerStyles: Stack<ContainerStyle> = Stack()
    private val parentalPadding: Stack<InternalId> = Stack()
    private val parentalBleedDirection: Stack<ContainerBleedDirection> = Stack()
    private var canFallbackToAncestor: Boolean = false
    private var language: String = ""

    fun pushElement(idJsonProperty: String, internalId: InternalId, isFallback: Boolean = false) {
        if (internalId == InternalId.Invalid) {
            throw AdaptiveCardParseException(ErrorStatusCode.InvalidPropertyValue, "Attempting to push an element on to the stack with an invalid ID")
        }
        idStack.push(Triple(idJsonProperty, internalId, isFallback))
    }

    fun popElement() {
        val idsToPop = idStack.pop()
        val elementId = idsToPop.first
        val elementInternalId = idsToPop.second
        val isFallback = idsToPop.third

        if (elementId.isNotEmpty()) {
            var haveCollision = false
            val nearestFallbackId = getNearestFallbackId(elementInternalId)

            elementIds[elementId]?.let { entryFallbackId ->
                if (entryFallbackId != elementInternalId) {
                    if (isFallback) {
                        return@let
                    }
                    haveCollision = true
                }
            }

            if (haveCollision) {
                throw AdaptiveCardParseException(ErrorStatusCode.IdCollision, "Collision detected for id '$elementId'")
            }

            if (!isFallback) {
                elementIds[elementId] = nearestFallbackId
            }
        }
    }

    private fun getNearestFallbackId(skipId: InternalId): InternalId {
        for (curElement in idStack.reversed()) {
            if (curElement.third && curElement.second != skipId) {
                return curElement.second
            }
        }
        return InternalId.Invalid
    }

    fun getParentalContainerStyle(): ContainerStyle {
        return if (parentalContainerStyles.isNotEmpty()) parentalContainerStyles.peek() else ContainerStyle.Default
    }

    fun setParentalContainerStyle(style: ContainerStyle) {
        if (style != ContainerStyle.None) {
            parentalContainerStyles.push(style)
        }
    }

    fun paddingParentInternalId(): InternalId {
        return if (parentalPadding.isNotEmpty()) parentalPadding.peek() else InternalId.Invalid
    }

    fun saveContextForStyledCollectionElement(current: StyledCollectionElement) {
        if (current.style != ContainerStyle.None) {
            parentalContainerStyles.push(current.style)
        }
        if (current.padding) {
            pushBleedDirection(ContainerBleedDirection.BleedAll)
            parentalPadding.push(current.internalId)
        }
    }

    fun restoreContextForStyledCollectionElement(current: StyledCollectionElement) {
        if (current.style != ContainerStyle.None) {
            parentalContainerStyles.pop()
        }
        if (current.padding) {
            parentalPadding.pop()
            popBleedDirection()
        }
    }

    fun getBleedDirection(): ContainerBleedDirection {
        return if (parentalBleedDirection.isNotEmpty()) parentalBleedDirection.peek() else ContainerBleedDirection.BleedAll
    }

    fun pushBleedDirection(direction: ContainerBleedDirection) {
        parentalBleedDirection.push(direction)
    }

    fun popBleedDirection() {
        parentalBleedDirection.pop()
    }

    fun setLanguage(value: String) {
        language = value
    }

    fun getLanguage(): String {
        return language
    }

    fun getCanFallbackToAncestor(): Boolean {
        return canFallbackToAncestor
    }

    fun setCanFallbackToAncestor(value: Boolean) {
        canFallbackToAncestor = value
    }
}