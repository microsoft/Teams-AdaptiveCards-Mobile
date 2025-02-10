package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
import org.junit.Assert.assertEquals
import org.junit.Test

class RichTextBlockPropertiesTest : BaseModelTest() {

    @Test
    fun `test RichTextBlock properties`() {
        val jsonString = """
            {
                "type": "richTextBlock",
                "inlines": [
                    {
                        "type": "TextRun",
                        "text": "Sample Text"
                    }
                ]
            }
        """.trimIndent()

        val richTextBlock = json.decodeFromString<CardElements.RichTextBlock>(jsonString)

        assertEquals(1, richTextBlock.inlines.size)
        assertEquals("TextRun", richTextBlock.inlines[0].type)
        assertEquals("Sample Text", richTextBlock.inlines[0].text)
    }
}