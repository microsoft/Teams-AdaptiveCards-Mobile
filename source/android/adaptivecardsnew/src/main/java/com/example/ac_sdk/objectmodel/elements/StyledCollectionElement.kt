package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.BackgroundImage
import com.example.ac_sdk.objectmodel.utils.ContainerStyle
import com.example.ac_sdk.objectmodel.utils.InternalId
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
sealed class StyledCollectionElement : CollectionCoreElement() {
    var style: ContainerStyle? = null
    var verticalContentAlignment: VerticalAlignment? = null
    var hasPadding: Boolean? = null
    var showBorder: Boolean? = null
    var roundedCorners: Boolean? = null
    var hasBleed: Boolean? = null
    var parentalId: InternalId? = null
    var backgroundImage: BackgroundImage? = null
    var selectAction: BaseActionElement? = null
    var minHeight: UInt? = null
}