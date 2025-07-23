package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.ActionElement
import com.example.ac_sdk.objectmodel.elements.CardElement
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

        val actionSet = json.decodeFromString<CardElement.ActionSet>(jsonString)
        assertEquals(1, actionSet.actions.size)
        assertEquals(
            "https://example.com",
            (actionSet.actions[0] as ActionElement.ActionOpenUrl).url
        )
    }
}