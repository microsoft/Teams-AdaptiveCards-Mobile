package io.adaptivecardsV2

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.CardElement
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ForegroundColor
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconStyle
import org.junit.Assert.assertEquals
import org.junit.Test

class IconPropertiesTest : BaseModelTest() {

    @Test
    fun `test Icon properties`() {
        val jsonString = """
            {
                "type": "icon",
                "color": "Default",
                "style": "Regular",
                "size": "Medium",
                "name": "exampleIcon",
                "selectAction": null
            }
        """.trimIndent()

        val icon = json.decodeFromString<CardElement.Icon>(jsonString)

        assertEquals(ForegroundColor.DEFAULT, icon.color)
        assertEquals(IconStyle.REGULAR, icon.style)
        assertEquals(IconSize.MEDIUM, icon.size)
        assertEquals("exampleIcon", icon.name)
        assertEquals(null, icon.selectAction)
    }
}