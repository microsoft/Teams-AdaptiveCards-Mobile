import com.example.ac_sdk.AdaptiveCardParser
import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.Authentication
import com.example.ac_sdk.objectmodel.BackgroundImage
import com.example.ac_sdk.objectmodel.Refresh
import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.elements.CollectionElement
import com.example.ac_sdk.objectmodel.elements.InputElements
import com.example.ac_sdk.objectmodel.elements.models.Fact
import com.example.ac_sdk.objectmodel.elements.models.PlainTextInline
import com.example.ac_sdk.objectmodel.elements.models.TextRun
import com.example.ac_sdk.objectmodel.parser.ParseContext
import com.example.ac_sdk.objectmodel.utils.AssociatedInputs
import com.example.ac_sdk.objectmodel.utils.ChoiceSetStyle
import com.example.ac_sdk.objectmodel.utils.ContainerStyle
import com.example.ac_sdk.objectmodel.utils.FontType
import com.example.ac_sdk.objectmodel.utils.ForegroundColor
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.ImageFillMode
import com.example.ac_sdk.objectmodel.utils.ImageSize
import com.example.ac_sdk.objectmodel.utils.ImageStyle
import com.example.ac_sdk.objectmodel.utils.Spacing
import com.example.ac_sdk.objectmodel.utils.TextInputStyle
import com.example.ac_sdk.objectmodel.utils.TextSize
import com.example.ac_sdk.objectmodel.utils.TextStyle
import com.example.ac_sdk.objectmodel.utils.TextWeight
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class EverythingBagelTests {

    companion object {
        private val EVERYTHING_JSON = """
        {
  "type": "AdaptiveCard",
  "version": "1.0",
  "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
  "refresh": {
    "action": {
      "type": "Action.Execute",
      "id": "refresh_action_id",
      "verb": "refresh_action_verb"
    },
    "userIds": [
      "refresh_userIds_0"
    ]
  },
  "authentication": {
    "text": "authentication_text",
    "connectionName": "authentication_connectionName",
    "tokenExchangeResource": {
      "id": "authentication_tokenExchangeResource_id",
      "uri": "authentication_tokenExchangeResource_uri",
      "providerId": "authentication_tokenExchangeResource_providerId"
    },
    "buttons": [
      {
        "type": "authentication_buttons_0_type",
        "title": "authentication_buttons_0_title",
        "image": "authentication_buttons_0_image",
        "value": "authentication_buttons_0_value"
      }
    ]
  },
  "fallbackText": "fallbackText",
  "speak": "speak",
  "lang": "en",
  "rtl": false,
  "body": [
    {
      "type": "TextBlock",
      "text": "TextBlock_text",
      "color": "default",
      "horizontalAlignment": "left",
      "isSubtle": false,
      "italic": true,
      "maxLines": 1,
      "size": "default",
      "weight": "default",
      "wrap": false,
      "id": "TextBlock_id",
      "spacing": "default",
      "separator": false,
      "strikethrough": true,
      "style": "Heading"
    },
    {
      "type": "TextBlock",
      "text": "TextBlock_text",
      "color": "default",
      "horizontalAlignment": "left",
      "isSubtle": false,
      "italic": true,
      "maxLines": 1,
      "size": "default",
      "weight": "default",
      "wrap": false,
      "id": "TextBlock_id_mono",
      "spacing": "default",
      "separator": false,
      "strikethrough": true,
      "fontType": "monospace"
    },
    {
      "type": "TextBlock",
      "text": "TextBlock_text",
      "color": "default",
      "horizontalAlignment": "left",
      "isSubtle": false,
      "italic": true,
      "maxLines": 1,
      "size": "default",
      "weight": "default",
      "wrap": false,
      "id": "TextBlock_id_def",
      "spacing": "default",
      "separator": false,
      "strikethrough": true,
      "fontType": "default"
    },
    {
      "type": "Image",
      "altText": "Image_altText",
      "horizontalAlignment": "center",
      "selectAction": {
        "type": "Action.OpenUrl",
        "title": "Image_Action.OpenUrl",
        "url": "https://adaptivecards.io/"
      },
      "size": "auto",
      "style": "person",
      "url": "https://adaptivecards.io/content/cats/1.png",
      "id": "Image_id",
      "isVisible": false,
      "spacing": "none",
      "separator": true
    },
    {
      "type": "Container",
      "style": "default",
      "selectAction": {
        "type": "Action.Submit",
        "title": "Container_Action.Submit",
        "data": {
          "submitValue": "value"
        }
      },
      "id": "Container_id",
      "spacing": "medium",
      "separator": false,
      "rtl": true,
      "items": [
        {
          "type": "ColumnSet",
          "id": "ColumnSet_id",
          "spacing": "large",
          "separator": true,
          "columns": [
            {
              "type": "Column",
              "style": "default",
              "width": "auto",
              "id": "Column_id1",
              "rtl": false,
              "items": [
                {
                  "type": "Image",
                  "url": "https://adaptivecards.io/content/cats/1.png"
                }
              ]
            },
            {
              "type": "Column",
              "style": "emphasis",
              "width": "20px",
              "id": "Column_id2",
              "items": [
                {
                  "type": "Image",
                  "url": "https://adaptivecards.io/content/cats/2.png"
                }
              ]
            },
            {
              "type": "Column",
              "style": "default",
              "width": "stretch",
              "id": "Column_id3",
              "items": [
                {
                  "type": "Image",
                  "url": "https://adaptivecards.io/content/cats/3.png"
                },
                {
                  "type": "TextBlock",
                  "text": "Column3_TextBlock_text",
                  "id": "Column3_TextBlock_id",
                  "fontType": "default"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "FactSet",
      "id": "FactSet_id",
      "facts": [
        {
          "type": "Fact",
          "title": "Topping",
          "value": "poppyseeds"
        },
        {
          "type": "Fact",
          "title": "Topping",
          "value": "onion flakes"
        }
      ]
    },
    {
      "type": "ImageSet",
      "imageSize": "auto",
      "id": "ImageSet_id",
      "separator": true,
      "images": [
        {
          "type": "Image",
          "url": "https://adaptivecards.io/content/cats/1.png"
        },
        {
          "type": "Image",
          "url": "https://adaptivecards.io/content/cats/2.png"
        },
        {
          "type": "Image",
          "url": "https://adaptivecards.io/content/cats/3.png"
        }
      ]
    },
    {
      "type": "Container",
      "id": "Container_id_inputs",
      "items": [
        {
          "type": "Input.Text",
          "id": "Input.Text_id",
          "isMultiline": false,
          "label": "Input.Text_label",
          "maxLength": 10,
          "placeholder": "Input.Text_placeholder",
          "style": "text",
          "value": "Input.Text_value",
          "spacing": "small",
          "isRequired": false,
          "regex": "([A-Z])\\\\w+",
          "inlineAction": {
            "type": "Action.Submit",
            "iconUrl": "https://adaptivecards.io/content/cats/1.png",
            "title": "Input.Text_Action.Submit"
          }
        },
        {
          "type": "Input.Number",
          "id": "Input.Number_id",
          "label": "Input.Number_label",
          "max": 9.5,
          "min": 3.5,
          "placeholder": "Input.Number_placeholder",
          "value": 4.5,
          "isRequired": true
        },
        {
          "type": "Input.Date",
          "id": "Input.Date_id",
          "label": "Input.Date_label",
          "min": "8/1/2018",
          "max": "1/1/2020",
          "placeholder": "Input.Date_placeholder",
          "value": "8/9/2018"
        },
        {
          "type": "Input.Time",
          "id": "Input.Time_id",
          "label": "Input.Time_label",
          "min": "10:00",
          "max": "17:00",
          "value": "13:00",
          "placeholder": "Input.Time_placeholder",
          "isRequired": true,
          "errorMessage": "Input.Time.ErrorMessage"
        },
        {
          "type": "Input.Toggle",
          "id": "Input.Toggle_id",
          "label": "Input.Toggle_label",
          "title": "Input.Toggle_title",
          "value": "Input.Toggle_on",
          "valueOff": "Input.Toggle_off",
          "valueOn": "Input.Toggle_on"
        },
        {
          "type": "TextBlock",
          "weight": "BoLdEr",
          "size": "large",
          "text": "Everybody's got choices"
        },
        {
          "type": "Input.ChoiceSet",
          "id": "Input.ChoiceSet_id",
          "isMultiSelect": true,
          "label": "Input.ChoiceSet_label",
          "style": "compact",
          "value": "Input.Choice2,Input.Choice4",
          "choices": [
            {
              "type": "Input.Choice",
              "title": "Input.Choice1_title",
              "value": "Input.Choice1"
            },
            {
              "type": "Input.Choice",
              "title": "Input.Choice2_title",
              "value": "Input.Choice2"
            },
            {
              "type": "Input.Choice",
              "title": "Input.Choice3_title",
              "value": "Input.Choice3"
            },
            {
              "type": "Input.Choice",
              "title": "Input.Choice4_title",
              "value": "Input.Choice4"
            }
          ]
        }
      ]
    },
    {
      "type": "ActionSet",
      "actions": [
        {
          "type": "Action.Submit",
          "title": "ActionSet.Action.Submit",
          "id": "ActionSet.Action.Submit_id",
          "associatedInputs": "none",
          "tooltip": "tooltip",
          "isEnabled": false
        },
        {
          "type": "Action.OpenUrl",
          "title": "ActionSet.Action.OpenUrl",
          "id": "ActionSet.Action.OpenUrl_id",
          "tooltip": "tooltip",
          "url": "https://adaptivecards.io/",
          "isEnabled": true
        }
      ]
    },
    {
      "type": "RichTextBlock",
      "id": "RichTextBlock_id",
      "horizontalAlignment": "right",
      "inlines": [
        {
          "color": "Dark",
          "fontType": "Monospace",
          "highlight": true,
          "isSubtle": true,
          "italic": true,
          "size": "large",
          "strikethrough": true,
          "text": "This is a text run",
          "type": "TextRun",
          "underline": true,
          "weight": "Bolder"
        },
        {
          "type": "TextRun",
          "text": "This is another text run",
          "selectAction": {
            "type": "Action.Submit",
            "data": {"key": "value"}
          }
        },
        "This is a text run specified as a string"
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "Action.Submit",
      "id": "Action.Submit_id",
      "tooltip": "tooltip",
      "isEnabled": true,
      "data": {
        "submitValue": true
      }
    },
    {
      "type": "Action.Execute",
      "verb": "Action.Execute_verb",
      "title": "Action.Execute_title",
      "id": "Action.Execute_id",
      "associatedInputs": "none",
      "isEnabled": false,
      "data": {
        "Action.Execute_data_keyA": "Action.Execute_data_valueA"
      }
    },
    {
      "type": "Action.ShowCard",
      "title": "Action.ShowCard",
      "id": "Action.ShowCard_id",
      "tooltip": "tooltip",
      "card": {
        "type": "AdaptiveCard",
        "backgroundImage": {
          "url": "https://adaptivecards.io/content/cats/1.png",
          "fillMode": "repeat",
          "verticalAlignment": "center",
          "horizontalAlignment": "right"
        },
        "body": [
          {
            "type": "TextBlock",
            "isSubtle": true,
            "text": "Action.ShowCard text"
          }
        ]
      }
    }
  ]
  }
        """.trimIndent()
    }

    // MARK: - Helper Validators

    private fun validateBackgroundImage(
        backImage: BackgroundImage,
        mode: ImageFillMode,
        hAlignment: HorizontalAlignment,
        vAlignment: VerticalAlignment
    ) {
        assertEquals("https://adaptivecards.io/content/cats/1.png", backImage.url)
        assertEquals(mode, backImage.fillMode)
        assertEquals(hAlignment, backImage.horizontalAlignment)
        assertEquals(vAlignment, backImage.verticalAlignment)
    }

    private fun validateRefresh(refresh: Refresh) {
        assertNotNull(refresh.action)
        assertEquals("refresh_action_id", refresh.action.id)
        assertEquals(1, refresh.userIds.size)
        assertEquals("refresh_userIds_0", refresh.userIds.first())
    }

    private fun validateAuthentication(auth: Authentication) {
        assertEquals("authentication_text", auth.text)
        assertEquals("authentication_connectionName", auth.connectionName)
        assertNotNull(auth.tokenExchangeResource)
        assertEquals("authentication_tokenExchangeResource_id", auth.tokenExchangeResource?.id)
        assertEquals("authentication_tokenExchangeResource_uri", auth.tokenExchangeResource?.uri)
        assertEquals(
            "authentication_tokenExchangeResource_providerId",
            auth.tokenExchangeResource.providerId
        )
        assertEquals(1, auth.buttons.size)
        auth.buttons.firstOrNull()?.let { button ->
            assertEquals("authentication_buttons_0_type", button.type)
            assertEquals("authentication_buttons_0_title", button.title)
            assertEquals("authentication_buttons_0_image", button.image)
            assertEquals("authentication_buttons_0_value", button.value)
        } ?: fail("No authentication button found")
    }

    private fun validateTopLevelProperties(card: AdaptiveCard) {
        card.backgroundImage?.let {
            assertEquals("https://adaptivecards.io/content/cats/1.png", it.url)
        }
            ?: fail("Missing background image")
        card.refresh?.let { validateRefresh(it) } ?: fail("Missing refresh")
        card.authentication?.let { validateAuthentication(it) } ?: fail("Missing authentication")
        assertEquals("fallbackText", card.fallbackText)
        assertEquals(HeightType.AUTO, card.height)
        assertEquals("", card.language)
        assertNull(card.selectAction)
        assertEquals("speak", card.speak)
        assertEquals(ContainerStyle.NONE, card.style)
        assertEquals("1.0", card.version)
        assertNotNull(card.rtl)
        assertFalse(card.rtl!!)
        assertEquals(VerticalAlignment.TOP, card.verticalAlignment)
    }

    private fun validateTextBlock(
        textBlock: CardElements.TextBlock,
        fontType: FontType?,
        style: TextStyle?,
        id: String
    ) {
        assertEquals(id, textBlock.id)
        assertEquals("TextBlock_text", textBlock.text)
        assertEquals(style, textBlock.style)
        assertEquals(ForegroundColor.DEFAULT, textBlock.color)
        assertEquals(HorizontalAlignment.LEFT, textBlock.horizontalAlignment)
        assertEquals(Spacing.DEFAULT, textBlock.spacing)
        assertEquals(1, textBlock.maxLines)
        assertEquals(TextSize.DEFAULT, textBlock.size)
        assertEquals(TextWeight.DEFAULT, textBlock.weight)
        assertEquals(fontType, textBlock.fontType)
        assertNotNull(textBlock.isSubtle)
        assertFalse(textBlock.isSubtle!!)
        assertFalse(textBlock.separator == true)
        assertFalse(textBlock.wrap == true)
    }

    private fun validateImage(image: CardElements.Image) {
        assertEquals("Image_id", image.id)
        assertEquals("Image_altText", image.altText)
        assertEquals("https://adaptivecards.io/content/cats/1.png", image.url)
        assertEquals("", image.backgroundColor)
        assertEquals(ImageStyle.PERSON, image.style)
        assertEquals(Spacing.NONE, image.spacing)
        assertNull(image.height)
        assertEquals(HorizontalAlignment.CENTER, image.horizontalAlignment)
        assertEquals(ImageSize.AUTO, image.size)
        assertTrue(image.separator == true)
        assertFalse(image.isVisible == true)
        if (image.selectAction is ActionElements.ActionOpenUrl) {
            val imageAction = image.selectAction as ActionElements.ActionOpenUrl
            assertEquals("Image_Action.OpenUrl", imageAction.title)
            assertEquals("https://adaptivecards.io/", imageAction.url)
            assertTrue(imageAction.isEnabled)
        } else {
            fail("Image selectAction is not OpenUrlAction")
        }
    }

    private fun validateColumnSet(columnSet: CollectionElement.ColumnSet) {
        assertEquals("ColumnSet_id", columnSet.id)
        assertEquals(Spacing.LARGE, columnSet.spacing)
        assertTrue(columnSet.separator == true)
        val columns = columnSet.columns
        assertEquals(3, columns?.size)
        // First column.
        val firstColumn: CollectionElement.Column? = columns?.get(0)
        assertEquals("Column_id1", firstColumn?.id)
        assertEquals("auto", firstColumn?.width)
        assertEquals(0, firstColumn?.pixelWidth)
        assertEquals(ContainerStyle.DEFAULT, firstColumn?.style)
        assertNotNull(firstColumn)
        assertFalse(firstColumn?.rtl!!)
        val firstItems = firstColumn.items
        assertEquals(1, firstItems.size)
        val firstImage = firstItems.first() as? CardElements.Image
        assertEquals("https://adaptivecards.io/content/cats/1.png", firstImage?.url)
        // Second column.
        val secondColumn = columns.get(1)

        assertEquals("20px", secondColumn.width)
        val secondItems = secondColumn.items
        assertEquals(1, secondItems.size)
        val secondImage = secondItems.first() as? CardElements.Image
        assertEquals("https://adaptivecards.io/content/cats/2.png", secondImage?.url)
        // Third column.
        val thirdColumn = columns.get(2) as? CollectionElement.Column
        assertEquals("stretch", thirdColumn?.width)
        assertEquals(0, thirdColumn?.pixelWidth)
        assertEquals(ContainerStyle.DEFAULT, thirdColumn?.style)
        val thirdItems = thirdColumn?.items
        assertEquals(2, thirdItems?.size)
        val thirdImage = thirdItems?.get(0) as? CardElements.Image
        assertEquals("https://adaptivecards.io/content/cats/3.png", thirdImage?.url)
        val thirdTextBlock = thirdItems?.get(1) as? CardElements.TextBlock
        assertEquals("Column3_TextBlock_text", thirdTextBlock?.text)
        assertEquals("Column3_TextBlock_id", thirdTextBlock?.id)
    }

    private fun validateColumnSetContainer(container: CollectionElement.Container) {
        assertEquals("Container_id", container.id)
        assertEquals(Spacing.MEDIUM, container.spacing)
        assertEquals(ContainerStyle.DEFAULT, container.style)
        assertNotNull(container.rtl)
        assertTrue(container.rtl!!)
        val action = container.selectAction as? ActionElements.ActionSubmit
        assertEquals("Container_Action.Submit", action?.title)
        when (val data = action?.data) {
            is Map<String, JsonElement> -> {
                val dataString = Json.encodeToString(data)
                assertEquals("{\"submitValue\":\"value\"}", dataString)
            }

            else -> fail("dataJson is neither String nor Map")
        }
        assertEquals(AssociatedInputs.NONE, action?.associatedInputs)
        val items = container.items
        assertEquals(1, items?.size)
        val columnSet = items?.first() as CollectionElement.ColumnSet
        validateColumnSet(columnSet)
    }

    private fun validateFactSet(factSet: CardElements.FactSet) {
        assertEquals("FactSet_id", factSet.id)
        val facts = factSet.facts
        assertEquals(2, facts.size)
        val firstFact = facts[0] as? Fact
        assertEquals("Topping", firstFact?.title)
        assertEquals("poppyseeds", firstFact?.value)
        val secondFact = facts[1] as? Fact
        assertEquals("Topping", secondFact?.title)
        assertEquals("onion flakes", secondFact?.value)
    }

    private fun validateImageSet(imageSet: CardElements.ImageSet) {
        assertEquals("ImageSet_id", imageSet.id)
        assertEquals(ImageSize.AUTO, imageSet.imageSize)
        val images = imageSet.images
        assertEquals(3, images?.size)
        images?.forEachIndexed { index, image ->
            val currImage = image as? CardElements.Image
            val expectedUrl = "https://adaptivecards.io/content/cats/${index + 1}.png"
            assertEquals(expectedUrl, currImage?.url)
        }
    }

    private fun validateInputText(textInput: InputElements.TextInput) {
        assertEquals("Input.Text_id", textInput.id)
        assertFalse(textInput.isMultiline == true)
        assertFalse(textInput.isRequired == true)
        assertEquals(10, textInput.maxLength)
        assertEquals("Input.Text_placeholder", textInput.placeholder)
        assertEquals(Spacing.SMALL, textInput.spacing)
        assertEquals(TextInputStyle.TEXT.toString().lowercase(), textInput.style)
        assertEquals("Input.Text_value", textInput.value)
        assertTrue(textInput.errorMessage.isNullOrEmpty())
        assertEquals("([A-Z])\\\\w+", textInput.regex)
        assertEquals("Input.Text_label", textInput.label)
        val inlineAction = textInput.inlineAction as? ActionElements.ActionSubmit
        assertEquals("Input.Text_Action.Submit", inlineAction?.title)
        assertEquals("https://adaptivecards.io/content/cats/1.png", inlineAction?.iconUrl)
        assertEquals(AssociatedInputs.NONE, inlineAction?.associatedInputs)
        assertTrue(inlineAction?.isEnabled == true)
    }

    private fun validateInputNumber(numberInput: InputElements.NumberInput) {
        assertEquals("Input.Number_id", numberInput.id)
        assertTrue(numberInput.isRequired == true)
        assertEquals(9.5, numberInput.max)
        assertEquals(3.5, numberInput.min)
        assertEquals(4.5, numberInput.value)
        assertEquals("Input.Number_placeholder", numberInput.placeholder)
        assertTrue(numberInput.errorMessage.isNullOrEmpty())
        assertEquals("Input.Number_label", numberInput.label)
    }

    private fun validateInputDate(dateInput: InputElements.DateInput) {
        assertEquals("Input.Date_id", dateInput.id)
        assertEquals("1/1/2020", dateInput.max)
        assertEquals("8/1/2018", dateInput.min)
        assertEquals("8/9/2018", dateInput.value)
        assertEquals("Input.Date_placeholder", dateInput.placeholder)
        assertFalse(dateInput.isRequired == true)
        assertTrue(dateInput.errorMessage.isNullOrEmpty())
        assertEquals("Input.Date_label", dateInput.label)
    }

    private fun validateInputTime(timeInput: InputElements.TimeInput) {
        assertEquals("Input.Time_id", timeInput.id)
        assertEquals("10:00", timeInput.min)
        assertEquals("17:00", timeInput.max)
        assertEquals("13:00", timeInput.value)
        assertTrue(timeInput.isRequired == true)
        assertEquals("Input.Time.ErrorMessage", timeInput.errorMessage)
        assertEquals("Input.Time_label", timeInput.label)
    }

    private fun validateInputToggle(toggleInput: InputElements.ToggleInput) {
        assertEquals("Input.Toggle_id", toggleInput.id)
        assertEquals("Input.Toggle_title", toggleInput.title)
        assertEquals("Input.Toggle_on", toggleInput.value)
        assertEquals("Input.Toggle_on", toggleInput.valueOn)
        assertEquals("Input.Toggle_off", toggleInput.valueOff)
        assertFalse(toggleInput.isRequired == true)
        assertTrue(toggleInput.errorMessage.isNullOrEmpty())
        assertEquals("Input.Toggle_label", toggleInput.label)
    }

    private fun validateTextBlockInInput(textBlock: CardElements.TextBlock) {
        assertNull(textBlock.id)
        assertEquals("Everybody's got choices", textBlock.text)
        assertEquals(TextWeight.BOLDER, textBlock.weight)
        assertEquals(TextSize.LARGE, textBlock.size)
    }

    private fun validateInputChoiceSet(choiceSet: InputElements.ChoiceSetInput) {
        assertEquals("Input.ChoiceSet_id", choiceSet.id)
        assertEquals(ChoiceSetStyle.COMPACT.toString().lowercase(), choiceSet.style)
        assertEquals("Input.Choice2,Input.Choice4", choiceSet.value)
        assertTrue(choiceSet.isMultiSelect == true)
        assertFalse(choiceSet.isRequired == true)
        assertTrue(choiceSet.errorMessage.isNullOrEmpty())
        val choices = choiceSet.choices
        assertEquals(4, choices.size)
        for (i in choices.indices) {
            val currChoice = choices[i]
            val expectedValue = "Input.Choice${i + 1}"
            assertEquals(expectedValue, currChoice.value)
            val expectedTitle = "Input.Choice${i + 1}_title"
            assertEquals(expectedTitle, currChoice.title)
        }
        assertEquals("Input.ChoiceSet_label", choiceSet.label)
    }

    private fun validateInputContainer(container: CollectionElement.Container) {
        assertEquals("Container_id_inputs", container.id)
        assertNull(container.rtl)
        val items = container.items
        assertEquals(7, items?.size)
        if (items?.get(0) is InputElements.TextInput) {
            validateInputText(items[0] as InputElements.TextInput)
        } else {
            fail("Expected TextInput in input container")
        }
        if (items?.get(1) is InputElements.NumberInput) {
            validateInputNumber(items[1] as InputElements.NumberInput)
        } else {
            fail("Expected NumberInput in input container")
        }
        if (items?.get(2) is InputElements.DateInput) {
            validateInputDate(items[2] as InputElements.DateInput)
        } else {
            fail("Expected DateInput in input container")
        }
        if (items?.get(3) is InputElements.TimeInput) {
            validateInputTime(items[3] as InputElements.TimeInput)
        } else {
            fail("Expected TimeInput in input container")
        }
        if (items?.get(4) is InputElements.ToggleInput) {
            validateInputToggle(items[4] as InputElements.ToggleInput)
        } else {
            fail("Expected ToggleInput in input container")
        }
        if (items?.get(5) is CardElements.TextBlock) {
            validateTextBlockInInput(items[5] as CardElements.TextBlock)
        } else {
            fail("Expected TextBlock in input container")
        }
        if (items?.get(6) is InputElements.ChoiceSetInput) {
            validateInputChoiceSet(items[6] as InputElements.ChoiceSetInput)
        } else {
            fail("Expected ChoiceSetInput in input container")
        }
    }

    private fun validateActionSet(actionSet: CardElements.ActionSet) {
        val actions = actionSet.actions
        assertEquals(2, actions.size)
        if (actions[0] is ActionElements.ActionSubmit) {
            val submitAction = actions[0] as ActionElements.ActionSubmit
            assertEquals("ActionSet.Action.Submit_id", submitAction.id)
            assertEquals(AssociatedInputs.NONE, submitAction.associatedInputs)
            assertEquals("tooltip", submitAction.tooltip)
            assertTrue(!submitAction.isEnabled)
        } else {
            fail("Expected SubmitAction in ActionSet")
        }
        if (actions[1] is ActionElements.ActionOpenUrl) {
            val openUrlAction = actions[1] as ActionElements.ActionOpenUrl
            assertEquals("ActionSet.Action.OpenUrl_id", openUrlAction.id)
            assertEquals("tooltip", openUrlAction.tooltip)
            assertTrue(openUrlAction.isEnabled)
        } else {
            fail("Expected OpenUrlAction in ActionSet")
        }
    }

    private fun validateRichTextBlock(richTextBlock: CardElements.RichTextBlock) {
       // assertNull(richTextBlock.horizontalAlignment)
        val inlines = richTextBlock.inlines
        assertEquals(3, inlines.size)
        if (inlines[0] is TextRun) {
            val inlineTextElement = inlines[0] as TextRun
            assertEquals("This is a text run", inlineTextElement.text)
            assertEquals(ForegroundColor.DARK, inlineTextElement.color)
            assertEquals(TextSize.LARGE, inlineTextElement.size)
            assertEquals(TextWeight.BOLDER, inlineTextElement.weight)
            assertEquals(
                FontType.MONOSPACE.toString().lowercase(),
                inlineTextElement.fontType?.lowercase()
            )
            assertNotNull(inlineTextElement.isSubtle)
            assertTrue(inlineTextElement.isSubtle!!)
            assertTrue(inlineTextElement.italic == true)
            assertTrue(inlineTextElement.highlight == true)
            assertTrue(inlineTextElement.strikethrough == true)
            assertTrue(inlineTextElement.underline == true)
        } else {
            fail("Expected TextRun as first inline in RichTextBlock")
        }
        if (inlines[1] is TextRun) {
            val inlineTextElement = inlines[1] as TextRun
            assertTrue(inlineTextElement.selectAction is ActionElements.ActionSubmit)
            if (inlineTextElement.selectAction is ActionElements.ActionSubmit) {
                val selectAction = inlineTextElement.selectAction as ActionElements.ActionSubmit
                assertEquals(AssociatedInputs.NONE, selectAction.associatedInputs)
            } else {
                fail("Expected inline text selectAction to be SubmitAction")
            }
        } else {
            fail("Expected TextRun as second inline in RichTextBlock")
        }
        if (inlines[2] is PlainTextInline) {
            assertEquals("This is a text run specified as a string", (inlines[2] as PlainTextInline).text)
        } else {
            fail("Expected String as third inline in RichTextBlock")
        }
    }

    private fun validateBody(card: AdaptiveCard) {
        val body = card.body
        assertEquals(10, body.size)
        if (body[0] is CardElements.TextBlock) {
            validateTextBlock(
                body[0] as CardElements.TextBlock,
                fontType = null,
                style = TextStyle.HEADING,
                id = "TextBlock_id"
            )
        } else {
            fail("Expected TextBlock as first element in body")
        }
        if (body[1] is CardElements.TextBlock) {
            validateTextBlock(
                body[1] as CardElements.TextBlock,
                fontType = FontType.MONOSPACE,
                style = null,
                id = "TextBlock_id_mono"
            )
        } else {
            fail("Expected TextBlock as second element in body")
        }
        if (body[2] is CardElements.TextBlock) {
            validateTextBlock(
                body[2] as CardElements.TextBlock,
                fontType = FontType.DEFAULT,
                style = null,
                id = "TextBlock_id_def"
            )
        } else {
            fail("Expected TextBlock as third element in body")
        }
        if (body[3] is CardElements.Image) {
            validateImage(body[3] as CardElements.Image)
        } else {
            fail("Expected Image as fourth element in body")
        }
        if (body[4] is CollectionElement.Container) {
            validateColumnSetContainer(body[4] as CollectionElement.Container)
        } else {
            fail("Expected Container as fifth element in body")
        }
        if (body[5] is CardElements.FactSet) {
            validateFactSet(body[5] as CardElements.FactSet)
        } else {
            fail("Expected FactSet as sixth element in body")
        }
        if (body[6] is CardElements.ImageSet) {
            validateImageSet(body[6] as CardElements.ImageSet)
        } else {
            fail("Expected ImageSet as seventh element in body")
        }
        if (body[7] is CollectionElement.Container) {
            validateInputContainer(body[7] as CollectionElement.Container)
        } else {
            fail("Expected input Container as eighth element in body")
        }
        if (body[8] is CardElements.ActionSet) {
            validateActionSet(body[8] as CardElements.ActionSet)
        } else {
            fail("Expected ActionSet as ninth element in body")
        }
        if (body[9] is CardElements.RichTextBlock) {
            validateRichTextBlock(body[9] as CardElements.RichTextBlock)
        } else {
            fail("Expected RichTextBlock as tenth element in body")
        }
    }

    private fun validateToplevelActions(card: AdaptiveCard) {
        val actions = card.actions
        assertEquals(3, actions.size)
        if (actions[0] is ActionElements.ActionSubmit) {
            val submitAction = actions[0] as ActionElements.ActionSubmit
            assertEquals("Action.Submit_id", submitAction.id)
            assertEquals("Action.Submit", submitAction.title)
            when (val data = submitAction.data) {
                is Map<*, *> -> {
                    assertTrue(data["submitValue"]?.jsonPrimitive?.content, true)
                }

                else -> fail("submitAction.dataJson is neither String nor Map")
            }
            assertEquals(
                AssociatedInputs.NONE.toString().lowercase(),
                submitAction.associatedInputs.toString().lowercase()
            )
            assertEquals("tooltip", submitAction.tooltip)
            assertTrue(submitAction.isEnabled == true)
            assertTrue(submitAction.additionalProperties?.jsonObject.isNullOrEmpty())
        } else {
            fail("Expected SubmitAction as first top-level action")
        }
        if (actions[1] is ActionElements.ActionExecute) {
            val executeAction = actions[1] as ActionElements.ActionExecute
            assertEquals("Action.Execute_id", executeAction.id)
            assertEquals("Action.Execute_title", executeAction.title)
            assertEquals("Action.Execute_verb", executeAction.verb)
            val executePlain = executeAction.data
            val executeDataString = try {
                Json.encodeToString(executePlain)
            } catch (e: Exception) {
                ""
            }

            assertEquals(
                "{\"Action.Execute_data_keyA\":\"Action.Execute_data_valueA\"}",
                executeDataString
            )
            assertEquals(AssociatedInputs.NONE, executeAction.associatedInputs)
            assertTrue(!executeAction.isEnabled)
        } else {
            fail("Expected ExecuteAction as second top-level action")
        }
        if (actions[2] is ActionElements.ActionShowCard) {
            val showCardAction = actions[2] as ActionElements.ActionShowCard
            assertEquals("Action.ShowCard_id", showCardAction.id)
            assertEquals("Action.ShowCard", showCardAction.title)
            assertEquals("tooltip", showCardAction.tooltip)
            assertTrue(showCardAction.isEnabled)
            val subCard = showCardAction.card as? AdaptiveCard
            assertEquals(0, subCard?.actions?.size)
            validateBackgroundImage(
                subCard?.backgroundImage!!,
                ImageFillMode.REPEAT,
                HorizontalAlignment.RIGHT,
                VerticalAlignment.CENTER
            )
            assertEquals("", subCard.fallbackText)
            assertEquals("", subCard.language)
            assertNull(subCard.selectAction)
            assertEquals("", subCard.speak)
            assertEquals(ContainerStyle.NONE, subCard.style)
            assertEquals("", subCard.version)
            assertEquals(VerticalAlignment.TOP, subCard.verticalAlignment)
            val serializedData = subCard.serialize()
            val expectedJsonString =
                """{"backgroundImage":{"fillMode":"repeat","horizontalAlignment":"right","url":"https://adaptivecards.io/content/cats/1.png","verticalAlignment":"center"},"body":[{"isSubtle":true,"text":"Action.ShowCard text","type":"TextBlock"}],"type":"AdaptiveCard"}"""
            val json = Json { ignoreUnknownKeys = true }

            // Parse the JSON strings into JSON elements
            val expectedElement = json.parseToJsonElement(expectedJsonString)
            val actualElement = json.parseToJsonElement(serializedData)
            assertEquals(expectedElement, actualElement)
        } else {
            fail("Expected ShowCardAction as third top-level action")
        }
    }

    private fun validateFallbackCard(card: AdaptiveCard) {
        val fallbackCard = AdaptiveCardParser.makeFallbackTextCard("fallback", "en", "speak")
        val fallbackTextBlock = fallbackCard.body.firstOrNull() as? CardElements.TextBlock
        assertEquals("fallback", fallbackTextBlock?.text)
        assertEquals("en", fallbackCard.language)
        assertEquals("speak", fallbackCard.speak)
    }

    private fun compareJsonStructures(
        expected: Map<String, Any>,
        actual: Map<String, Any>,
        path: String = ""
    ) {
        val expectedKeys = expected.keys
        val actualKeys = actual.keys
        val missingInActual = expectedKeys.subtract(actualKeys)
        missingInActual.forEach { key ->
            println("Missing in actual at $path/$key: ${expected[key] ?: "nil"}")
        }
        val extraInActual = actualKeys.subtract(expectedKeys)
        extraInActual.forEach { key ->
            println("Extra in actual at $path/$key: ${actual[key] ?: "nil"}")
        }
        val sharedKeys = expectedKeys.intersect(actualKeys)
        sharedKeys.forEach { key ->
            val currentPath = if (path.isEmpty()) key else "$path/$key"
            val expectedValue = expected[key]
            val actualValue = actual[key]
            if (expectedValue is Map<*, *> && actualValue is Map<*, *>) {
                @Suppress("UNCHECKED_CAST")
                compareJsonStructures(
                    expectedValue as Map<String, Any>,
                    actualValue as Map<String, Any>,
                    currentPath
                )
            } else if (expectedValue is List<*> && actualValue is List<*>) {
                if (expectedValue.size != actualValue.size) {
                    println("Array count mismatch at $currentPath: expected ${expectedValue.size}, got ${actualValue.size}")
                }
                for (i in expectedValue.indices) {
                    val expItem = expectedValue[i]
                    val actItem = actualValue[i]
                    if (expItem is Map<*, *> && actItem is Map<*, *>) {
                        @Suppress("UNCHECKED_CAST")
                        compareJsonStructures(
                            expItem as Map<String, Any>,
                            actItem as Map<String, Any>,
                            "$currentPath[$i]"
                        )
                    }
                }
            } else if (!areValuesSemanticallyEqual(expectedValue, actualValue)) {
                println("Value mismatch at $currentPath:")
                println("Expected: $expectedValue")
                println("Actual:   $actualValue")
            }
        }
    }

    private fun areValuesSemanticallyEqual(expected: Any?, actual: Any?): Boolean {
        if (expected == null && actual == null) return true
        if (expected == null || actual == null) return false
        if (expected is Number && actual is Number) {
            return expected.toDouble() == actual.toDouble()
        }
        if (expected is String && actual is String) {
            val caseInsensitiveProperties = listOf("style", "type", "weight", "size", "color")
            if (caseInsensitiveProperties.any { expected.lowercase().contains(it) }) {
                return expected.lowercase() == actual.lowercase()
            }
        }
        return expected == actual
    }

    @Test
    fun testEverythingBagel() {
        val parseContext = ParseContext()
        val parseResult =
            AdaptiveCardParser.deserializeFromString(EVERYTHING_JSON, "1.0", parseContext)
        assertEquals(0, parseResult.warnings?.size)
        val everythingBagel = parseResult.adaptiveCard
        validateTopLevelProperties(everythingBagel)
        validateBody(everythingBagel)
        validateToplevelActions(everythingBagel)
        validateFallbackCard(everythingBagel)
    }
}
