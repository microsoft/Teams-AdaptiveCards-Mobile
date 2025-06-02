package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElement
import org.junit.Assert.assertEquals
import org.junit.Test

class ToggleInputPropertiesTest : BaseModelTest() {

    @Test
    fun `test InputToggle properties`() {
        val jsonString = """
            {
                "type": "Input.Toggle",
                "title": "Toggle option",
                "value": "true",
                "valueOn": "true",
                "valueOff": "false",
                "wrap": true
            }
        """.trimIndent()

        val toggleInput = json.decodeFromString<InputElement.ToggleInput>(jsonString)

        assertEquals("Toggle option", toggleInput.title)
        assertEquals("true", toggleInput.value)
        assertEquals("true", toggleInput.valueOn)
        assertEquals("false", toggleInput.valueOff)
        assertEquals(true, toggleInput.wrap)
    }
}