package io.adaptivecardsV2

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.CardElement
import org.junit.Assert.assertEquals
import org.junit.Test

class MediaPropertiesTest : BaseModelTest() {

    @Test
    fun `test Media properties`() {
        val jsonString = """
            {
                "type": "media",
                "sources": [
                    {
                        "mimeType": "video/mp4",
                        "url": "https://example.com/video.mp4"
                    }
                ]
            }
        """.trimIndent()

        val media = json.decodeFromString<CardElement.Media>(jsonString)

        assertEquals(1, media.sources.size)
        assertEquals("video/mp4", media.sources[0].mimeType)
        assertEquals("https://example.com/video.mp4", media.sources[0].url)
    }
}