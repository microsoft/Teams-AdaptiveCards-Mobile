package com.example.ac_sdk.objectmodel.utils

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class RatingSize(val key: String) {
    Medium("medium"),
    Large("large")
}

enum class RatingColor(val key: String) {
    Neutral("neutral"),
    Marigold("marigold")
}

enum class RatingStyle(val key: String) {
    Default("default"),
    Compact("compact")
}

enum class SeparatorThickness(val key: String) {
    Default("default"),
    Thick("thick")
}

enum class ItemFit(val key: String) {
    Fit("Fit"),
    Fill("Fill")
}

enum class ActionsOrientation(val key: String) {
    Horizontal("Horizontal"),
    Vertical("Vertical")
}

enum class ActionMode(val key: String) {
    Inline("Inline"),
    Popup("Popup")
}

enum class AssociatedInputs() {
    @SerialName("auto")
    AUTO,
    @SerialName("none") NONE
}

enum class ChoiceSetStyle {
    @SerialName("compact")
    COMPACT,

    @SerialName("expanded")
    EXPANDED,

    @SerialName("filtered")
    FILTERED
}

enum class TextInputStyle {
    @SerialName("email")
    MAIL,

    @SerialName("tel")
    TEL,

    @SerialName("text")
    TEXT,

    @SerialName("url")
    URL,

    @SerialName("password")
    PASSWORD
}

@Serializable
enum class ContainerStyle {
    @SerialName("None")
    NONE,
    @SerialName("Default")
    DEFAULT,
    @SerialName("Emphasis")
    EMPHASIS,
    @SerialName("Good")
    GOOD,
    @SerialName("Attention")
    ATTENTION,
    @SerialName("Warning")
    WARNING,
    @SerialName("Accent")
    ACCENT
}

enum class ActionAlignment(val key: String) {
    Left("Left"),
    Center("Center"),
    Right("Right"),
    Stretch("Stretch")
}

enum class IconPlacement(val key: String) {
    AboveTitle("AboveTitle"),
    LeftOfTitle("LeftOfTitle")
}

enum class InlineElementType(val key: String) {
    TextRun("TextRun")
}

@Serializable
enum class FallbackType {
    @SerialName("none")
    NONE,
    @SerialName("drop")
    DROP,
    @SerialName("content")
    CONTENT
}

enum class Mode {
    @SerialName("primary")
    PRIMARY,
    @SerialName("secondary")
    SECONDARY
}

enum class ErrorStatusCode(val key: String) {
    InvalidJson("InvalidJson"),
    RenderFailed("RenderFailed"),
    RequiredPropertyMissing("RequiredPropertyMissing"),
    InvalidPropertyValue("InvalidPropertyValue"),
    UnsupportedParserOverride("UnsupportedParserOverride"),
    IdCollision("IdCollision"),
    CustomError("CustomError")
}


@Serializable
enum class ValueChangedActionType {
    @SerialName("Action.ResetInputs")
    RESET_INPUTS
}

enum class ContainerBleedDirection(val key: String) {
    BleedRestricted("restricted"),
    BleedLeft("left"),
    BleedRight("right"),
    BleedLeftRight("leftRight"),
    BleedUp("up"),
    BleedLeftUp("leftUp"),
    BleedRightUp("rightUp"),
    BleedLeftRightUp("leftRightUp"),
    BleedDown("down"),
    BleedLeftDown("leftDown"),
    BleedRightDown("rightDown"),
    BleedLeftRightDown("leftRightDown"),
    BleedUpDown("upDown"),
    BleedLeftUpDown("leftUpDown"),
    BleedRightUpDown("rightUpDown"),
    BleedAll("all")
}


@Serializable
enum class ActionType {
    @SerialName("Action.Submit")
    SUBMIT,
    @SerialName("Action.OpenUrl")
    OPENURL,
    @SerialName("Action.ShowCard")
    SHOWCARD,
    @SerialName("Action.Execute")
    EXECUTE,
    @SerialName("Action.ToggleVisibility")
    TOGGLEVISIBILITY
}

@Serializable
enum class ActionRole {
    @SerialName("Button")
    BUTTON,
    @SerialName("Link")
    LINK,
    @SerialName("Tab")
    TAB,
    @SerialName("Menu")
    MENU,
    @SerialName("MenuItem")
    MENUITEM,
}

@Serializable
enum class CardElementType {
    @SerialName("TextBlock")
    TEXTBLOCK,
    @SerialName("Image")
    IMAGE,
    @SerialName("Media")
    MEDIA,
    @SerialName("RichTextBlock")
    RICHTEXTBLOCK,
    @SerialName("TextRun")
    TEXTRUN,
    @SerialName("Icon")
    ICON,
    @SerialName("RatingLabel")
    RATINGLABEL,
    @SerialName("Container")
    CONTAINER,
    @SerialName("ColumnSet")
    COLUMNSET,
    @SerialName("Column")
    COLUMN,
    @SerialName("FactSet")
    FACTSET,
    @SerialName("ImageSet")
    IMAGESET,
    @SerialName("ActionSet")
    ACTIONSET,
    @SerialName("Input.Text")
    INPUTTEXT,
    @SerialName("Input.Number")
    INPUTNUMBER,
    @SerialName("Input.Date")
    INPUTDATE,
    @SerialName("Input.Time")
    INPUTTIME,
    @SerialName("Input.Toggle")
    INPUTTOGGLE,
    @SerialName("Input.ChoiceSet")
    INPUTCHOICESET
}

