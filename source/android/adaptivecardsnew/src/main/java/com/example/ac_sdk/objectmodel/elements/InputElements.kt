package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.elements.models.Choice
import com.example.ac_sdk.objectmodel.utils.AdaptiveCardSchemaKey
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import kotlinx.serialization.*
import kotlinx.serialization.json.*

@Serializable
sealed class InputElements {

    @Serializable
    @SerialName("Input.Text")
    data class InputText(
        val isMultiline: Boolean? = null,
        val maxLength: Int? = null,
        val placeholder: String? = null,
        val style: String? = null,
        val value: String? = null
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.IS_MULTILINE,
                        AdaptiveCardSchemaKey.MAX_LENGTH,
                        AdaptiveCardSchemaKey.PLACEHOLDER,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.VALUE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Input.Number")
    data class InputNumber(
        val min: Double? = null,
        val max: Double? = null,
        val placeholder: String? = null,
        val value: Double? = null
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.MIN,
                        AdaptiveCardSchemaKey.MAX,
                        AdaptiveCardSchemaKey.PLACEHOLDER,
                        AdaptiveCardSchemaKey.VALUE
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Input.Date")
    data class InputDate(
        val min: String? = null,
        val max: String? = null,
        val value: String? = null,
        val placeholder: String? = null
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.MIN,
                        AdaptiveCardSchemaKey.MAX,
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.PLACEHOLDER
                    )
                )
            }
        }
    }

    @Serializable
    @SerialName("Input.Time")
    data class InputTime(
        val min: String? = null,
        val max: String? = null,
        val value: String? = null,
        val placeholder: String? = null
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.MIN,
                        AdaptiveCardSchemaKey.MAX,
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.PLACEHOLDER
                    )
                )
            }
        }
    }

    @SerialName("Input.Toggle")
    @Serializable
    data class InputToggle(
        val title: String,
        val value: String? = null,
        val valueOn: String? = null,
        val valueOff: String? = null,
        val wrap: Boolean? = null
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.TITLE,
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.VALUE_ON,
                        AdaptiveCardSchemaKey.VALUE_OFF,
                        AdaptiveCardSchemaKey.WRAP
                    )
                )
            }
        }
    }

    @Serializable
    data class InputChoiceSet(
        val isMultiSelect: Boolean? = null,
        val style: String? = null,
        val value: String? = null,
        val choices: List<Choice>
    ) : BaseInputElement() {
        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.IS_MULTI_SELECT,
                        AdaptiveCardSchemaKey.STYLE,
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.CHOICES
                    )
                )
            }
        }
    }


    @Serializable
    @SerialName("Input.Rating")
    data class RatingInput(
        val horizontalAlignment: HorizontalAlignment?,
        val value: Double,
        val max: Double
    ) : BaseInputElement() {

        override fun populateKnownPropertiesSet(): MutableSet<AdaptiveCardSchemaKey> {
            return super.populateKnownPropertiesSet().apply {
                addAll(
                    listOf(
                        AdaptiveCardSchemaKey.HORIZONTAL_ALIGNMENT,
                        AdaptiveCardSchemaKey.VALUE,
                        AdaptiveCardSchemaKey.MAX
                    )
                )
            }
        }

    }

    companion object {
        fun fromJson(json: String): BaseInputElement {
            return Json.decodeFromString(json)
        }
    }
}