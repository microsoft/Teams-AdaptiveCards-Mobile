package io.adaptivecards.parser.elements

import io.adaptivecards.objectmodel.FontType
import io.adaptivecards.objectmodel.TextStyle
import io.adaptivecards.parser.utils.ForegroundColor
import io.adaptivecards.parser.utils.HorizontalAlignment
import io.adaptivecards.parser.utils.IconSize
import io.adaptivecards.parser.utils.IconStyle
import io.adaptivecards.parser.utils.ImageSize
import io.adaptivecards.parser.utils.ImageStyle
import io.adaptivecards.parser.utils.TextSize
import io.adaptivecards.parser.utils.TextWeight
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Sealed hierarchy for card elements
@Serializable
@Polymorphic
sealed class CardElement {
    // AC elements
    @Serializable
    data class TextBlock(
        var text: String,
        var color: ForegroundColor? = null,
        var horizontalAlignment: HorizontalAlignment? = null,
        var isSubtle: Boolean? = null,
        var italic: Boolean? = null,
        var maxLines: Int? = null,
        var size: TextSize? = null,
        var weight: TextWeight? = null,
        var wrap: Boolean? = null,
        var strikethrough: Boolean? = null,
        var style: TextStyle? = null,
        var fontType: FontType? = null,
        var highlight: Boolean? = null,
        var underline: Boolean? = null
    ) : BaseCardElement()

    @Serializable
    data class Image(
        var url: String,
        var altText: String?,
        var horizontalAlignment: HorizontalAlignment?,
        var size: ImageSize?,
        var style: ImageStyle?
    ) : BaseCardElement()

    @Serializable
    @SerialName("media")
    data class Media(var sources: List<MediaSource>) : BaseCardElement()

    @Serializable
    @SerialName("richTextBlock")
    data class RichTextBlock(val inlines: List<TextRun>) : BaseCardElement()

    @Serializable
    @SerialName("icon")
    data class Icon(
        var foregroundColor: ForegroundColor,
        var iconStyle: IconStyle,
        var iconSize: IconSize,
        var name: String,
        var selectAction: BaseActionElement?
    ) : BaseCardElement()

    @Serializable
    @SerialName("ratingLabel")
    data class RatingLabel(
        var max: Int?,
        var count: Int?,
        var color: String?,
        var label: String?,
        var value: Double?,
        var errorMessage: String?,
        var hAlignment: HorizontalAlignment?
    ) : BaseCardElement()


    @Serializable
    @SerialName("actionSet")
    data class ActionSet(
        var actions: List<ActionElement>
    ) : BaseCardElement()

//
//    // Containers
//    @Serializable
//    @SerialName("container")
//    data class ContainerElement(val container: Container) : CardElement()
//
//    @Serializable
//    @SerialName("columnSet")
//    data class ColumnSetElement(val columnSet: ColumnSet) : CardElement()
//
//    @Serializable
//    @SerialName("column")
//    data class ColumnElement(val column: Column) : CardElement()
//
//    @Serializable
//    @SerialName("factSet")
//    data class FactSetElement(val factSet: FactSet) : CardElement()
//
//    @Serializable
//    @SerialName("imageSet")
//    data class ImageSetElement(val imageSet: ImageSet) : CardElement()
//
//    @Serializable
//    @SerialName("actionSet")
//    data class ActionSetElement(val actionSet: ActionSet) : CardElement()
//
//    // Inputs
//    @Serializable
//    @SerialName("inputElement")
//    data class InputElementElement(val inputElement: InputElement) : CardElement()

}

@Serializable
data class MediaSource (var mimeType: String, var url: String)

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

