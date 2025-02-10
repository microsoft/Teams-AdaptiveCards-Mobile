package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
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

        val icon = json.decodeFromString<CardElements.Icon>(jsonString)

        assertEquals(ForegroundColor.DEFAULT, icon.foregroundColor)
        assertEquals(IconStyle.REGULAR, icon.iconStyle)
        assertEquals(IconSize.MEDIUM, icon.iconSize)
        assertEquals("exampleIcon", icon.name)
        assertEquals(null, icon.selectAction)
    }
}