package io.adaptivecards.parser.utils

enum class AdaptiveCardSchemaKey(val key: String) {
    ACCENT("accent"),
    ACTION("action"),
    ACTION_ALIGNMENT("actionAlignment"),
    ACTION_MODE("actionMode"),
    ACTION_ROLE("role"),
    ACTION_SET("ActionSet"),
    ACTION_SET_CONFIG("actionSetConfig"),
    ACTIONS("actions"),
    ACTIONS_ORIENTATION("actionsOrientation"),
    ADAPTIVE_CARD("adaptiveCard"),
    ALLOW_CUSTOM_STYLE("allowCustomStyle"),
    ALLOW_INLINE_PLAYBACK("allowInlinePlayback"),
    ALT_TEXT("altText"),
    NAME("name"),
    ASSOCIATED_INPUTS("associatedInputs"),
    ATTENTION("attention"),
    AUTHENTICATION("authentication"),
    BACKGROUND_COLOR("backgroundColor"),
    BACKGROUND_IMAGE("backgroundImage"),
    BACKGROUND_IMAGE_URL("backgroundImageUrl"),
    BASE_CARD_ELEMENT("baseCardElement"),
    BASE_CONTAINER_STYLE("baseContainerStyle"),
    BADGE("badge"),
    BLEED("bleed"),
    BODY("body"),
    BOLDER("bolder"),
    BORDER_COLOR("borderColor"),
    BOTTOM("bottom"),
    BUTTON_SPACING("buttonSpacing"),
    BUTTONS("buttons"),
    CAPTION_SOURCES("captionSources"),
    CARD("card"),
    CELL_SPACING("cellSpacing"),
    CELLS("cells"),
    CENTER("center"),
    CHOICE_SET("choiceSet"),
    CHOICES("choices"),
    CHOICES_DATA("choices.data"),
    CHOICES_DATA_TYPE("choicesDataTyp"),
    COLOR("color"),
    COLOR_CONFIG("colorConfig"),
    COLUMN("column"),
    COLUMN_HEADER("columnHeader"),
    COLUMN_SET("columnSet"),
    COLUMNS("columns"),
    CONDITIONALLY_ENABLED("conditionallyEnabled"),
    CONNECTION_NAME("connectionName"),
    CONTAINER("container"),
    CONTAINER_STYLES("containerStyles"),
    BORDER_WIDTH("borderWidth"),
    CORNER_RADIUS("cornerRadius"),
    DARK("dark"),
    DATA("data"),
    DATA_QUERY("Data.Query"),
    DATASET("dataset"),
    DATE_INPUT("dateInput"),
    DEFAULT("default"),
    DEFAULT_POSTER("defaultPoster"),
    COUNT("count"),
    DESCRIPTION("description"),
    ELEMENT_ID("elementId"),
    EMPHASIS("emphasis"),
    ERROR_MESSAGE("errorMessage"),
    EXTRA_LARGE("extraLarge"),
    FACT_SET("factSet"),
    FACTS("facts"),
    FALLBACK("fallback"),
    FALLBACK_TEXT("fallbackText"),
    FILL_MODE("fillMode"),
    FIRST_ROW_AS_HEADERS("firstRowAsHeaders"),
    FONT_FAMILY("fontFamily"),
    FONT_SIZES("fontSizes"),
    FONT_TYPE("fontType"),
    FONT_TYPES("fontTypes"),
    FONT_WEIGHTS("fontWeights"),
    FOREGROUND_COLOR("foregroundColor"),
    FOREGROUND_COLORS("foregroundColors"),
    GOOD("good"),
    GRID_STYLE("gridStyle"),
    HEADING("heading"),
    HEADING_LEVEL("headingLevel"),
    HEIGHT("height"),
    HIGHLIGHT("highlight"),
    HIGHLIGHT_COLOR("highlightColor"),
    HIGHLIGHT_COLORS("highlightColors"),
    HORIZONTAL_ALIGNMENT("horizontalAlignment"),
    HORIZONTAL_CELL_CONTENT_ALIGNMENT("horizontalCellContentAlignment"),
    HOST_WIDTH_BREAKPOINTS("hostWidthBreakpoints"),
    ICON_PLACEMENT("iconPlacement"),
    ICON_SIZE("iconSize"),
    ICON_URL("iconUrl"),
    ID("id"),
    IMAGE("image"),
    ICON("icon"),
    IMAGE_BASE_URL("imageBaseUrl"),
    IMAGE_SET("imageSet"),
    IMAGE_SIZE("imageSize"),
    IMAGE_SIZES("imageSizes"),
    IMAGES("images"),
    INLINE_ACTION("inlineAction"),
    INLINE_TOP_MARGIN("inlineTopMargin"),
    INLINES("inlines"),
    INPUT_SPACING("inputSpacing"),
    INPUTS("inputs"),
    IS_ENABLED("isEnabled"),
    IS_MULTI_SELECT("isMultiSelect"),
    IS_MULTILINE("isMultiline"),
    SHOW_BORDER("showBorder"),
    ROUNDED_CORNERS("roundedCorners"),
    IS_REQUIRED("isRequired"),
    IS_SELECTED("isSelected"),
    IS_SUBTLE("isSubtle"),
    IS_VISIBLE("isVisible"),
    ITALIC("italic"),
    ITEMS("items"),
    LABEL("label"),
    LANGUAGE("lang"),
    LARGE("large"),
    LEFT("left"),
    LIGHT("light"),
    LIGHTER("lighter"),
    LINE_COLOR("lineColor"),
    LINE_THICKNESS("lineThickness"),
    MAX("max"),
    MAX_ACTIONS("maxActions"),
    MAX_IMAGE_HEIGHT("maxImageHeight"),
    MAX_LENGTH("maxLength"),
    MAX_LINES("maxLines"),
    MAX_WIDTH("maxWidth"),
    MEDIA("media"),
    MEDIUM("medium"),
    META_DATA("metaData"),
    METHOD("method"),
    MIME_TYPE("mimeType"),
    MIN("min"),
    MIN_HEIGHT("minHeight"),
    MODE("mode"),
    MONOSPACE("monospace"),
    NARROW("narrow"),
    NUMBER_INPUT("numberInput"),
    RATING_INPUT("ratingInput"),
    RATING_LABEL("ratingLabel"),
    OPTIONAL_INPUTS("optionalInputs"),
    PADDING("padding"),
    PLACEHOLDER("placeholder"),
    PLAY_BUTTON("playButton"),
    POSTER("poster"),
    PROVIDER_ID("providerId"),
    REFRESH("refresh"),
    REGEX("regex"),
    REPEAT("repeat"),
    REPEAT_HORIZONTALLY("repeatHorizontally"),
    REPEAT_VERTICALLY("repeatVertically"),
    REQUIRED_INPUTS("requiredInputs"),
    REQUIRES("requires"),
    RICH_TEXT_BLOCK("richTextBlock"),
    RIGHT("right"),
    ROWS("rows"),
    RTL("rtl"),
    SCHEMA("schema"),
    SELECT_ACTION("selectAction"),
    SEPARATOR("separator"),
    SHOW_ACTION_MODE("showActionMode"),
    SHOW_CARD("showCard"),
    SHOW_CARD_ACTION_CONFIG("showCardActionConfig"),
    SHOW_GRID_LINES("showGridLines"),
    SIZE("size"),
    SMALL("small"),
    SOURCES("sources"),
    SPACING("spacing"),
    SPACING_DEFINITION("spacingDefinition"),
    SPEAK("speak"),
    STANDARD("standard"),
    STRETCH("stretch"),
    STRIKETHROUGH("strikethrough"),
    STYLE("style"),
    SUBTLE("subtle"),
    SUFFIX("suffix"),
    SUPPORTS_INTERACTIVITY("supportsInteractivity"),
    TABLE("table"),
    TABLE_CELL("tableCell"),
    TABLE_ROW("tableRow"),
    TARGET_ELEMENTS("targetElements"),
    TARGET_INPUT_IDS("targetInputIds"),
    TARGET_WIDTH("targetWidth"),
    TEXT("text"),
    TEXT_BLOCK("textBlock"),
    TEXT_CONFIG("textConfig"),
    TEXT_INPUT("textInput"),
    TEXT_STYLES("textStyles"),
    MARIGOLD_COLOR("marigoldColor"),
    NEUTRAL_COLOR("neutralColor"),
    FILLED_STAR("filledStar"),
    EMPTY_STAR("emptyStar"),
    RATING_TEXT_COLOR("ratingTextColor"),
    COUNT_TEXT_COLOR("countTextColor"),
    TEXT_WEIGHT("textWeight"),
    THICKNESS("thickness"),
    TIME_INPUT("timeInput"),
    TITLE("title"),
    TOGGLE_INPUT("toggleInput"),
    LAYOUT("Layout"),
    ITEM_FIT("itemFit"),
    ROW_SPACING("rowSpacing"),
    COLUMN_SPACING("columnSpacing"),
    ITEM_WIDTH("itemWidth"),
    MIN_ITEM_WIDTH("minItemWidth"),
    MAX_ITEM_WIDTH("maxItemWidth"),
    HORIZONTAL_ITEMS_ALIGNMENT("horizontalItemsAlignment"),
    ROW("row"),
    ROW_SPAN("rowSpan"),
    COLUMN_SPAN("columnSpan"),
    AREA_GRID_NAME("grid.area"),
    AREAS("areas"),
    LAYOUTS("layouts"),
    TOKEN_EXCHANGE_RESOURCE("tokenExchangeResource"),
    TOOLTIP("tooltip"),
    TOP("top"),
    TYPE("type"),
    UNDERLINE("underline"),
    URI("uri"),
    URL("url"),
    USER_IDS("userIds"),
    VALUE("value"),
    VALUE_CHANGED_ACTION("valueChangedAction"),
    VALUE_CHANGED_ACTION_TYPE("valueChangedActionType"),
    VALUE_OFF("valueOff"),
    VALUE_ON("valueOn"),
    VERB("verb"),
    VERY_NARROW("veryNarrow"),
    VERSION("version"),
    VERTICAL_ALIGNMENT("verticalAlignment"),
    VERTICAL_CELL_CONTENT_ALIGNMENT("verticalCellContentAlignment"),
    VERTICAL_CONTENT_ALIGNMENT("verticalContentAlignment"),
    WARNING("warning"),
    WEB_URL("webUrl"),
    WEIGHT("weight"),
    WIDTH("width"),
    COMPOUND_BUTTON("compoundButton"),
    WRAP("wrap")
}

