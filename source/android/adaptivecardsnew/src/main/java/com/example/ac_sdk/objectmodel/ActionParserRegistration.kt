package com.example.ac_sdk.objectmodel

import org.json.JSONObject

abstract class ActionElementParser {
    abstract fun deserialize(context: ParseContext, value: JSONObject): ActionElement
    abstract fun deserializeFromString(context: ParseContext, value: String): ActionElement
}

class ActionElementParserWrapper(private val parser: ActionElementParser) : ActionElementParser() {
    override fun deserialize(context: ParseContext, value: JSONObject): ActionElement {
        val idProperty = value.getString("id")
        context.pushElement(idProperty, false)
        val element = parser.deserialize(context, value)
        context.popElement()
        return element
    }

    override fun deserializeFromString(context: ParseContext, value: String): ActionElement {
        return deserialize(context, JSONObject(value))
    }

    fun getActualParser(): ActionElementParser {
        return parser
    }
}

class ActionParserRegistration {
    private val knownElements = mutableSetOf(
        ActionType.EXECUTE.toString(),
        ActionType.OPENURL.toString(),
        ActionType.SHOWCARD.toString(),
        ActionType.SUBMIT.toString(),
        ActionType.TOGGLEVISIBILITY.toString(),
    )

//    private val cardElementParsers = mutableListOf((
//        ActionType.EXECUTE.toString() to ExecuteActionParser(),
//        ActionType.OPEN_URL.toString() to OpenUrlActionParser(),
//        ActionType.SHOW_CARD.toString() to ShowCardActionParser(),
//        ActionType.SUBMIT.toString() to SubmitActionParser(),
//        ActionType.TOGGLE_VISIBILITY.toString() to ToggleVisibilityActionParser(),
//        ActionType.UNKNOWN_ACTION.toString() to UnknownActionParser()
//    )
//
//    fun addParser(elementType: String, parser: ActionElementParser) {
//        if (knownElements.contains(elementType)) {
//            throw UnsupportedOperationException("Overriding known action parsers is unsupported")
//        }
//        cardElementParsers[elementType] = parser
//    }
//
//    fun removeParser(elementType: String) {
//        if (knownElements.contains(elementType)) {
//            throw UnsupportedOperationException("Removing known action parsers is unsupported")
//        }
//        cardElementParsers.remove(elementType)
//    }
//
//    fun getParser(elementType: String): ActionElementParser? {
//        val parser = cardElementParsers[elementType] ?: return null
//        return ActionElementParserWrapper(parser)
//    }
}