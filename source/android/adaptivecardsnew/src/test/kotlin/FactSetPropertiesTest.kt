package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
import org.junit.Assert.assertEquals
import org.junit.Test

class FactSetPropertiesTest : BaseModelTest() {

    @Test
    fun `test FactSet properties`() {
        val jsonString = """
            {
                "type": "FactSet",
                "facts": [
                    {
                        "title": "Fact 1",
                        "value": "Value 1"
                    }
                ]
            }
            """.trimIndent()
        val factSet = json.decodeFromString<CardElements.FactSet>(jsonString)

        assertEquals("Fact 1", factSet.facts[0].title)
        assertEquals("Value 1", factSet.facts[0].value)

    }
}