@Serializable
enum class TargetWidthType {
    @SerialName("Default")
    DEFAULT,
    @SerialName("wide")
    WIDE,
    @SerialName("standard")
    STANDARD,
    @SerialName("narrow")
    NARROW,
    @SerialName("veryNarrow")
    VERY_NARROW,
    @SerialName("atLeast:wide")
    AT_LEAST_WIDE,
    @SerialName("atLeast:standard")
    AT_LEAST_STANDARD,
    @SerialName("atLeast:narrow")
    AT_LEAST_NARROW,
    @SerialName("atLeast:veryNarrow")
    AT_LEAST_VERY_NARROW,
    @SerialName("atMost:wide")
    AT_MOST_WIDE,
    @SerialName("atMost:standard")
    AT_MOST_STANDARD,
    @SerialName("atMost:narrow")
    AT_MOST_NARROW,
    @SerialName("atMost:veryNarrow")
    AT_MOST_VERY_NARROW
}

@Serializable
enum class Spacing {
    @SerialName("default")
    DEFAULT,
    @SerialName("none")
    NONE,
    @SerialName("small")
    SMALL,
    @SerialName("medium")
    MEDIUM,
    @SerialName("large")
    LARGE,
    @SerialName("extraLarge")
    EXTRA_LARGE,
    @SerialName("padding")
    PADDING
}

@Serializable
enum class HeightType {
    @SerialName("Auto")
    AUTO,
    @SerialName("Stretch")
    STRETCH
}

@Serializable
enum class HostWidth {
    @SerialName("default")
    DEFAULT,
    @SerialName("wide")
    WIDE,
    @SerialName("standard")
    STANDARD,
    @SerialName("narrow")
    NARROW,
    @SerialName("veryNarrow")
    VERY_NARROW
}

@Serializable
enum class VerticalAlignment {
    @SerialName("top")
    TOP,
    @SerialName("center")
    CENTER,
    @SerialName("bottom")
    BOTTOM
}

@Serializable
enum class ForegroundColor {
    @SerialName("Default")
    DEFAULT,
    @SerialName("Dark")
    DARK,
    @SerialName("Light")
    LIGHT,
    @SerialName("Accent")
    ACCENT,
    @SerialName("Good")
    GOOD,
    @SerialName("Warning")
    WARNING,
    @SerialName("Attention")
    ATTENTION
}

@Serializable
enum class TextSize {
    @SerialName("Small")
    SMALL,
    @SerialName("Default")
    DEFAULT,
    @SerialName("Medium")
    MEDIUM,
    @SerialName("Large")
    LARGE,
    @SerialName("ExtraLarge")
    EXTRA_LARGE
}

@Serializable
enum class TextWeight {
    @SerialName("Default")
    DEFAULT,
    @SerialName("Lighter")
    LIGHTER,
    @SerialName("Bolder")
    BOLDER
}

@Serializable
enum class TextStyle {
    @SerialName("default")
    DEFAULT,
    @SerialName("heading")
    HEADING,
    @SerialName("title")
    TITLE,
    @SerialName("subtitle")
    SUBTITLE
}

@Serializable
enum class FontType {
    @SerialName("Default")
    DEFAULT,
    @SerialName("Monospace")
    MONOSPACE
}

@Serializable
enum class ImageFillMode {
    @SerialName("cover")
    COVER,
    @SerialName("repeatHorizontally")
    REPEAT_HORIZ,
    @SerialName("repeatVertically")
    REPEAT_VERT,
    @SerialName("repeat")
    REPEAT
}

@Serializable
enum class HorizontalAlignment {
    @SerialName("left")
    LEFT,

    @SerialName("center")
    CENTER,

    @SerialName("right")
    RIGHT
}

@Serializable
enum class ImageSize {
    @SerialName("Auto")
    AUTO,
    @SerialName("Stretch")
    STRETCH,
    @SerialName("Small")
    SMALL,
    @SerialName("Medium")
    MEDIUM,
    @SerialName("Large")
    LARGE
}

@Serializable
enum class ImageStyle {
    @SerialName("default")
    DEFAULT,
    @SerialName("person")
    PERSON,
    @SerialName("roundedCorners")
    ROUNDCORNERS
}

@Serializable
enum class IconSize {
    @SerialName("xxSmall")
    XXSMALL,
    @SerialName("xSmall")
    XSMALL,
    @SerialName("Small")
    SMALL,
    @SerialName("Standard")
    STANDARD,
    @SerialName("Medium")
    MEDIUM,
    @SerialName("Large")
    LARGE,
    @SerialName("xLarge")
    XLARGE,
    @SerialName("xxLarge")
    XXLARGE
}

@Serializable
enum class IconStyle {
    @SerialName("Regular")
    REGULAR,
    @SerialName("Filled")
    FILLED
}

@Serializable
enum class LayoutContainerType {
    @SerialName("None")
    NONE,
    @SerialName("Stack")
    STACK,
    @SerialName("Flow")
    FLOW,
    @SerialName("AreaGrid")
    AREAGRID
}