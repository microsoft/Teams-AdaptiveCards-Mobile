package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElement
import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.IconSize
import com.example.ac_sdk.objectmodel.utils.IconStyle
import org.junit.Assert.assertEquals
import org.junit.Test

class IconPropertiesTest : BaseModelTest() {

    @Test
    fun `test Icon properties`() {
        val jsonString = """
            {
                "type": "icon",
                "foregroundColor": "Default",
                "iconStyle": "Regular",
                "iconSize": "Medium",
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