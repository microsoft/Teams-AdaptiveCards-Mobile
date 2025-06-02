package com.example.ac_sdk.objectmodel.elements.models

import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.IconSize
import com.example.ac_sdk.objectmodel.utils.IconStyle
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
@SerialName("icon")
data class IconInfo(
    val iconStyle: IconStyle = IconStyle.REGULAR,
    var iconSize: IconSize = IconSize.STANDARD,
    var foregroundColor: ForegroundColor = ForegroundColor.DEFAULT,
    var name: String = ""
)
