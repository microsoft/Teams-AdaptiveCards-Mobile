package com.example.ac_sdk.objectmodel

import org.json.JSONObject

data class DateTimePreparser(val text: String)

data class TextElementProperties(
    var text: String = "",
    var textSize: TextSize? = null,
    var textWeight: TextWeight? = null,
    var fontType: FontType? = null,
    var textColor: ForegroundColor? = null,
    var isSubtle: Boolean? = null,
    var language: String = ""
) {
    fun serializeToJsonValue(): JSONObject {
        val json = JSONObject()
        json.put("text", text)
        textSize?.let { json.put("textSize", it.name) }
        textWeight?.let { json.put("textWeight", it.name) }
        fontType?.let { json.put("fontType", it.name) }
        textColor?.let { json.put("textColor", it.name) }
        isSubtle?.let { json.put("isSubtle", it) }
        json.put("language", language)
        return json
    }

    fun deserialize(json: JSONObject) {
        text = json.optString("text", "")
        textSize = json.optString("textSize", null)?.let { TextSize.valueOf(it) }
        textWeight = json.optString("textWeight", null)?.let { TextWeight.valueOf(it) }
        fontType = json.optString("fontType", null)?.let { FontType.valueOf(it) }
        textColor = json.optString("textColor", null)?.let { ForegroundColor.valueOf(it) }
        isSubtle = json.optBoolean("isSubtle", false)
        language = json.optString("language", "")
    }
}

class TextBlock(
    var wrap: Boolean = false,
    var maxLines: Int = 0,
    var hAlignment: HorizontalAlignment? = null,
    var textStyle: TextStyle? = null,
    var textElementProperties: TextElementProperties = TextElementProperties()
) {
    fun serializeToJsonValue(): JSONObject {
        val json = textElementProperties.serializeToJsonValue()
        hAlignment?.let { json.put("horizontalAlignment", it.name) }
        if (maxLines != 0) json.put("maxLines", maxLines)
        if (wrap) json.put("wrap", wrap)
        textStyle?.let { json.put("style", it.name) }
        return json
    }

    fun getText(): String = textElementProperties.text
    fun setText(value: String) { textElementProperties.text = value }

    fun getTextForDateParsing(): DateTimePreparser = DateTimePreparser(textElementProperties.text)

    fun getStyle(): TextStyle? = textStyle
    fun setStyle(value: TextStyle?) { textStyle = value }

    fun getTextSize(): TextSize? = textElementProperties.textSize
    fun setTextSize(value: TextSize?) { textElementProperties.textSize = value }

    fun getTextWeight(): TextWeight? = textElementProperties.textWeight
    fun setTextWeight(value: TextWeight?) { textElementProperties.textWeight = value }

    fun getFontType(): FontType? = textElementProperties.fontType
    fun setFontType(value: FontType?) { textElementProperties.fontType = value }

    fun getTextColor(): ForegroundColor? = textElementProperties.textColor
    fun setTextColor(value: ForegroundColor?) { textElementProperties.textColor = value }

    fun getWrap(): Boolean = wrap
    fun setWrap(value: Boolean) { wrap = value }

    fun getIsSubtle(): Boolean? = textElementProperties.isSubtle
    fun setIsSubtle(value: Boolean?) { textElementProperties.isSubtle = value }

    fun getMaxLines(): Int = maxLines
    fun setMaxLines(value: Int) { maxLines = value }

    fun getHorizontalAlignment(): HorizontalAlignment? = hAlignment
    fun setHorizontalAlignment(value: HorizontalAlignment?) { hAlignment = value }

    fun getLanguage(): String = textElementProperties.language
    fun setLanguage(value: String) { textElementProperties.language = value }
}

class TextBlockParser {
    fun deserialize(json: JSONObject): TextBlock {
        val textBlock = TextBlock()
        textBlock.textElementProperties.deserialize(json)
        textBlock.wrap = json.optBoolean("wrap", false)
        textBlock.textStyle = json.optString("style", null)?.let { TextStyle.valueOf(it) }
        textBlock.maxLines = json.optInt("maxLines", 0)
        textBlock.hAlignment = json.optString("horizontalAlignment", null)?.let { HorizontalAlignment.valueOf(it) }
        return textBlock
    }

    fun deserializeFromString(jsonString: String): TextBlock {
        val json = JSONObject(jsonString)
        return deserialize(json)
    }
}