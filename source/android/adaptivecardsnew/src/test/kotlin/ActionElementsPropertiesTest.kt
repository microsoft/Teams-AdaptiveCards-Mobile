package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.TargetElement
import kotlinx.serialization.json.JsonPrimitive
import org.junit.Assert.assertEquals
import org.junit.Test

class ActionElementsPropertiesTest : BaseModelTest() {

    @Test
    fun `test ActionSubmit properties`() {
        val jsonString = """
            {
                "type": "Action.Submit",
                "data": {
                    "key1": "value1"
                }
            }
        """.trimIndent()

        val actionSubmit = json.decodeFromString<ActionElements.ActionSubmit>(jsonString)

        val expectedData = mapOf(
            "key1" to JsonPrimitive("value1"),
        )

        assertEquals(expectedData, actionSubmit.data)
    }


    @Test
    fun `test ActionOpenUrl properties`() {
        val jsonString = """
            {
                "type": "Action.OpenUrl",
                "url": "https://example.com"
            }
        """.trimIndent()

        val actionOpenUrl = json.decodeFromString<ActionElements.ActionOpenUrl>(jsonString)

        assertEquals("https://example.com", actionOpenUrl.url)
    }

    @Test
    fun `test ActionShowCard properties`() {
        val jsonString = """
            {
                "type": "Action.ShowCard",
                "card": {
                    "type": "AdaptiveCard",
                    "version": "1.0",
                    "body": []
                }
            }
        """.trimIndent()

        val actionShowCard = json.decodeFromString<ActionElements.ActionShowCard>(jsonString)

        val expectedCard = AdaptiveCard(
            type = "AdaptiveCard",
            version = "1.0",
            body = arrayListOf()
        )

        assertEquals(expectedCard, actionShowCard.card)
    }

    @Test
    fun `test ActionExecute properties`() {
        val jsonString = """
            {
                "type": "Action.Execute",
                "verb": "exampleVerb"
            }
        """.trimIndent()

        val actionExecute = json.decodeFromString<ActionElements.ActionExecute>(jsonString)

        assertEquals("exampleVerb", actionExecute.verb)
    }

    @Test
    fun `test ActionToggleVisibility properties`() {
        val jsonString = """
            {
                "type": "Action.ToggleVisibility",
                "targetElements": [
                    {
                        "elementId": "element1",
                        "isVisible": true
                    }
                ]
            }
        """.trimIndent()

        val actionToggleVisibility =
            json.decodeFromString<ActionElements.ActionToggleVisibility>(jsonString)

        val expectedTargetElements = listOf(
            TargetElement(
                elementId = "element1",
                isVisible = true
            )
        )

        assertEquals(expectedTargetElements, actionToggleVisibility.targetElements)
    }
}