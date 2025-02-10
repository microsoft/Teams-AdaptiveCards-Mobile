package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class InputTogglePropertiesTest : BaseModelTest() {

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

        val inputToggle = json.decodeFromString<InputElements.InputToggle>(jsonString)

        assertEquals("Toggle option", inputToggle.title)
        assertEquals("true", inputToggle.value)
        assertEquals("true", inputToggle.valueOn)
        assertEquals("false", inputToggle.valueOff)
        assertEquals(true, inputToggle.wrap)
    }
}