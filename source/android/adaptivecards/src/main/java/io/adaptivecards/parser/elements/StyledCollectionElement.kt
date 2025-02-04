package io.adaptivecards.parser.elements

import io.adaptivecards.parser.BackgroundImage
import io.adaptivecards.parser.utils.ContainerStyle
import io.adaptivecards.parser.utils.VerticalContentAlignment
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.Serializable

@Serializable
@Polymorphic
sealed class StyledCollectionElement : CollectionCoreElement() {
    var style: ContainerStyle? = null
    var verticalContentAlignment: VerticalContentAlignment? = null
    var hasPadding: Boolean? = null
    var showBorder: Boolean? = null
    var roundedCorners: Boolean? = null
    var hasBleed: Boolean? = null
    var parentalId: InternalId? = null
    var backgroundImage: BackgroundImage? = null
    var selectAction: BaseActionElement? = null
    var minHeight: UInt? = null
}