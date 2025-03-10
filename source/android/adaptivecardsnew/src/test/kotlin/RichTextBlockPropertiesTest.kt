package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElement
import com.example.ac_sdk.objectmodel.elements.models.TextRun
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
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

        val richTextBlock = json.decodeFromString<CardElement.RichTextBlock>(jsonString)

        assertEquals(1, richTextBlock.inlines.size)
        assertTrue(richTextBlock.inlines[0] is TextRun)
    }
}