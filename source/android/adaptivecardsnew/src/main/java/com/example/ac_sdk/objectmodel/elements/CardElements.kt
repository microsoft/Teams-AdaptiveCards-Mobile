package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.FontType
import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.IconSize
import com.example.ac_sdk.objectmodel.utils.IconStyle
import com.example.ac_sdk.objectmodel.utils.ImageSize
import com.example.ac_sdk.objectmodel.utils.ImageStyle
import com.example.ac_sdk.objectmodel.utils.TextSize
import com.example.ac_sdk.objectmodel.utils.TextStyle
import com.example.ac_sdk.objectmodel.utils.TextWeight
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Sealed hierarchy for card elements
@Serializable
sealed class CardElements {
    // AC elements
    @Serializable
    @SerialName("TextBlock")
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
        //test
    ) : BaseCardElement()

    @Serializable
    @SerialName("Image")
    data class Image(
        val url: String,
        val altText: String? = null,
        val horizontalAlignment: HorizontalAlignment? = null,
        val size: ImageSize? = null,
        val style: ImageStyle? = null
    ) : BaseCardElement()

    @Serializable
    @SerialName("media")
    data class Media(val sources: List<MediaSource>) : BaseCardElement()

    @Serializable
    @SerialName("richTextBlock")
    data class RichTextBlock(val inlines: List<TextRun>) : BaseCardElement()

    @Serializable
    @SerialName("icon")
    data class Icon(
        val foregroundColor: ForegroundColor,
        val iconStyle: IconStyle,
        val iconSize: IconSize,
        val name: String,
        val selectAction: BaseActionElement?
    ) : BaseCardElement()

    @Serializable
    @SerialName("ratingLabel")
    data class RatingLabel(
        val max: Int?,
        val count: Int?,
        val color: String?,
        val label: String?,
        val value: Double?,
        val errorMessage: String?,
        val hAlignment: HorizontalAlignment?
    ) : BaseCardElement()


    @Serializable
    @SerialName("actionSet")
    data class ActionSet(
        val actions: List<BaseActionElement>
    ) : BaseCardElement()

    @Serializable
    data class FactSet(
        val facts: List<Fact>
    ) : BaseCardElement()

    @Serializable
    data class ImageSet(
        val images: List<CardElements.Image>? = null,
        val imageSize: String? = null
    ) : BaseCardElement()

    @Serializable
    data class TableRow(
        val cells: List<CollectionElement.TableCell>
    ): BaseCardElement()
}

@Serializable
data class MediaSource (val mimeType: String, var url: String)

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

@Serializable
data class Fact(
    val title: String,
    val value: String
)


