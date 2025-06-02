package com.example.ac_sdk.objectmodel.elements.models

import kotlinx.serialization.Serializable

@Serializable
data class MediaSource(val mimeType: String, var url: String)