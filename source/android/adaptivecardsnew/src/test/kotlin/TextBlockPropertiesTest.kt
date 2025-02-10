package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.utils.FontType
import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.TextSize
import com.example.ac_sdk.objectmodel.utils.TextStyle
import com.example.ac_sdk.objectmodel.utils.TextWeight
import org.junit.Assert.assertEquals
import org.junit.Test

class TextBlockPropertiesTest : BaseModelTest() {

    @Test
    fun `test TextBlock properties`() {
        val jsonString = """
            {
                "id": "id1",
                "type": "TextBlock",
                "text": "Sample Text",
                "color": "Default",
                "horizontalAlignment": "center",
                "isSubtle": true,
                "italic": false,
                "maxLines": 3,
                "size": "Medium",
                "weight": "Bolder",
                "wrap": true,
                "strikethrough": false,
                "style": "default",
                "fontType": "Default",
                "highlight": false,
                "underline": true
            }
        """.trimIndent()

        val textBlock = json.decodeFromString<CardElements.TextBlock>(jsonString)

        assertEquals("id1", textBlock.id)
        assertEquals("Sample Text", textBlock.text)
        assertEquals(ForegroundColor.DEFAULT, textBlock.color)
        assertEquals(HorizontalAlignment.CENTER, textBlock.horizontalAlignment)
        assertEquals(true, textBlock.isSubtle)
        assertEquals(false, textBlock.italic)
        assertEquals(3, textBlock.maxLines)
        assertEquals(TextSize.MEDIUM, textBlock.size)
        assertEquals(TextWeight.BOLDER, textBlock.weight)
        assertEquals(true, textBlock.wrap)
        assertEquals(false, textBlock.strikethrough)
        assertEquals(TextStyle.DEFAULT, textBlock.style)
        assertEquals(FontType.DEFAULT, textBlock.fontType)
        assertEquals(false, textBlock.highlight)
        assertEquals(true, textBlock.underline)
    }

}