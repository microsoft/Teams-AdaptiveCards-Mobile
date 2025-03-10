package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElement
import com.example.ac_sdk.objectmodel.elements.CollectionElement
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ColumnElementPropertiesTest : BaseModelTest() {

    @Test
    fun `test Column properties`() {
        val jsonString = """
            {
                "items": [
                    {
                        "type": "TextBlock",
                        "text": "Sample Text"
                    }
                ],
                "width": "auto"
            }
        """.trimIndent()

        val column = json.decodeFromString<CollectionElement.Column>(jsonString)

        assertEquals(1, column.items?.size)
        assertTrue(column.items?.get(0) is CardElement.TextBlock)
        assertEquals("auto", column.width)
    }

    @Test
    fun `test ColumnSet properties`() {
        val jsonString = """
            {
                "columns": [
                    {
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Sample Text"
                            }
                        ],
                        "width": "auto"
                    }
                ]
            }
        """.trimIndent()

        val columnSet = json.decodeFromString<CollectionElement.ColumnSet>(jsonString)

        assertEquals(1, columnSet.columns?.size)
        assertEquals(1, columnSet.columns?.get(0)?.items?.size)
        assertTrue(columnSet.columns?.get(0)?.items?.get(0) is CardElement.TextBlock)
        assertEquals("auto", columnSet.columns?.get(0)?.width)
    }
}