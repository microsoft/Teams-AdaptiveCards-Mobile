package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.CardElements
import kotlinx.serialization.json.Json
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

        val media = json.decodeFromString<CardElements.Media>(jsonString)

        assertEquals(1, media.sources.size)
        assertEquals("video/mp4", media.sources[0].mimeType)
        assertEquals("https://example.com/video.mp4", media.sources[0].url)
    }
}