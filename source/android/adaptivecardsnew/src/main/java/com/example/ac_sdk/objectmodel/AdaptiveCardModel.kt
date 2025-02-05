package com.example.ac_sdk.objectmodel

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlinx.serialization.json.JsonElement

@Serializable
data class AdaptiveCard(
    @SerialName("\$schema") val schema: String? = null,
    val type: String? = null,
    val version: String? = null,
    val unknown: String? = null,
    val refresh: Refresh? = null,
    var language: String = "",
    var fallbackText: String = "",
    var speak: String = "",
    val minHeight: Int? = null,
    val height: HeightType? = null,
    val verticalAlignment: VerticalAlignment? = null,
    val backgroundImage: BackgroundImage? = null,
    val body: ArrayList<BaseCardElement> = arrayListOf(),
    val actions: ArrayList<ActionElement> = arrayListOf(),
    val authentication: Authentication? = null,
    val rtl: Boolean? = null
)

@Serializable
data class BackgroundImageObj(
    val url: String? = null,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@Serializable(with = BackgroundImageSerializer::class)
data class BackgroundImage(
    val url: String,
    val fillMode: ImageFillMode? = null,
    val horizontalAlignment: HorizontalAlignment? = null,
    val verticalAlignment: VerticalAlignment? = null
)

@Serializable
data class Authentication(
    val connectionName: String,
    val text: String,
    val tokenExchangeResource: TokenExchangeResource,
    val buttons: List<AuthCardButton>
)

@Serializable
data class Refresh(
    val action: ActionExecute,
    val userIds: List<String>
)

@Serializable
data class TokenExchangeResource(
    val id: String,
    val providerId: String,
    val uri: String
)

@Serializable
data class AuthCardButton(
    val type: String,
    val title: String
)

@Serializable
sealed class ActionElement {
    @Serializable
    @SerialName("Action.Submit")
    data class Submit(val data: ActionSubmit) : ActionElement()

    @Serializable
    @SerialName("Action.OpenUrl")
    data class OpenUrl(val data: ActionOpenUrl) : ActionElement()

    @Serializable
    @SerialName("Action.ShowCard")
    data class ShowCard(val data: ActionShowCard) : ActionElement()

    @Serializable
    @SerialName("Action.Execute")
    data class Execute(val data: ActionExecute) : ActionElement()

    @Serializable
    @SerialName("Action.ToggleVisibility")
    data class ToggleVisibility(val data: ActionToggleVisibility) : ActionElement()
}

@Serializable
open class BaseActionElement(
    val title: String? = null,
    val iconUrl: String? = null,
    val style: String? = null,
    val tooltip: String? = null,
    val isEnabled: Boolean? = null,
    val type: ActionType? = null,
    val mode: Mode? = null,
    val role: ActionRole? = null
)

@Serializable
data class ActionSubmit(
    val data: Map<String, JsonElement>? = null
) : BaseActionElement()

@Serializable
data class ActionOpenUrl(
    val url: String
) : BaseActionElement()

@Serializable
data class ActionShowCard(
    val card: AdaptiveCard
) : BaseActionElement()

@Serializable
data class ActionExecute(
    val verb: String
) : BaseActionElement()

@Serializable
data class ActionToggleVisibility(
    val targetElements: List<TargetElement>
) : BaseActionElement()

@Serializable
data class TargetElement(
    val elementId: String,
    val isVisible: Boolean? = null
)

//@Serializable
//sealed class CardElement {
//    @Serializable
//    @SerialName("TextBlock")
//    data class TextBlockElement(val data: TextBlock) : CardElement()
//
//    @Serializable
//    @SerialName("Image")
//    data class ImageElement(val data: Image) : CardElement()
//
//    @Serializable
//    @SerialName("Media")
//    data class MediaElement(val data: Media) : CardElement()
//
//    @Serializable
//    @SerialName("RichTextBlock")
//    data class RichTextBlockElement(val data: RichTextBlock) : CardElement()
//
//    @Serializable
//    @SerialName("TextRun")
//    data class TextRunElement(val data: TextRun) : CardElement()
//
//    @Serializable
//    @SerialName("Icon")
//    data class IconElement(val data: Icon) : CardElement()
//
//    @Serializable
//    @SerialName("RatingLabel")
//    data class RatingLabelElement(val data: RatingLabel) : CardElement()
//
//    @Serializable
//    @SerialName("Container")
//    data class ContainerElement(val data: Container) : CardElement()
//
//    @Serializable
//    @SerialName("ColumnSet")
//    data class ColumnSetElement(val data: ColumnSet) : CardElement()
//
//    @Serializable
//    @SerialName("Column")
//    data class ColumnElement(val data: Column) : CardElement()
//
//    @Serializable
//    @SerialName("FactSet")
//    data class FactSetElement(val data: FactSet) : CardElement()
//
//    @Serializable
//    @SerialName("ImageSet")
//    data class ImageSetElement(val data: ImageSet) : CardElement()
//
//    @Serializable
//    @SerialName("ActionSet")
//    data class ActionSetElement(val data: ActionSet) : CardElement()
//
//    @Serializable
//    @SerialName("InputElement")
//    data class InputElementData(val data: InputElement) : CardElement()
//}

@Serializable
sealed class BaseCardElement {
    //val type: CardElementType? = null,
    val spacing: Spacing? = null
    val separator: Boolean? = null
    val height: HeightType? = null
    val targetWidth: TargetWidthType? = null
    val isVisible: Boolean? = null
    val areaGridName: String? = null
    val nonOptionalAreaGridName: String? = null

    @Serializable
    @SerialName("TextBlock")
    data class TextBlock(
        val text: String,
        val color: ForegroundColor? = null,
        val horizontalAlignment: HorizontalAlignment? = null,
        val isSubtle: Boolean? = null,
        val italic: Boolean? = null,
        val maxLines: Int? = null,
        val size: TextSize? = null,
        val weight: TextWeight? = null,
        val wrap: Boolean? = null,
        val language: String? = null,
        val strikethrough: Boolean? = null,
        val style: TextStyle? = null,
        val fontType: FontType? = null,
        val highlight: Boolean? = null,
        val underline: Boolean? = null
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
    @SerialName("Media")
    data class Media(
        val sources: List<MediaSource>
    ) : BaseCardElement()

    @Serializable
    @SerialName("RichTextBlock")
    data class RichTextBlock(
        val inlines: List<TextRun>
    ) : BaseCardElement()


    @Serializable
    @SerialName("ActionSet")
    data class ActionSet(
        val actions: List<ActionElement>
    ) : BaseCardElement()

    @Serializable
    @SerialName("Icon")
    data class Icon(
        val foregroundColor: ForegroundColor,
        val iconStyle: IconStyle,
        val iconSize: IconSize,
        val name: String,
        val selectAction: BaseActionElement? = null
    ) : BaseCardElement()

    @Serializable
    @SerialName("RatingLabel")
    data class RatingLabel(
        val max: Int,
        val count: Int? = null,
        val hAlignment: HorizontalAlignment? = null
    ) : BaseCardElement()

    @Serializable
    @SerialName("FactSet")
    data class FactSet(
        val facts: List<Fact>
    ) : BaseCardElement()

    @Serializable
    @SerialName("Fact")
    data class Fact(
        val title: String,
        val value: String
    ) : BaseCardElement()

    @Serializable
    @SerialName("ImageSet")
    data class ImageSet(
        val images: List<Image>? = null,
        val imageSize: String? = null
    ) : BaseCardElement()

    @Serializable
    open class BaseInputElement(
        val isRequired: Boolean? = null,
        val errorMessage: String? = null,
        val label: String? = null,
        val valueChangedAction: ValueChangedAction? = null
    ) : BaseCardElement()

//    @Serializable
//    open class CollectionCoreElement(
//        val elements: List<BaseCardElement>? = null
//    ) : BaseCardElement()

    @Serializable
    open class StyledCollectionElement(
        val style: ContainerStyle? = null,
        val verticalAlignment: VerticalAlignment? = null,
        val hasPadding: Boolean? = null,
        val showBorder: Boolean? = null,
        val roundedCorners: Boolean? = null,
        val hasBleed: Boolean? = null,
        val parentalId: InternalId? = null,
        val backgroundImage: BackgroundImage? = null,
        val selectAction: BaseActionElement? = null,
        val minHeight: UInt? = null) : BaseCardElement()

    @Serializable
    @SerialName("Container")
    data class Container(
        val items: List<BaseCardElement>,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null
    ) : StyledCollectionElement()

    @Serializable
    @SerialName("ColumnSet")
    data class ColumnSet(
        val columns: List<Column>,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null
    ) : StyledCollectionElement()

    @Serializable
    @SerialName("Column")
    data class Column(
        val items: List<BaseCardElement>,
        val width: String? = null,
        val bleed: Boolean? = null,
        val rtl: Boolean? = null
    ) : StyledCollectionElement()

    @Serializable
    @SerialName("Table")
    data class Table(
        val columns: List<TableColumnDefinition>,
        val rows: List<TableRow>,
        val firstRowAsHeaders: Boolean? = null,
        val showGridLines: Boolean? = null,
        val gridStyle: String? = null,
        val horizontalCellContentAlignment: String? = null,
        val verticalCellContentAlignment: String? = null
    ) : StyledCollectionElement()
}

@Serializable
data class MediaSource(
    val mimeType: String,
    val url: String
)

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
data class TableColumnDefinition(
    val width: String? = null
)

@Serializable
data class TableRow(
    val type: String,
    val cells: List<TableCell>
)

@Serializable
data class TableCell(
    val type: String,
    val items: List<BaseCardElement>,
    val style: String? = null,
    val verticalContentAlignment: String? = null
)

@Serializable
sealed class InputElement {
    @Serializable
    @SerialName("Input.Text")
    data class Text(val data: InputText) : InputElement()

    @Serializable
    @SerialName("Input.Number")
    data class Number(val data: InputNumber) : InputElement()

    @Serializable
    @SerialName("Input.Date")
    data class Date(val data: InputDate) : InputElement()

    @Serializable
    @SerialName("Input.Time")
    data class Time(val data: InputTime) : InputElement()

    @Serializable
    @SerialName("Input.Toggle")
    data class Toggle(val data: InputToggle) : InputElement()

    @Serializable
    @SerialName("Input.ChoiceSet")
    data class ChoiceSet(val data: InputChoiceSet) : InputElement()

    @Serializable
    @SerialName("Input.Rating")
    data class RatingInputData(val data: RatingInput) : InputElement()
}

@Serializable
data class InputText(
    val isMultiline: Boolean? = null,
    val maxLength: Int? = null,
    val placeholder: String? = null,
    val style: String? = null,
    val value: String? = null
) : BaseCardElement.BaseInputElement()

@Serializable
data class InputNumber(
    val min: Double? = null,
    val max: Double? = null,
    val placeholder: String? = null,
    val value: Double? = null
) : BaseCardElement.BaseInputElement()

@Serializable
data class InputDate(
    val min: String? = null,
    val max: String? = null,
    val value: String? = null,
    val placeholder: String? = null
) : BaseCardElement.BaseInputElement()

@Serializable
data class InputTime(
    val min: String? = null,
    val max: String? = null,
    val value: String? = null,
    val placeholder: String? = null
) : BaseCardElement.BaseInputElement()

@Serializable
data class InputToggle(
    val title: String,
    val value: String? = null,
    val valueOn: String? = null,
    val valueOff: String? = null,
    val wrap: Boolean? = null
) : BaseCardElement.BaseInputElement()

@Serializable
data class InputChoiceSet(
    val isMultiSelect: Boolean? = null,
    val style: String? = null,
    val value: String? = null,
    val choices: List<Choice>
) : BaseCardElement.BaseInputElement()

@Serializable
data class RatingInput(
    val horizontalAlignment: HorizontalAlignment? = null,
    val value: Double,
    val max: Double
) : BaseCardElement.BaseInputElement()

@Serializable
data class Choice(
    val title: String,
    val value: String
)

@Serializable
class ValueChangedAction(
    val targetInputIds: List<String> = emptyList(),
    val valueChangedActionType: ValueChangedActionType = ValueChangedActionType.RESET_INPUTS
)

@Serializable
open class BaseElement(
    var id: String? = null,
    var typeString: String? = null,
    var additionalProperties: Map<String, JsonElement>? = null,
    var requires: Map<String, SemanticVersion>? = null,
    var fallback: BaseCardElement? = null,
    var internalId: InternalId? = null,
    var fallbackType: FallbackType? = null,
    var canFallbackToAncestor: Boolean? = null
)

@Serializable
data class InternalId(
    val id: UInt
)