enum class CardElementType(val value: String) {
    ACTION_SET("ActionSet"),
    ADAPTIVE_CARD("AdaptiveCard"),
    CHOICE_SET_INPUT("Input.ChoiceSet"),
    COLUMN("Column"),
    COLUMN_SET("ColumnSet"),
    CONTAINER("Container"),
    CUSTOM("Custom"),
    DATE_INPUT("Input.Date"),
    FACT("Fact"),
    FACT_SET("FactSet"),
    IMAGE("Image"),
    ICON("Icon"),
    IMAGE_SET("ImageSet"),
    MEDIA("Media"),
    NUMBER_INPUT("Input.Number"),
    RATING_INPUT("Input.Rating"),
    RATING_LABEL("Rating"),
    RICH_TEXT_BLOCK("RichTextBlock"),
    TABLE("Table"),
    TABLE_CELL("TableCell"),
    TABLE_ROW("TableRow"),
    TEXT_BLOCK("TextBlock"),
    TEXT_INPUT("Input.Text"),
    TIME_INPUT("Input.Time"),
    TOGGLE_INPUT("Input.Toggle"),
    COMPOUND_BUTTON("CompoundButton"),
    UNKNOWN("Unknown")
}

enum class ActionType(val value: String) {
    UNSUPPORTED("Unsupported"),
    EXECUTE("Action.Execute"),
    OPEN_URL("Action.OpenUrl"),
    SHOW_CARD("Action.ShowCard"),
    SUBMIT("Action.Submit"),
    TOGGLE_VISIBILITY("Action.ToggleVisibility"),
    CUSTOM("Custom"),
    UNKNOWN_ACTION("UnknownAction"),
    OVERFLOW("Overflow")
}

