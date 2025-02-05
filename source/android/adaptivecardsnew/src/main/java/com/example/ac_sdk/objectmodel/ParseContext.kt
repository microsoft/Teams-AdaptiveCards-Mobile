package com.example.ac_sdk.objectmodel

import java.util.*

class ParseContext(
    var elementParserRegistration: ElementParserRegistration = ElementParserRegistration(),
    var actionParserRegistration: ActionParserRegistration = ActionParserRegistration()
) {
    var warnings: MutableList<AdaptiveCardParseWarning> = mutableListOf()
   // private val elementIds: MutableMap<String> = mutableMapOf()
    //private val idStack: Stack<Double<String, Boolean>> = Stack()
    private val parentalContainerStyles: Stack<ContainerStyle> = Stack()
    private val parentalBleedDirection: Stack<ContainerBleedDirection> = Stack()
    private var canFallbackToAncestor: Boolean = false
    private var language: String = ""

    fun pushElement(idJsonProperty: String, isFallback: Boolean = false) {
      //  idStack.push(Triple(idJsonProperty, isFallback))
    }

    fun popElement() {
//        val idsToPop = idStack.pop()
//        val elementId = idsToPop.first
//        val elementInternalId = idsToPop.second
//        val isFallback = idsToPop.third

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