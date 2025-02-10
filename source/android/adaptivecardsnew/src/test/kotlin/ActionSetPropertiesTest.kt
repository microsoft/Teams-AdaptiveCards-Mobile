package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.CardElements
import org.junit.Assert.assertEquals
import org.junit.Test

class ActionSetPropertiesTest : BaseModelTest() {

    @Test
    fun `test ActionSet properties`() {
        val jsonString = """
            {
                "type": "actionSet",
                "actions": [
                    {
                        "type": "Action.OpenUrl",
                        "url": "https://example.com"
                    }
                ]
            }
        """.trimIndent()

        val actionSet = json.decodeFromString<CardElements.ActionSet>(jsonString)
        assertEquals(1, actionSet.actions.size)
        assertEquals(
            "https://example.com",
            (actionSet.actions[0] as ActionElements.ActionOpenUrl).url
        )
    }
}