enum class HeightType(val value: String) {
    AUTO("Auto"),
    STRETCH("Stretch")
}

enum class RatingSize(val value: String) {
    MEDIUM("medium"),
    LARGE("large")
}

enum class RatingColor(val value: String) {
    NEUTRAL("neutral"),
    MARIGOLD("marigold")
}

enum class RatingStyle(val value: String) {
    DEFAULT("default"),
    COMPACT("compact")
}

enum class Spacing(val value: String) {
    DEFAULT("default"),
    NONE("none"),
    SMALL("small"),
    MEDIUM("medium"),
    LARGE("large"),
    EXTRA_LARGE("extraLarge"),
    PADDING("padding")
}

enum class SeparatorThickness(val value: String) {
    DEFAULT("default"),
    THICK("thick")
}

enum class ImageStyle(val value: String) {
    DEFAULT("default"),
    PERSON("person"),
    ROUNDED_CORNERS("roundedCorners")
}

enum class IconSize(val value: String) {
    XX_SMALL("xxSmall"),
    X_SMALL("xSmall"),
    SMALL("Small"),
    STANDARD("Standard"),
    MEDIUM("Medium"),
    LARGE("Large"),
    X_LARGE("xLarge"),
    XX_LARGE("xxLarge")
}

enum class IconStyle(val value: String) {
    REGULAR("Regular"),
    FILLED("Filled")
}

enum class VerticalAlignment(val value: String) {
    TOP("top"),
    CENTER("center"),
    BOTTOM("bottom")
}

enum class ImageFillMode(val value: String) {
    COVER("cover"),
    REPEAT_HORIZONTALLY("repeatHorizontally"),
    REPEAT_VERTICALLY("repeatVertically"),
    REPEAT("repeat")
}

