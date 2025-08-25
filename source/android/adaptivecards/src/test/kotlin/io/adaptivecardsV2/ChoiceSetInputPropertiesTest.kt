package io.adaptivecardsV2

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.InputElement
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ChoiceSetStyle
import org.junit.Assert.assertEquals
import org.junit.Test

class ChoiceSetInputPropertiesTest : BaseModelTest() {
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

        val choiceSetInput = json.decodeFromString<InputElement.ChoiceSetInput>(jsonString)

        assertEquals(true, choiceSetInput.isMultiSelect)
        assertEquals(ChoiceSetStyle.EXPANDED, choiceSetInput.style)
        assertEquals("choice1", choiceSetInput.value)
        assertEquals(2, choiceSetInput.choices.size)
        assertEquals("Choice 1", choiceSetInput.choices[0].title)
        assertEquals("choice1", choiceSetInput.choices[0].value)
        assertEquals("Choice 2", choiceSetInput.choices[1].title)
        assertEquals("choice2", choiceSetInput.choices[1].value)
    }

}