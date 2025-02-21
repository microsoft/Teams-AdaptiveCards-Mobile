package com.example.ac_sdk.objectmodel.elements.models

import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.TextSize
import com.example.ac_sdk.objectmodel.utils.TextWeight
import kotlinx.serialization.Serializable

@Serializable
data class TextRun(
    val type: String,
    val text: String,
    val weight: TextWeight? = null,
    val highlight: Boolean? = null,
    val italic: Boolean? = null,
    val underline: Boolean? = null,
    val color: ForegroundColor? = null,
    val size: TextSize? = null,
    val fontType: String? = null
)
