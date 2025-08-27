// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.parser

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.BaseCardElement
import org.json.JSONObject

interface BaseCardElementParser {
    fun deserialize(context: ParseContext, value: JSONObject): BaseCardElement
    fun deserializeFromString(context: ParseContext, value: String): BaseCardElement {
        return deserialize(context, JSONObject(value))
    }
}

class BaseCardElementParserWrapper(private val parserToWrap: BaseCardElementParser) :
    BaseCardElementParser {
    override fun deserialize(context: ParseContext, value: JSONObject): BaseCardElement {
        val idProperty = value.optString("id")
       // val internalId = InternalId.next()
        val internalId = "internalId"

        //context.pushElement(idProperty, false)
        val element = parserToWrap.deserialize(context, value)
        context.popElement()

        return element
    }

    override fun deserializeFromString(context: ParseContext, value: String): BaseCardElement {
        return deserialize(context, JSONObject(value))
    }

    fun getActualParser(): BaseCardElementParser {
        return parserToWrap
    }
}

class ElementParserRegistration {
    private val knownElements = mutableSetOf(
        "ActionSet", "ChoiceSetInput", "Column", "ColumnSet", "CompoundButton", "Container",
        "DateInput", "FactSet", "Image", "Icon", "ImageSet", "Media", "NumberInput",
        "RatingInput", "RatingLabel", "RichTextBlock", "Table", "TextBlock", "TextInput",
        "TimeInput", "ToggleInput", "Unknown"
    )

//    private val cardElementParsers = mutableMapOf(
//        "ActionSet" to ActionSetParser(),
//        "ChoiceSetInput" to ChoiceSetInputParser(),
//        "Column" to ColumnParser(),
//        "ColumnSet" to ColumnSetParser(),
//        "Container" to ContainerParser(),
//        "DateInput" to DateInputParser(),
//        "FactSet" to FactSetParser(),
//        "Image" to ImageParser(),
//        "Icon" to IconParser(),
//        "ImageSet" to ImageSetParser(),
//        "Media" to MediaParser(),
//        "NumberInput" to NumberInputParser(),
//        "RatingInput" to RatingInputParser(),
//        "RatingLabel" to RatingLabelParser(),
//        "RichTextBlock" to RichTextBlockParser(),
//        "Table" to TableParser(),
//        "TextBlock" to TextBlockParser(),
//        "TextInput" to TextInputParser(),
//        "TimeInput" to TimeInputParser(),
//        "ToggleInput" to ToggleInputParser(),
//        "CompoundButton" to CompoundButtonParser(),
//        "Unknown" to UnknownElementParser()
//    )

//    fun addParser(elementType: String, parser: BaseCardElementParser) {
//        if (knownElements.contains(elementType)) {
//          //  throw AdaptiveCardParseException("Overriding known element parsers is unsupported")
//        } else {
//            cardElementParsers[elementType] = parser
//        }
//    }
//
//    fun removeParser(elementType: String) {
//        if (knownElements.contains(elementType)) {
//           // throw AdaptiveCardParseException("Overriding known element parsers is unsupported")
//        } else {
//            cardElementParsers.remove(elementType)
//        }
//    }

//    fun getParser(elementType: String): BaseCardElementParser? {
//        //return cardElementParsers[elementType]?.let { BaseCardElementParserWrapper(it) }
//    }
}