package com.example.ac_sdk.objectmodel

package io.adaptivecards.objectmodel

import org.json.JSONObject

abstract class ActionElementParser {
    abstract fun deserialize(context: ParseContext, value: JSONObject): BaseActionElement
    abstract fun deserializeFromString(context: ParseContext, value: String): BaseActionElement
}

class ActionElementParserWrapper(private val parser: ActionElementParser) : ActionElementParser() {
    override fun deserialize(context: ParseContext, value: JSONObject): BaseActionElement {
        val idProperty = value.getString("id")
        val internalId = InternalId.next()
        context.pushElement(idProperty, internalId)
        val element = parser.deserialize(context, value)
        context.popElement()
        return element
    }

    override fun deserializeFromString(context: ParseContext, value: String): BaseActionElement {
        return deserialize(context, JSONObject(value))
    }

    fun getActualParser(): ActionElementParser {
        return parser
    }
}

class ActionParserRegistration {
    private val knownElements = mutableSetOf(
        ActionType.EXECUTE.toString(),
        ActionType.OPEN_URL.toString(),
        ActionType.SHOW_CARD.toString(),
        ActionType.SUBMIT.toString(),
        ActionType.TOGGLE_VISIBILITY.toString(),
        ActionType.UNKNOWN_ACTION.toString()
    )

    private val cardElementParsers = mutableMapOf(
        ActionType.EXECUTE.toString() to ExecuteActionParser(),
        ActionType.OPEN_URL.toString() to OpenUrlActionParser(),
        ActionType.SHOW_CARD.toString() to ShowCardActionParser(),
        ActionType.SUBMIT.toString() to SubmitActionParser(),
        ActionType.TOGGLE_VISIBILITY.toString() to ToggleVisibilityActionParser(),
        ActionType.UNKNOWN_ACTION.toString() to UnknownActionParser()
    )

    fun addParser(elementType: String, parser: ActionElementParser) {
        if (knownElements.contains(elementType)) {
            throw UnsupportedOperationException("Overriding known action parsers is unsupported")
        }
        cardElementParsers[elementType] = parser
    }

    fun removeParser(elementType: String) {
        if (knownElements.contains(elementType)) {
            throw UnsupportedOperationException("Removing known action parsers is unsupported")
        }
        cardElementParsers.remove(elementType)
    }

    fun getParser(elementType: String): ActionElementParser? {
        val parser = cardElementParsers[elementType] ?: return null
        return ActionElementParserWrapper(parser)
    }
}