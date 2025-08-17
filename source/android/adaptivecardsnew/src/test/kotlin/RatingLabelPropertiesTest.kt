package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElement
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import org.junit.Assert.assertEquals
import org.junit.Test

class RatingLabelPropertiesTest : BaseModelTest() {

    @Test
    fun `test RatingLabel properties`() {
        val jsonString = """
            {
                "type": "ratingLabel",
                "max": 5,
                "count": 3,
                "color": "red",
                "label": "Rating",
                "value": 4.5,
                "errorMessage": "Error",
                "hAlignment": "center"
            }
        """.trimIndent()

        val ratingLabel = json.decodeFromString<CardElement.RatingLabel>(jsonString)

        assertEquals(5, ratingLabel.max)
        assertEquals(3, ratingLabel.count)
        assertEquals("red", ratingLabel.color)
        assertEquals("Rating", ratingLabel.label)
        assertEquals(4.5, ratingLabel.value)
        assertEquals("Error", ratingLabel.errorMessage)
        assertEquals(HorizontalAlignment.CENTER, ratingLabel.hAlignment)
    }
}