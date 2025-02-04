package io.adaptivecards.parser.utils

import kotlinx.serialization.Serializable

@Serializable
data class RemoteResourceInformation(val url: String = "", val mimeType: String = "")
