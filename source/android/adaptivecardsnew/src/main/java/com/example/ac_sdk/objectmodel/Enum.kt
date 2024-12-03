package com.example.ac_sdk.objectmodel

enum class HeightType(val key: String) {
    Auto("Auto"),
    Stretch("Stretch")
}

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

enum class Spacing(val key: String) {
    Default("default"),
    None("none"),
    Small("small"),
    Medium("medium"),
    Large("large"),
    ExtraLarge("extraLarge"),
    Padding("padding")
}

enum class SeparatorThickness(val key: String) {
    Default("default"),
    Thick("thick")
}

enum class ImageStyle(val key: String) {
    Default("default"),
    Person("person"),
    RoundedCorners("roundedCorners")
}

enum class IconSize(val key: String) {
    xxSmall("xxSmall"),
    xSmall("xSmall"),
    Small("Small"),
    Standard("Standard"),
    Medium("Medium"),
    Large("Large"),
    xLarge("xLarge"),
    xxLarge("xxLarge")
}

enum class IconStyle(val key: String) {
    Regular("Regular"),
    Filled("Filled")
}

enum class VerticalAlignment(val key: String) {
    Top("top"),
    Center("center"),
    Bottom("bottom")
}

enum class ImageFillMode(val key: String) {
    Cover("cover"),
    RepeatHorizontally("repeatHorizontally"),
    RepeatVertically("repeatVertically"),
    Repeat("repeat")
}

enum class ItemFit(val key: String) {
    Fit("Fit"),
    Fill("Fill")
}

enum class LayoutContainerType(val key: String) {
    None("Layout.None"),
    Stack("Layout.Stack"),
    Flow("Layout.Flow"),
    AreaGrid("Layout.AreaGrid")
}

enum class ImageSize(val key: String) {
    Auto("Auto"),
    Large("Large"),
    Medium("Medium"),
    Small("Small"),
    Stretch("Stretch")
}

enum class HorizontalAlignment(val key: String) {
    Center("center"),
    Left("left"),
    Right("right")
}

enum class ForegroundColor(val key: String) {
    Accent("Accent"),
    Attention("Attention"),
    Dark("Dark"),
    Default("Default"),
    Good("Good"),
    Light("Light"),
    Warning("Warning")
}

enum class TextStyle(val key: String) {
    Default("default"),
    Heading("heading")
}

enum class TextWeight(val key: String) {
    Bolder("Bolder"),
    Lighter("Lighter"),
    Default("Default")
}

enum class TextSize(val key: String) {
    ExtraLarge("ExtraLarge"),
    Large("Large"),
    Medium("Medium"),
    Default("Default"),
    Small("Small")
}

enum class FontType(val key: String) {
    Default("Default"),
    Monospace("Monospace")
}

enum class ActionsOrientation(val key: String) {
    Horizontal("Horizontal"),
    Vertical("Vertical")
}

enum class ActionMode(val key: String) {
    Inline("Inline"),
    Popup("Popup")
}

enum class ActionRole(val key: String) {
    Button("Button"),
    Link("Link"),
    Tab("Tab"),
    Menu("Menu"),
    MenuItem("MenuItem")
}

enum class AssociatedInputs(val key: String) {
    Auto("Auto"),
    None("None")
}

enum class ChoiceSetStyle(val key: String) {
    Compact("Compact"),
    Expanded("Expanded"),
    Filtered("Filtered")
}

enum class TextInputStyle(val key: String) {
    Email("Email"),
    Tel("Tel"),
    Text("Text"),
    Url("Url"),
    Password("Password")
}

enum class ContainerStyle(val key: String) {
    None("None"),
    Default("Default"),
    Emphasis("Emphasis"),
    Good("Good"),
    Attention("Attention"),
    Warning("Warning"),
    Accent("Accent")
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

enum class VerticalContentAlignment(val key: String) {
    Top("Top"),
    Center("Center"),
    Bottom("Bottom")
}

enum class InlineElementType(val key: String) {
    TextRun("TextRun")
}

enum class FallbackType {
    None,
    Drop,
    Content
};

enum class Mode(val key: String) {
    Primary("primary"),
    Secondary("secondary")
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

enum class ValueChangedActionType(val key: String) {
    ResetInputs("Action.ResetInputs")
}