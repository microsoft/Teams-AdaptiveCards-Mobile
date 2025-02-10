package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class InputDateTimePropertiesTest : BaseModelTest() {

    @Test
    fun `test InputDate properties`() {
        val jsonString = """
            {
                "type": "Input.Date",
                "min": "2023-01-01",
                "max": "2023-12-31",
                "value": "2023-06-15",
                "placeholder": "Select date"
            }
        """.trimIndent()

        val inputDate = json.decodeFromString<InputElements.InputDate>(jsonString)

        assertEquals("2023-01-01", inputDate.min)
        assertEquals("2023-12-31", inputDate.max)
        assertEquals("2023-06-15", inputDate.value)
        assertEquals("Select date", inputDate.placeholder)
    }

    @Test
    fun `test InputTime properties`() {
        val jsonString = """
            {
                "type": "Input.Time",
                "min": "08:00",
                "max": "18:00",
                "value": "12:00",
                "placeholder": "Select time"
            }
        """.trimIndent()

        val inputTime = json.decodeFromString<InputElements.InputTime>(jsonString)

        assertEquals("08:00", inputTime.min)
        assertEquals("18:00", inputTime.max)
        assertEquals("12:00", inputTime.value)
        assertEquals("Select time", inputTime.placeholder)
    }
}