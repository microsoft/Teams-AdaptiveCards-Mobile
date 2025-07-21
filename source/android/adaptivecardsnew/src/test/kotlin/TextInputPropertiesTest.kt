package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElement
import com.example.ac_sdk.objectmodel.utils.TextInputStyle
import org.junit.Assert.assertEquals
import org.junit.Test

class TextInputPropertiesTest : BaseModelTest() {

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

        val textInput = json.decodeFromString<InputElement.TextInput>(jsonString)

        assertEquals(true, textInput.isMultiline)
        assertEquals(100, textInput.maxLength)
        assertEquals("Enter text", textInput.placeholder)
        assertEquals(TextInputStyle.TEXT, textInput.style)
        assertEquals("Sample text", textInput.value)
    }

}