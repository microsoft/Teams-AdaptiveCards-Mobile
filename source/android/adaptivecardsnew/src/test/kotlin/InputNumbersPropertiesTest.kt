package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class InputNumbersPropertiesTest : BaseModelTest() {

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

        val inputNumber = json.decodeFromString<InputElements.InputNumber>(jsonString)

        assertEquals(1.0, inputNumber.min)
        assertEquals(10.0, inputNumber.max)
        assertEquals("Enter number", inputNumber.placeholder)
        assertEquals(5.0, inputNumber.value)
    }
}