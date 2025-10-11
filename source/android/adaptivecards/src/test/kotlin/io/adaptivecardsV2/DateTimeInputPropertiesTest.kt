package io.adaptivecardsV2

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.InputElement
import org.junit.Assert.assertEquals
import org.junit.Test

class DateTimeInputPropertiesTest : BaseModelTest() {

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

        val dateInput = json.decodeFromString<InputElement.DateInput>(jsonString)

        assertEquals("2023-01-01", dateInput.min)
        assertEquals("2023-12-31", dateInput.max)
        assertEquals("2023-06-15", dateInput.value)
        assertEquals("Select date", dateInput.placeholder)
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

        val timeInput = json.decodeFromString<InputElement.TimeInput>(jsonString)

        assertEquals("08:00", timeInput.min)
        assertEquals("18:00", timeInput.max)
        assertEquals("12:00", timeInput.value)
        assertEquals("Select time", timeInput.placeholder)
    }
}