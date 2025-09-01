package io.adaptivecards.adaptivecardsv2.objectmodel.elements.models

import kotlinx.serialization.Serializable

@Serializable
data class MediaSource(val mimeType: String, var url: String)