package io.adaptivecards.parser.elements
import io.adaptivecards.parser.utils.HorizontalAlignment
import kotlinx.serialization.*
import kotlinx.serialization.json.*

@Serializable
sealed class InputElement {

    @Serializable
    data class InputText(
        val isMultiline: Boolean? = null,
        val maxLength: Int? = null,
        val placeholder: String? = null,
        val style: String? = null,
        val value: String? = null
    ) : BaseInputElement()

    @Serializable
    @SerialName("Input.Number")
    data class InputNumber(
        val min: Double? = null,
        val max: Double? = null,
        val placeholder: String? = null,
        val value: Double? = null
    ) : BaseInputElement()

    @Serializable
    @SerialName("Input.Date")
    data class InputDate(
        val min: String? = null,
        val max: String? = null,
        val value: String? = null,
        val placeholder: String? = null
    ) : BaseInputElement()

    @Serializable
    @SerialName("Input.Time")
    data class InputTime(
        val min: String? = null,
        val max: String? = null,
        val value: String? = null,
        val placeholder: String? = null
    ) : BaseInputElement()

    @SerialName("Input.Toggle")
    @Serializable
    data class InputToggle(
        val title: String,
        val value: String? = null,
        val valueOn: String? = null,
        val valueOff: String? = null,
        val wrap: Boolean? = null
    ) : BaseInputElement()

    @Serializable
    data class InputChoiceSet(
        val isMultiSelect: Boolean? = null,
        val style: String? = null,
        val value: String? = null,
        val choices: List<Choice>
    ) : BaseInputElement()


    @Serializable
    @SerialName("Input.Rating")
    data class RatingInput(
        val horizontalAlignment: HorizontalAlignment?,
        val value: Double,
        val max:Double
        ) : BaseInputElement()

    companion object {
        fun fromJson(json: String): InputElement {
            return Json.decodeFromString(json)
        }
    }
}

@Serializable
data class Choice(
    val title: String,
    val value: String
)