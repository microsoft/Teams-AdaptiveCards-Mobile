// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2

import org.json.JSONObject

data class HostConfig(
    var fontFamily: String = "",
    var supportsInteractivity: Boolean = false,
    var imageBaseUrl: String = "",
    var factSet: FactSetConfig = FactSetConfig(),
    var fontSizes: FontSizesConfig = FontSizesConfig(),
    var fontWeights: FontWeightsConfig = FontWeightsConfig(),
    var fontTypes: FontTypesDefinition = FontTypesDefinition(),
    var containerStyles: ContainerStylesDefinition = ContainerStylesDefinition(),
    var image: ImageConfig = ImageConfig(),
    var imageSet: ImageSetConfig = ImageSetConfig(),
    var imageSizes: ImageSizesConfig = ImageSizesConfig(),
    var separator: SeparatorConfig = SeparatorConfig(),
    var spacing: SpacingConfig = SpacingConfig(),
    var adaptiveCard: AdaptiveCardConfig = AdaptiveCardConfig(),
    var actions: ActionsConfig = ActionsConfig(),
    var media: MediaConfig = MediaConfig(),
    var hostWidth: HostWidthConfig = HostWidthConfig(),
    var inputs: InputsConfig = InputsConfig(),
    var textBlock: TextBlockConfig = TextBlockConfig(),
    var textStyles: TextStylesConfig = TextStylesConfig(),
    var ratingLabelConfig: RatingElementConfig = RatingElementConfig(),
    var ratingInputConfig: RatingElementConfig = RatingElementConfig(),
    var table: TableConfig = TableConfig(),
    var borderWidth: JSONObject? = null,
    var cornerRadius: JSONObject? = null,
    var compoundButtonConfig: CompoundButtonConfig = CompoundButtonConfig()
) {
    companion object {
        fun deserializeFromString(jsonString: String): HostConfig {
            val jsonObject = JSONObject(jsonString)
            return deserialize(jsonObject)
        }

        fun deserialize(json: JSONObject): HostConfig {
            val result = HostConfig()
            result.fontFamily = json.optString("fontFamily", result.fontFamily)
            result.supportsInteractivity = json.optBoolean("supportsInteractivity", result.supportsInteractivity)
            result.imageBaseUrl = json.optString("imageBaseUrl", result.imageBaseUrl)
            result.factSet = FactSetConfig.deserialize(
                json.optJSONObject("factSet") ?: JSONObject(),
                result.factSet
            )
            result.fontSizes = FontSizesConfig.deserialize(
                json.optJSONObject("fontSizes") ?: JSONObject(),
                result.fontSizes
            )
            result.fontWeights = FontWeightsConfig.deserialize(
                json.optJSONObject("fontWeights") ?: JSONObject(),
                result.fontWeights
            )
            result.fontTypes = FontTypesDefinition.deserialize(
                json.optJSONObject("fontTypes") ?: JSONObject(),
                result.fontTypes
            )
            result.containerStyles = ContainerStylesDefinition.deserialize(
                json.optJSONObject("containerStyles") ?: JSONObject(), result.containerStyles
            )
            result.image =
                ImageConfig.deserialize(json.optJSONObject("image") ?: JSONObject(), result.image)
            result.imageSet = ImageSetConfig.deserialize(
                json.optJSONObject("imageSet") ?: JSONObject(),
                result.imageSet
            )
            result.imageSizes = ImageSizesConfig.deserialize(
                json.optJSONObject("imageSizes") ?: JSONObject(),
                result.imageSizes
            )
            result.separator = SeparatorConfig.deserialize(
                json.optJSONObject("separator") ?: JSONObject(),
                result.separator
            )
            result.spacing = SpacingConfig.deserialize(
                json.optJSONObject("spacing") ?: JSONObject(),
                result.spacing
            )
            result.adaptiveCard = AdaptiveCardConfig.deserialize(
                json.optJSONObject("adaptiveCard") ?: JSONObject(),
                result.adaptiveCard
            )
            result.actions = ActionsConfig.deserialize(
                json.optJSONObject("actions") ?: JSONObject(),
                result.actions
            )
            result.media =
                MediaConfig.deserialize(json.optJSONObject("media") ?: JSONObject(), result.media)
            result.hostWidth = HostWidthConfig.deserialize(
                json.optJSONObject("hostWidth") ?: JSONObject(),
                result.hostWidth
            )
            result.inputs = InputsConfig.deserialize(
                json.optJSONObject("inputs") ?: JSONObject(),
                result.inputs
            )
            result.textBlock = TextBlockConfig.deserialize(
                json.optJSONObject("textBlock") ?: JSONObject(),
                result.textBlock
            )
            result.textStyles = TextStylesConfig.deserialize(
                json.optJSONObject("textStyles") ?: JSONObject(),
                result.textStyles
            )
            result.ratingLabelConfig = RatingElementConfig.deserialize(
                json.optJSONObject("ratingLabelConfig") ?: JSONObject(), result.ratingLabelConfig
            )
            result.ratingInputConfig = RatingElementConfig.deserialize(
                json.optJSONObject("ratingInputConfig") ?: JSONObject(), result.ratingInputConfig
            )
            result.table =
                TableConfig.deserialize(json.optJSONObject("table") ?: JSONObject(), result.table)
            result.borderWidth = json.optJSONObject("borderWidth")
            result.cornerRadius = json.optJSONObject("cornerRadius")
            result.compoundButtonConfig = CompoundButtonConfig.deserialize(
                json.optJSONObject("compoundButtonConfig") ?: JSONObject(),
                result.compoundButtonConfig
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FactSetConfig(
    var spacing: Int = 0,
    var title: FactSetTextConfig = FactSetTextConfig(),
    var value: FactSetTextConfig = FactSetTextConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FactSetConfig): FactSetConfig {
            val result = FactSetConfig()
            result.spacing = json.optInt("spacing", defaultValue.spacing)
            result.title = FactSetTextConfig.deserialize(
                json.optJSONObject("title") ?: JSONObject(),
                defaultValue.title
            )
            result.value = FactSetTextConfig.deserialize(
                json.optJSONObject("value") ?: JSONObject(),
                defaultValue.value
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FontSizesConfig(
    var small: Int = 10,
    var default: Int = 12,
    var medium: Int = 14,
    var large: Int = 17,
    var extraLarge: Int = 20
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FontSizesConfig): FontSizesConfig {
            val result = FontSizesConfig()
            result.small = json.optInt("small", defaultValue.small)
            result.default = json.optInt("default", defaultValue.default)
            result.medium = json.optInt("medium", defaultValue.medium)
            result.large = json.optInt("large", defaultValue.large)
            result.extraLarge = json.optInt("extraLarge", defaultValue.extraLarge)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FontWeightsConfig(
    var lighter: Int = 200,
    var default: Int = 400,
    var bolder: Int = 800
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FontWeightsConfig): FontWeightsConfig {
            val result = FontWeightsConfig()
            result.lighter = json.optInt("lighter", defaultValue.lighter)
            result.default = json.optInt("default", defaultValue.default)
            result.bolder = json.optInt("bolder", defaultValue.bolder)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FontTypesDefinition(
    var defaultFontType: FontTypeDefinition = FontTypeDefinition(),
    var monospaceFontType: FontTypeDefinition = FontTypeDefinition()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FontTypesDefinition): FontTypesDefinition {
            val result = FontTypesDefinition()
            result.defaultFontType = FontTypeDefinition.deserialize(
                json.optJSONObject("defaultFontType") ?: JSONObject(), defaultValue.defaultFontType
            )
            result.monospaceFontType = FontTypeDefinition.deserialize(
                json.optJSONObject("monospaceFontType") ?: JSONObject(),
                defaultValue.monospaceFontType
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FontTypeDefinition(
    var fontFamily: String = "",
    var fontSizes: FontSizesConfig = FontSizesConfig(),
    var fontWeights: FontWeightsConfig = FontWeightsConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FontTypeDefinition): FontTypeDefinition {
            val result = FontTypeDefinition()
            result.fontFamily = json.optString("fontFamily", defaultValue.fontFamily)
            result.fontSizes = FontSizesConfig.deserialize(
                json.optJSONObject("fontSizes") ?: JSONObject(),
                defaultValue.fontSizes
            )
            result.fontWeights = FontWeightsConfig.deserialize(
                json.optJSONObject("fontWeights") ?: JSONObject(),
                defaultValue.fontWeights
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ContainerStylesDefinition(
    var defaultPalette: ContainerStyleDefinition = ContainerStyleDefinition(),
    var emphasisPalette: ContainerStyleDefinition = ContainerStyleDefinition(),
    var goodPalette: ContainerStyleDefinition = ContainerStyleDefinition(),
    var attentionPalette: ContainerStyleDefinition = ContainerStyleDefinition(),
    var warningPalette: ContainerStyleDefinition = ContainerStyleDefinition(),
    var accentPalette: ContainerStyleDefinition = ContainerStyleDefinition()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ContainerStylesDefinition): ContainerStylesDefinition {
            val result = ContainerStylesDefinition()
            result.defaultPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("defaultPalette") ?: JSONObject(), defaultValue.defaultPalette
            )
            result.emphasisPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("emphasisPalette") ?: JSONObject(), defaultValue.emphasisPalette
            )
            result.goodPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("goodPalette") ?: JSONObject(), defaultValue.goodPalette
            )
            result.attentionPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("attentionPalette") ?: JSONObject(),
                defaultValue.attentionPalette
            )
            result.warningPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("warningPalette") ?: JSONObject(), defaultValue.warningPalette
            )
            result.accentPalette = ContainerStyleDefinition.deserialize(
                json.optJSONObject("accentPalette") ?: JSONObject(), defaultValue.accentPalette
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ContainerStyleDefinition(
    var backgroundColor: String = "",
    var borderColor: String = "",
    var foregroundColors: ColorsConfig = ColorsConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ContainerStyleDefinition): ContainerStyleDefinition {
            val result = ContainerStyleDefinition()
            result.backgroundColor = json.optString("backgroundColor", defaultValue.backgroundColor)
            result.borderColor = json.optString("borderColor", defaultValue.borderColor)
            result.foregroundColors = ColorsConfig.deserialize(
                json.optJSONObject("foregroundColors") ?: JSONObject(),
                defaultValue.foregroundColors
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ColorsConfig(
    var defaultColor: ColorConfig = ColorConfig(),
    var accent: ColorConfig = ColorConfig(),
    var dark: ColorConfig = ColorConfig(),
    var light: ColorConfig = ColorConfig(),
    var good: ColorConfig = ColorConfig(),
    var warning: ColorConfig = ColorConfig(),
    var attention: ColorConfig = ColorConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ColorsConfig): ColorsConfig {
            val result = ColorsConfig()
            result.defaultColor = ColorConfig.deserialize(
                json.optJSONObject("defaultColor") ?: JSONObject(),
                defaultValue.defaultColor
            )
            result.accent = ColorConfig.deserialize(
                json.optJSONObject("accent") ?: JSONObject(),
                defaultValue.accent
            )
            result.dark = ColorConfig.deserialize(
                json.optJSONObject("dark") ?: JSONObject(),
                defaultValue.dark
            )
            result.light = ColorConfig.deserialize(
                json.optJSONObject("light") ?: JSONObject(),
                defaultValue.light
            )
            result.good = ColorConfig.deserialize(
                json.optJSONObject("good") ?: JSONObject(),
                defaultValue.good
            )
            result.warning = ColorConfig.deserialize(
                json.optJSONObject("warning") ?: JSONObject(),
                defaultValue.warning
            )
            result.attention = ColorConfig.deserialize(
                json.optJSONObject("attention") ?: JSONObject(),
                defaultValue.attention
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ColorConfig(
    var defaultColor: String = "",
    var subtleColor: String = "",
    var highlightColors: HighlightColorConfig = HighlightColorConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ColorConfig): ColorConfig {
            val result = ColorConfig()
            result.defaultColor = json.optString("defaultColor", defaultValue.defaultColor)
            result.subtleColor = json.optString("subtleColor", defaultValue.subtleColor)
            result.highlightColors = HighlightColorConfig.deserialize(
                json.optJSONObject("highlightColors") ?: JSONObject(), defaultValue.highlightColors
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class HighlightColorConfig(
    var defaultColor: String = "",
    var subtleColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: HighlightColorConfig): HighlightColorConfig {
            val result = HighlightColorConfig()
            result.defaultColor = json.optString("defaultColor", defaultValue.defaultColor)
            result.subtleColor = json.optString("subtleColor", defaultValue.subtleColor)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ImageConfig(
    var imageSize: ImageSize = ImageSize.Default
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ImageConfig): ImageConfig {
            val result = ImageConfig()
            result.imageSize =
                ImageSize.fromString(json.optString("imageSize", defaultValue.imageSize.toString()))
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ImageSetConfig(
    var imageSize: ImageSize = ImageSize.Default,
    var maxImageHeight: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ImageSetConfig): ImageSetConfig {
            val result = ImageSetConfig()
            result.imageSize =
                ImageSize.fromString(json.optString("imageSize", defaultValue.imageSize.toString()))
            result.maxImageHeight = json.optInt("maxImageHeight", defaultValue.maxImageHeight)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ImageSizesConfig(
    var smallSize: Int = 0,
    var mediumSize: Int = 0,
    var largeSize: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ImageSizesConfig): ImageSizesConfig {
            val result = ImageSizesConfig()
            result.smallSize = json.optInt("smallSize", defaultValue.smallSize)
            result.mediumSize = json.optInt("mediumSize", defaultValue.mediumSize)
            result.largeSize = json.optInt("largeSize", defaultValue.largeSize)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class SeparatorConfig(
    var lineThickness: Int = 0,
    var lineColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: SeparatorConfig): SeparatorConfig {
            val result = SeparatorConfig()
            result.lineThickness = json.optInt("lineThickness", defaultValue.lineThickness)
            result.lineColor = json.optString("lineColor", defaultValue.lineColor)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class SpacingConfig(
    var smallSpacing: Int = 0,
    var defaultSpacing: Int = 0,
    var mediumSpacing: Int = 0,
    var largeSpacing: Int = 0,
    var extraLargeSpacing: Int = 0,
    var paddingSpacing: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: SpacingConfig): SpacingConfig {
            val result = SpacingConfig()
            result.smallSpacing = json.optInt("smallSpacing", defaultValue.smallSpacing)
            result.defaultSpacing = json.optInt("defaultSpacing", defaultValue.defaultSpacing)
            result.mediumSpacing = json.optInt("mediumSpacing", defaultValue.mediumSpacing)
            result.largeSpacing = json.optInt("largeSpacing", defaultValue.largeSpacing)
            result.extraLargeSpacing = json.optInt("extraLargeSpacing", defaultValue.extraLargeSpacing)
            result.paddingSpacing = json.optInt("paddingSpacing", defaultValue.paddingSpacing)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class AdaptiveCardConfig(
    var allowCustomStyle: Boolean = false
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: AdaptiveCardConfig): AdaptiveCardConfig {
            val result = AdaptiveCardConfig()
            result.allowCustomStyle = json.optBoolean("allowCustomStyle", defaultValue.allowCustomStyle)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ActionsConfig(
    var actionsOrientation: ActionsOrientation = ActionsOrientation.Horizontal,
    var actionAlignment: ActionAlignment = ActionAlignment.Left,
    var buttonSpacing: Int = 0,
    var maxActions: Int = 0,
    var showCard: ShowCardActionConfig = ShowCardActionConfig(),
    var spacing: Spacing = Spacing.Default,
    var iconPlacement: IconPlacement = IconPlacement.LeftOfTitle,
    var iconSize: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ActionsConfig): ActionsConfig {
            val result = ActionsConfig()
            result.actionsOrientation = ActionsOrientation.fromString(
                json.optString(
                    "actionsOrientation",
                    defaultValue.actionsOrientation.toString()
                )
            )
            result.actionAlignment = ActionAlignment.fromString(
                json.optString(
                    "actionAlignment",
                    defaultValue.actionAlignment.toString()
                )
            )
            result.buttonSpacing = json.optInt("buttonSpacing", defaultValue.buttonSpacing)
            result.maxActions = json.optInt("maxActions", defaultValue.maxActions)
            result.showCard = ShowCardActionConfig.deserialize(
                json.optJSONObject("showCard") ?: JSONObject(),
                defaultValue.showCard
            )
            result.spacing =
                Spacing.fromString(json.optString("spacing", defaultValue.spacing.toString()))
            result.iconPlacement = IconPlacement.fromString(
                json.optString(
                    "iconPlacement",
                    defaultValue.iconPlacement.toString()
                )
            )
            result.iconSize = json.optInt("iconSize", defaultValue.iconSize)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class ShowCardActionConfig(
    var actionMode: ActionMode = ActionMode.Inline,
    var inlineTopMargin: Int = 0,
    var style: ContainerStyle = ContainerStyle.Default
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ShowCardActionConfig): ShowCardActionConfig {
            val result = ShowCardActionConfig()
            result.actionMode = ActionMode.fromString(
                json.optString(
                    "actionMode",
                    defaultValue.actionMode.toString()
                )
            )
            result.inlineTopMargin = json.optInt("inlineTopMargin", defaultValue.inlineTopMargin)
            result.style =
                ContainerStyle.fromString(json.optString("style", defaultValue.style.toString()))
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class MediaConfig(
    var defaultPoster: String = "",
    var playButton: String = "",
    var allowInlinePlayback: Boolean = false
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: MediaConfig): MediaConfig {
            val result = MediaConfig()
            result.defaultPoster = json.optString("defaultPoster", defaultValue.defaultPoster)
            result.playButton = json.optString("playButton", defaultValue.playButton)
            result.allowInlinePlayback = json.optBoolean("allowInlinePlayback", defaultValue.allowInlinePlayback)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class HostWidthConfig(
    var veryNarrow: Int = 0,
    var narrow: Int = 0,
    var standard: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: HostWidthConfig): HostWidthConfig {
            val result = HostWidthConfig()
            result.veryNarrow = json.optInt("veryNarrow", defaultValue.veryNarrow)
            result.narrow = json.optInt("narrow", defaultValue.narrow)
            result.standard = json.optInt("standard", defaultValue.standard)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class TextBlockConfig(
    var headingLevel: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: TextBlockConfig): TextBlockConfig {
            val result = TextBlockConfig()
            result.headingLevel = json.optInt("headingLevel", defaultValue.headingLevel)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class TextStylesConfig(
    var heading: TextStyleConfig = TextStyleConfig(),
    var columnHeader: TextStyleConfig = TextStyleConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: TextStylesConfig): TextStylesConfig {
            val result = TextStylesConfig()
            result.heading = TextStyleConfig.deserialize(
                json.optJSONObject("heading") ?: JSONObject(),
                defaultValue.heading
            )
            result.columnHeader = TextStyleConfig.deserialize(
                json.optJSONObject("columnHeader") ?: JSONObject(),
                defaultValue.columnHeader
            )
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class RatingElementConfig(
    var filledStar: RatingStarConfig = RatingStarConfig(),
    var emptyStar: RatingStarConfig = RatingStarConfig(),
    var ratingTextColor: String = "",
    var countTextColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: RatingElementConfig): RatingElementConfig {
            val result = RatingElementConfig()
            result.filledStar = RatingStarConfig.deserialize(
                json.optJSONObject("filledStar") ?: JSONObject(),
                defaultValue.filledStar
            )
            result.emptyStar = RatingStarConfig.deserialize(
                json.optJSONObject("emptyStar") ?: JSONObject(),
                defaultValue.emptyStar
            )
            result.ratingTextColor = json.optString("ratingTextColor", defaultValue.ratingTextColor)
            result.countTextColor = json.optString("countTextColor", defaultValue.countTextColor)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class TableConfig(
    var cellSpacing: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: TableConfig): TableConfig {
            val result = TableConfig()
            result.cellSpacing = json.optInt("cellSpacing", defaultValue.cellSpacing)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class CompoundButtonConfig(
    var badgeConfig: BadgeConfig = BadgeConfig(),
    var borderColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: CompoundButtonConfig): CompoundButtonConfig {
            val result = CompoundButtonConfig()
            result.badgeConfig = BadgeConfig.deserialize(
                json.optJSONObject("badgeConfig") ?: JSONObject(),
                defaultValue.badgeConfig
            )
            result.borderColor = json.optString("borderColor", defaultValue.borderColor)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class BadgeConfig(
    var backgroundColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: BadgeConfig): BadgeConfig {
            val result = BadgeConfig()
            result.backgroundColor = json.optString("backgroundColor", defaultValue.backgroundColor)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class FactSetTextConfig(
    var wrap: Boolean = false,
    var maxWidth: Int = 0
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: FactSetTextConfig): FactSetTextConfig {
            val result = FactSetTextConfig()
            result.wrap = json.optBoolean("wrap", defaultValue.wrap)
            result.maxWidth = json.optInt("maxWidth", defaultValue.maxWidth)
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class TextStyleConfig(
    var color: ForegroundColor = ForegroundColor.Default,
    var fontType: FontType = FontType.Default,
    var isSubtle: Boolean = false,
    var size: TextSize = TextSize.Default,
    var weight: TextWeight = TextWeight.Default
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: TextStyleConfig): TextStyleConfig {
            val result = TextStyleConfig()
            result.color =
                ForegroundColor.fromString(json.optString("color", defaultValue.color.toString()))
            result.fontType =
                FontType.fromString(json.optString("fontType", defaultValue.fontType.toString()))
            result.isSubtle = json.optBoolean("isSubtle", defaultValue.isSubtle)
            result.size = TextSize.fromString(json.optString("size", defaultValue.size.toString()))
            result.weight =
                TextWeight.fromString(json.optString("weight", defaultValue.weight.toString()))
            return result
        }
    }
}

// Define other data classes and their deserialization methods similarly
data class RatingStarConfig(
    var marigoldColor: String = "",
    var neutralColor: String = ""
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: RatingStarConfig): RatingStarConfig {
            val result = RatingStarConfig()
            result.marigoldColor = json.optString("marigoldColor", defaultValue.marigoldColor)
            result.neutralColor = json.optString("neutralColor", defaultValue.neutralColor)
            return result
        }
    }
}

// Define enums and their conversion methods
enum class ImageSize {
    Small, Medium, Large, Default;

    companion object {
        fun fromString(value: String): ImageSize {
            return when (value) {
                "Small" -> Small
                "Medium" -> Medium
                "Large" -> Large
                else -> Default
            }
        }
    }
}

enum class ActionsOrientation {
    Horizontal, Vertical;

    companion object {
        fun fromString(value: String): ActionsOrientation {
            return when (value) {
                "Horizontal" -> Horizontal
                "Vertical" -> Vertical
                else -> Horizontal
            }
        }
    }
}

enum class ActionAlignment {
    Left, Center, Right, Stretch;

    companion object {
        fun fromString(value: String): ActionAlignment {
            return when (value) {
                "Left" -> Left
                "Center" -> Center
                "Right" -> Right
                "Stretch" -> Stretch
                else -> Left
            }
        }
    }
}

enum class Spacing {
    Default, None, Small, Medium, Large, ExtraLarge, Padding;

    companion object {
        fun fromString(value: String): Spacing {
            return when (value) {
                "None" -> None
                "Small" -> Small
                "Medium" -> Medium
                "Large" -> Large
                "ExtraLarge" -> ExtraLarge
                "Padding" -> Padding
                else -> Default
            }
        }
    }
}

enum class IconPlacement {
    LeftOfTitle, AboveTitle;

    companion object {
        fun fromString(value: String): IconPlacement {
            return when (value) {
                "LeftOfTitle" -> LeftOfTitle
                "AboveTitle" -> AboveTitle
                else -> LeftOfTitle
            }
        }
    }
}

enum class ActionMode {
    Inline, Popup;

    companion object {
        fun fromString(value: String): ActionMode {
            return when (value) {
                "Inline" -> Inline
                "Popup" -> Popup
                else -> Inline
            }
        }
    }
}

enum class ContainerStyle {
    None, Default, Emphasis, Good, Attention, Warning, Accent;

    companion object {
        fun fromString(value: String): ContainerStyle {
            return when (value) {
                "Emphasis" -> Emphasis
                "Good" -> Good
                "Attention" -> Attention
                "Warning" -> Warning
                "Accent" -> Accent
                else -> Default
            }
        }
    }
}

enum class ForegroundColor {
    Default, Dark, Light, Accent, Good, Warning, Attention;

    companion object {
        fun fromString(value: String): ForegroundColor {
            return when (value) {
                "Dark" -> Dark
                "Light" -> Light
                "Accent" -> Accent
                "Good" -> Good
                "Warning" -> Warning
                "Attention" -> Attention
                else -> Default
            }
        }
    }
}

enum class FontType {
    Default, Monospace;

    companion object {
        fun fromString(value: String): FontType {
            return when (value) {
                "Monospace" -> Monospace
                else -> Default
            }
        }
    }
}

enum class TextSize {
    Default, Small, Medium, Large, ExtraLarge;

    companion object {
        fun fromString(value: String): TextSize {
            return when (value) {
                "Small" -> Small
                "Medium" -> Medium
                "Large" -> Large
                "ExtraLarge" -> ExtraLarge
                else -> Default
            }
        }
    }
}

enum class TextWeight {
    Default, Lighter, Bolder;

    companion object {
        fun fromString(value: String): TextWeight {
            return when (value) {
                "Lighter" -> Lighter
                "Bolder" -> Bolder
                else -> Default
            }
        }
    }
}

data class InputsConfig(
    var errorMessage: ErrorMessageConfig = ErrorMessageConfig(),
    var label: LabelConfig = LabelConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: InputsConfig): InputsConfig {
            val result = InputsConfig()
            result.errorMessage = ErrorMessageConfig.deserialize(
                json.optJSONObject("errorMessage") ?: JSONObject(),
                defaultValue.errorMessage
            )
            result.label = LabelConfig.deserialize(
                json.optJSONObject("label") ?: JSONObject(),
                defaultValue.label
            )
            return result
        }
    }
}

data class ErrorMessageConfig(
    var size: TextSize = TextSize.Default,
    var spacing: Spacing = Spacing.Default,
    var weight: TextWeight = TextWeight.Default
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: ErrorMessageConfig): ErrorMessageConfig {
            val result = ErrorMessageConfig()
            result.size = TextSize.fromString(json.optString("size", defaultValue.size.toString()))
            result.spacing =
                Spacing.fromString(json.optString("spacing", defaultValue.spacing.toString()))
            result.weight =
                TextWeight.fromString(json.optString("weight", defaultValue.weight.toString()))
            return result
        }
    }
}

data class LabelConfig(
    var inputSpacing: Spacing = Spacing.Default,
    var requiredInputs: InputLabelConfig = InputLabelConfig(),
    var optionalInputs: InputLabelConfig = InputLabelConfig()
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: LabelConfig): LabelConfig {
            val result = LabelConfig()
            result.inputSpacing = Spacing.fromString(
                json.optString(
                    "inputSpacing",
                    defaultValue.inputSpacing.toString()
                )
            )
            result.requiredInputs = InputLabelConfig.deserialize(
                json.optJSONObject("requiredInputs") ?: JSONObject(),
                defaultValue.requiredInputs
            )
            result.optionalInputs = InputLabelConfig.deserialize(
                json.optJSONObject("optionalInputs") ?: JSONObject(),
                defaultValue.optionalInputs
            )
            return result
        }
    }
}

data class InputLabelConfig(
    var color: ForegroundColor = ForegroundColor.Default,
    var isSubtle: Boolean = false,
    var size: TextSize = TextSize.Default,
    var suffix: String = "",
    var weight: TextWeight = TextWeight.Default
) {
    companion object {
        fun deserialize(json: JSONObject, defaultValue: InputLabelConfig): InputLabelConfig {
            val result = InputLabelConfig()
            result.color =
                ForegroundColor.fromString(json.optString("color", defaultValue.color.toString()))
            result.isSubtle = json.optBoolean("isSubtle", defaultValue.isSubtle)
            result.size = TextSize.fromString(json.optString("size", defaultValue.size.toString()))
            result.suffix = json.optString("suffix", defaultValue.suffix)
            result.weight =
                TextWeight.fromString(json.optString("weight", defaultValue.weight.toString()))
            return result
        }
    }
}