package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class InputTextPropertiesTest : BaseModelTest() {

    @Test
    fun `test InputText properties`() {
        val jsonString = """
            {
                "type": "Input.Text",
                "isMultiline": true,
                "maxLength": 100,
                "placeholder": "Enter text",
                "style": "text",
                "value": "Sample text"
            }
        """.trimIndent()

        val inputText = json.decodeFromString<InputElements.InputText>(jsonString)

        assertEquals(true, inputText.isMultiline)
        assertEquals(100, inputText.maxLength)
        assertEquals("Enter text", inputText.placeholder)
        assertEquals("text", inputText.style)
        assertEquals("Sample text", inputText.value)
    }

}