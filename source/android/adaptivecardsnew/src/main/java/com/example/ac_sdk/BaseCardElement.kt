package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.CardElementType
import com.example.ac_sdk.objectmodel.HeightType
import com.example.ac_sdk.objectmodel.HostWidth
import com.example.ac_sdk.objectmodel.TargetWidthType
import org.json.JSONObject

class BaseCardElement(
    var type: CardElementType,
    var spacing: Spacing = Spacing.Default,
    var separator: Boolean = false,
    var height: HeightType = HeightType.Auto,
    var targetWidth: TargetWidthType = TargetWidthType.Default,
    var isVisible: Boolean = true,
    var areaGridName: String? = null,
    var nonOptionalAreaGridName: String = ""
) {
    private val knownProperties = mutableSetOf<String>()

    init {
        setTypeString(type.toString())
        populateKnownPropertiesSet()
    }

    private fun setTypeString(typeString: String) {
        // Implementation here
    }

    private fun populateKnownPropertiesSet() {
        knownProperties.addAll(
            listOf(
                "height",
                "isVisible",
                "minHeight",
                "targetWidth",
                "separator",
                "spacing"
            )
        )
    }

    fun serializeToJson(): JSONObject {
        val root = JSONObject()

        if (height != HeightType.Auto) {
            root.put("height", height.toString())
        }

        if (spacing != Spacing.Default) {
            root.put("spacing", spacing.toString())
        }

        if (separator) {
            root.put("separator", true)
        }

        areaGridName?.let {
            root.put("areaGridName", it)
        }

        if (targetWidth != TargetWidthType.Default) {
            root.put("targetWidth", targetWidth.toString())
        }

        if (!isVisible) {
            root.put("isVisible", false)
        }

        return root
    }

    fun parseJsonObject(json: JSONObject) {
        val typeString = json.getString("type")
        // Assuming a method to get parser by typeString
        val parser = getParser(typeString) ?: getParser("Unknown")
        val parsedElement = parser?.deserialize(json)
        parsedElement?.let {
            // Assign parsed element to this instance
        } ?: throw IllegalArgumentException("Unable to parse element of type $typeString")
    }

    private fun getParser(typeString: String): BaseCardElementParser? {
        // Implementation to get parser by typeString
        return null
    }

    fun meetsTargetWidthRequirement(hostWidth: HostWidth): Boolean {
        return when (targetWidth) {
            TargetWidthType.Default -> true
            TargetWidthType.Wide -> hostWidth == HostWidth.Wide
            TargetWidthType.Standard -> hostWidth == HostWidth.Standard
            TargetWidthType.Narrow -> hostWidth == HostWidth.Narrow
            TargetWidthType.VeryNarrow -> hostWidth == HostWidth.VeryNarrow
            TargetWidthType.AtLeastWide -> hostWidth >= HostWidth.Wide
            TargetWidthType.AtLeastStandard -> hostWidth >= HostWidth.Standard
            TargetWidthType.AtLeastNarrow -> hostWidth >= HostWidth.Narrow
            TargetWidthType.AtLeastVeryNarrow -> hostWidth >= HostWidth.VeryNarrow
            TargetWidthType.AtMostWide -> hostWidth <= HostWidth.Wide
            TargetWidthType.AtMostStandard -> hostWidth <= HostWidth.Standard
            TargetWidthType.AtMostNarrow -> hostWidth <= HostWidth.Narrow
            TargetWidthType.AtMostVeryNarrow -> hostWidth <= HostWidth.VeryNarrow
        }
    }

    companion object {
        fun deserializeBasePropertiesFromString(jsonString: String): BaseCardElement {
            val json = JSONObject(jsonString)
            return deserializeBaseProperties(json)
        }

        fun deserializeBaseProperties(json: JSONObject): BaseCardElement {
            val element = BaseCardElement(CardElementType.valueOf(json.getString("type")))
            element.deserializeBaseProperties(json)
            return element
        }
    }

    private fun deserializeBaseProperties(json: JSONObject) {
        // Deserialize properties
        height = HeightType.valueOf(json.optString("height", HeightType.Auto.name))
        targetWidth = TargetWidthType.valueOf(json.optString("targetWidth", TargetWidthType.Default.name))
        isVisible = json.optBoolean("isVisible", true)
        separator = json.optBoolean("separator", false)
        spacing = Spacing.valueOf(json.optString("spacing", Spacing.Default.name))
        areaGridName = json.optString("areaGridName", null)
        nonOptionalAreaGridName = json.optString("areaGridName", "")
    }
}

interface BaseCardElementParser {
    fun deserialize(json: JSONObject): BaseCardElement?
}