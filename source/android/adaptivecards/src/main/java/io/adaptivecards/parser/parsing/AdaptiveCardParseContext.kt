package io.adaptivecards.parser.parsing

import io.adaptivecards.parser.elements.BaseCardElement

class ParseContext(val elementParserRegistration: ElementParserRegistration)

class ElementParserRegistration {
    // Implement this method based on your specific requirements.
    fun getParser(type: String): ElementParser? {
        return null
    }
}

interface ElementParser {
    fun deserialize(context: ParseContext, json: Map<String, Any>): BaseCardElement?
}

