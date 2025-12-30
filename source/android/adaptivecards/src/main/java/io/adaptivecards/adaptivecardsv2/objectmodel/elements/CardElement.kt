// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.elements.models.Fact
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.models.IconInfo
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.models.Inline
import io.adaptivecards.adaptivecardsv2.objectmodel.elements.models.MediaSource
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.AdaptiveCardSchemaKey
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.FontType
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ForegroundColor
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.HorizontalAlignment
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.IconStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ImageSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ImageStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.LabelPosition
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ProgressBarColor
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ProgressSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.TextSize
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.TextStyle
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.TextWeight
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Sealed hierarchy for card elements
@Serializable
sealed class CardElement {
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
        var underline: Boolean? = null,
        var language: String? = null
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.WRAP,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.MAX_LINES,
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Image")
    data class Image(
        val url: String,
        val altText: String? = null,
        val backgroundColor: String? = "",
        val horizontalAlignment: HorizontalAlignment? = null,
        val size: ImageSize = ImageSize.NONE,
        val style: ImageStyle = ImageStyle.DEFAULT,
        val pixelWidth: Int = 0,
        val pixelHeight: Int = 0,
        val selectAction: BaseActionElement? = null
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.ALT_TEXT,
                        AdaptiveCardSchemaKey.BACKGROUND_COLOR,
                        AdaptiveCardSchemaKey.HEIGHT,
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT,
                        AdaptiveCardSchemaKey.SELECT_ACTION,
                        AdaptiveCardSchemaKey.SIZE,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.URL,
                        AdaptiveCardSchemaKey.WIDTH
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("media")
    data class Media(
        val sources: List<MediaSource>
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.POSTER,
                        AdaptiveCardSchemaKey.ALT_TEXT,
                        AdaptiveCardSchemaKey.SOURCES
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("RichTextBlock")
    data class RichTextBlock(
        val inlines: List<Inline>,
        val horizontalAlignment: HorizontalAlignment? = null
    ) : BaseCardElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT,
                        AdaptiveCardSchemaKey.INLINES
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Icon")
    data class Icon(
        val color: ForegroundColor? = null,
        val style: IconStyle = IconStyle.REGULAR,
        val size: IconSize = IconSize.STANDARD,
        val name: String,
        val selectAction: BaseActionElement? = null
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.NAME,
                        AdaptiveCardSchemaKey.SIZE,
                        AdaptiveCardSchemaKey.COLOR,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.SELECT_ACTION
                    )
                )
            }
        }
    }

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
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.MAX,
                        AdaptiveCardSchemaKey.COUNT,
                        AdaptiveCardSchemaKey.SIZE,
                        AdaptiveCardSchemaKey.COLOR,
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("ActionSet")
    data class ActionSet(
        val actions: List<BaseActionElement>
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.ACTIONS
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("FactSet")
    data class FactSet(
        val facts: List<Fact>
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.FACTS
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("ImageSet")
    data class ImageSet(
        val images: List<Image>? = null,
        val imageSize: ImageSize? = null
    ) : BaseCardElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.IMAGES,
                        AdaptiveCardSchemaKey.IMAGE_SIZE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("TableRow")
    data class TableRow(
        val cells: List<CollectionElement.TableCell>
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.CELLS,
                        AdaptiveCardSchemaKey.HORIZONTAL_CELL_CONTENT_ALIGNMENT,
                        AdaptiveCardSchemaKey.RTL,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.VERTICAL_CELL_CONTENT_ALIGNMENT
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("CompoundButton")
    data class CompoundButton(
        val badge: String = "",
        val title: String = "",
        val description: String? = "",
        val icon: IconInfo? = null,
        val selectAction: BaseActionElement? = null
    ) : BaseCardElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.BADGE,
                        AdaptiveCardSchemaKey.DESCRIPTION,
                        AdaptiveCardSchemaKey.ICON,
                        AdaptiveCardSchemaKey.SELECT_ACTION,
                        AdaptiveCardSchemaKey.TITLE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("ProgressBar")
    data class ProgressBar(
        val value: Double = 0.0,
        val max: Double = 100.0,
        val color: ProgressBarColor = ProgressBarColor.ACCENT,
        val horizontalAlignment: HorizontalAlignment? = HorizontalAlignment.LEFT
    ) : BaseCardElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.COLOR,
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT,
                        AdaptiveCardSchemaKey.MAX,
                        AdaptiveCardSchemaKey.VALUE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("ProgressRing")
    data class ProgressRing(
        val label: String = "",
        val labelPosition: LabelPosition = LabelPosition.ABOVE,
        val horizontalAlignment: HorizontalAlignment = HorizontalAlignment.LEFT,
        val size: ProgressSize = ProgressSize.MEDIUM,
    ) : BaseCardElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT,
                        AdaptiveCardSchemaKey.LABEL,
                        AdaptiveCardSchemaKey.LABEL_POSITION,
                        AdaptiveCardSchemaKey.SIZE
                    )
                )
            }
        }
    }
}