enum class ItemFit(val value: String) {
    FIT("Fit"),
    FILL("Fill")
}

enum class LayoutContainerType(val value: String) {
    NONE("Layout.None"),
    STACK("Layout.Stack"),
    FLOW("Layout.Flow"),
    AREA_GRID("Layout.AreaGrid")
}

enum class ImageSize(val value: String) {
    AUTO("auto"),
    LARGE("Large"),
    MEDIUM("Medium"),
    SMALL("Small"),
    STRETCH("Stretch")
}

enum class HorizontalAlignment(val value: String) {
    CENTER("center"),
    LEFT("left"),
    RIGHT("right")
}

enum class ForegroundColor(val value: String) {
    ACCENT("Accent"),
    ATTENTION("Attention"),
    DARK("Dark"),
    DEFAULT("default"),
    GOOD("Good"),
    LIGHT("Light"),
    WARNING("Warning")
}

enum class TextStyle(val value: String) {
    DEFAULT("default"),
    HEADING("Heading")
}

enum class TextWeight(val value: String) {
    BOLDER("bolder"),
    LIGHTER("Lighter"),
    DEFAULT("default")
}

enum class TextSize(val value: String) {
    EXTRA_LARGE("ExtraLarge"),
    LARGE("large"),
    MEDIUM("Medium"),
    DEFAULT("default"),
    SMALL("Small")
}

enum class FontType(val value: String) {
    DEFAULT("Default"),
    MONOSPACE("Monospace"),
    DISPLAY("display")
}

enum class ActionsOrientation(val value: String) {
    HORIZONTAL("Horizontal"),
    VERTICAL("Vertical")
}

enum class ActionMode(val value: String) {
    INLINE("Inline"),
    POPUP("Popup")
}

enum class ActionRole(val value: String) {
    BUTTON("Button"),
    LINK("Link"),
    TAB("Tab"),
    MENU("Menu"),
    MENU_ITEM("MenuItem")
}

enum class AssociatedInputs(val value: String) {
    AUTO("Auto"),
    NONE("None")
}

enum class ChoiceSetStyle(val value: String) {
    COMPACT("Compact"),
    EXPANDED("Expanded"),
    FILTERED("Filtered")
}

enum class TextInputStyle(val value: String) {
    EMAIL("Email"),
    TEL("Tel"),
    TEXT("Text"),
    URL("Url"),
    PASSWORD("Password")
}

enum class ContainerStyle(val value: String) {
    DEFAULT("default"),
    EMPHASIS("emphasis"),
    GOOD("Good"),
    ATTENTION("Attention"),
    WARNING("Warning"),
    ACCENT("Accent"),
    NONE("none"),
    TEXT("text")
}

enum class ActionAlignment(val value: String) {
    LEFT("Left"),
    CENTER("Center"),
    RIGHT("Right"),
    STRETCH("Stretch")
}

enum class IconPlacement(val value: String) {
    ABOVE_TITLE("AboveTitle"),
    LEFT_OF_TITLE("LeftOfTitle")
}

enum class VerticalContentAlignment(val value: String) {
    TOP("Top"),
    CENTER("Center"),
    BOTTOM("Bottom")
}

enum class InlineElementType(val value: String) {
    TEXT_RUN("TextRun")
}

enum class Mode(val value: String) {
    PRIMARY("primary"),
    SECONDARY("secondary")
}

enum class ErrorStatusCode(val value: String) {
    INVALID_JSON("InvalidJson"),
    RENDER_FAILED("RenderFailed"),
    REQUIRED_PROPERTY_MISSING("RequiredPropertyMissing"),
    INVALID_PROPERTY_VALUE("InvalidPropertyValue"),
    UNSUPPORTED_PARSER_OVERRIDE("UnsupportedParserOverride"),
    ID_COLLISION("IdCollision"),
    CUSTOM_ERROR("CustomError")
}

enum class TargetWidthType(val value: String) {
    DEFAULT("Default"),
    VERY_NARROW("veryNarrow"),
    NARROW("narrow"),
    STANDARD("standard"),
    WIDE("wide"),
    AT_MOST_VERY_NARROW("atMost:veryNarrow"),
    AT_MOST_NARROW("atMost:narrow"),
    AT_MOST_STANDARD("atMost:standard"),
    AT_MOST_WIDE("atMost:wide"),
    AT_LEAST_VERY_NARROW("atLeast:veryNarrow"),
    AT_LEAST_NARROW("atLeast:narrow"),
    AT_LEAST_STANDARD("atLeast:standard"),
    AT_LEAST_WIDE("atLeast:wide")
}

enum class ValueChangedActionType(val value: String) {
    RESET_INPUTS("Action.ResetInputs")
}
