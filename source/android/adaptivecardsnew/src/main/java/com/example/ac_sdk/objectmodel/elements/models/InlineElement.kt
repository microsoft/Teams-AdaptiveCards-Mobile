package com.example.ac_sdk.objectmodel.elements.models

import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.InlineSerializer
import com.example.ac_sdk.objectmodel.utils.TextSize
import com.example.ac_sdk.objectmodel.utils.TextWeight
import kotlinx.serialization.Serializable

@Serializable(with = InlineSerializer::class)
sealed interface Inline

@Serializable
data class PlainTextInline(
    var text: String
) : Inline


@Serializable
data class TextRun(
    val type: String?,
    val text: String,
    val weight: TextWeight? = null,
    val highlight: Boolean? = null,
    val language: String? = null,
    val italic: Boolean? = null,
    val underline: Boolean? = null,
    val strikethrough: Boolean? = null,
    val color: ForegroundColor? = null,
    val size: TextSize? = null,
    val fontType: String? = null,
    val isSubtle: Boolean? = null,
    val selectAction: BaseActionElement? = null,
) : Inline
