package io.adaptivecardsV2

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.CardElement
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HorizontalAlignment
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ImageSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ImageStyle
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

        val image = json.decodeFromString<CardElement.Image>(jsonString)

        assertEquals("Id1", image.id)
        assertEquals("https://example.com/image.png", image.url)
        assertEquals("Example Image", image.altText)
        assertEquals(HorizontalAlignment.CENTER, image.horizontalAlignment)
        assertEquals(ImageSize.MEDIUM, image.size)
        assertEquals(ImageStyle.DEFAULT, image.style)
    }
}