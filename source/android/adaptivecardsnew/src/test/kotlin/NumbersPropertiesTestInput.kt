package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class NumbersPropertiesTestInput : BaseModelTest() {

    @Test
    fun `test InputNumber properties`() {
        val jsonString = """
            {
                "type": "Input.Number",
                "min": 1.0,
                "max": 10.0,
                "placeholder": "Enter number",
                "value": 5.0
            }
        """.trimIndent()

        val numberInput = json.decodeFromString<InputElements.NumberInput>(jsonString)

        assertEquals(1.0, numberInput.min)
        assertEquals(10.0, numberInput.max)
        assertEquals("Enter number", numberInput.placeholder)
        assertEquals(5.0, numberInput.value)
    }
}