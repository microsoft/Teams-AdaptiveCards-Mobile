// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.BackgroundImage
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ContainerStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.InternalId
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.VerticalAlignment
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