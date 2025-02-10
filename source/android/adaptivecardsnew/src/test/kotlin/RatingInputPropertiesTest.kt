package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import org.junit.Assert.assertEquals
import org.junit.Test

class RatingInputPropertiesTest : BaseModelTest() {
    @Test
    fun `test RatingInput properties`() {
        val jsonString = """
            {
                "type": "Input.Rating",
                "horizontalAlignment": "center",
                "value": 4.5,
                "max": 5.0
            }
        """.trimIndent()

        val ratingInput = json.decodeFromString<InputElements.RatingInput>(jsonString)

        assertEquals(HorizontalAlignment.CENTER, ratingInput.horizontalAlignment)
        assertEquals(4.5, ratingInput.value, 0.0)
        assertEquals(5.0, ratingInput.max, 0.0)
    }
}