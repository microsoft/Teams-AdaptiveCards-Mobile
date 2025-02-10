package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.ImageSize
import com.example.ac_sdk.objectmodel.utils.ImageStyle
import org.junit.Assert.assertEquals
import org.junit.Test

class ImagePropertiesTest : BaseModelTest() {

    @Test
    fun `test Image properties`() {
        val jsonString = """
            {
                "id": "Id1",
                "type": "Image",
                "url": "https://example.com/image.png",
                "altText": "Example Image",
                "horizontalAlignment": "center",
                "size": "Medium",
                "style": "default"
            }
        """.trimIndent()

        val image = json.decodeFromString<CardElements.Image>(jsonString)

        assertEquals("Id1", image.id)
        assertEquals("https://example.com/image.png", image.url)
        assertEquals("Example Image", image.altText)
        assertEquals(HorizontalAlignment.CENTER, image.horizontalAlignment)
        assertEquals(ImageSize.MEDIUM, image.size)
        assertEquals(ImageStyle.DEFAULT, image.style)
    }
}