package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.InputElements
import org.junit.Assert.assertEquals
import org.junit.Test

class InputChoiceSetPropertiesTest : BaseModelTest() {
    @Test
    fun `test InputChoiceSet properties`() {
        val jsonString = """
            {
                "type": "Input.ChoiceSet",
                "isMultiSelect": true,
                "style": "expanded",
                "value": "choice1",
                "choices": [
                    {
                        "title": "Choice 1",
                        "value": "choice1"
                    },
                    {
                        "title": "Choice 2",
                        "value": "choice2"
                    }
                ]
            }
        """.trimIndent()

        val inputChoiceSet = json.decodeFromString<InputElements.InputChoiceSet>(jsonString)

        assertEquals(true, inputChoiceSet.isMultiSelect)
        assertEquals("expanded", inputChoiceSet.style)
        assertEquals("choice1", inputChoiceSet.value)
        assertEquals(2, inputChoiceSet.choices.size)
        assertEquals("Choice 1", inputChoiceSet.choices[0].title)
        assertEquals("choice1", inputChoiceSet.choices[0].value)
        assertEquals("Choice 2", inputChoiceSet.choices[1].title)
        assertEquals("choice2", inputChoiceSet.choices[1].value)
    }

}