package io.adaptivecards.adaptivecardsv2.objectmodel.elements.models

import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ForegroundColor
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconStyle
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
@SerialName("icon")
data class IconInfo(
    val style: IconStyle = IconStyle.REGULAR,
    var size: IconSize = IconSize.STANDARD,
    var color: ForegroundColor = ForegroundColor.DEFAULT,
    var name: String = ""
)
