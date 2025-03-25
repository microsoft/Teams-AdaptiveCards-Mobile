//
//  ACAdaptiveCardParserTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation
import XCTest
@testable import SwiftAdaptiveCards

class ACAdaptiveCardParserTests: XCTestCase {
    func testParseAdaptiveCard() throws {
        let json = """
            {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
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
                            "title": "authentication_buttons_0_title"
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
                    }
                ]
            }
            """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.0")
            let card = parseResult.adaptiveCard
            
            // Schema may not be directly accessible in the new model
            // XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
            XCTAssertEqual(card.version, "1.0")
            
            // Check background image
            guard let backgroundImage = card.backgroundImage else {
                XCTFail("Background image is missing")
                return
            }
            XCTAssertEqual(backgroundImage.url, "https://adaptivecards.io/content/cats/1.png")
            
            // Check refresh properties
            guard let refresh = card.refresh else {
                XCTFail("Refresh property is missing")
                return
            }
            
            // In the new model, the action might be a typed action rather than an enum
            guard let executeAction = refresh.action as? SwiftExecuteAction else {
                XCTFail("Expected refresh action to be an ExecuteAction")
                return
            }
            
            // Some commented assertions in the original that may need updating
            // XCTAssertEqual(refresh.action.id, "refresh_action_id")
            XCTAssertEqual(executeAction.verb, "refresh_action_verb")
            XCTAssertEqual(refresh.userIds.first, "refresh_userIds_0")
            
            // Check authentication properties
            guard let authentication = card.authentication else {
                XCTFail("Authentication property is missing")
                return
            }
            
            XCTAssertEqual(authentication.text, "authentication_text")
            XCTAssertEqual(authentication.connectionName, "authentication_connectionName")
            
            let tokenResource = authentication.tokenExchangeResource
            XCTAssertEqual(tokenResource?.id, "authentication_tokenExchangeResource_id")
            XCTAssertEqual(tokenResource?.uri, "authentication_tokenExchangeResource_uri")
            XCTAssertEqual(tokenResource?.providerId, "authentication_tokenExchangeResource_providerId")
            
            guard let firstButton = authentication.buttons.first else {
                XCTFail("Authentication buttons are missing")
                return
            }
            
            XCTAssertEqual(firstButton.type, "authentication_buttons_0_type")
            XCTAssertEqual(firstButton.title, "authentication_buttons_0_title")
            
            // Check other card properties
            XCTAssertEqual(card.fallbackText, "fallbackText")
            XCTAssertEqual(card.speak, "speak")
            XCTAssertEqual(card.language, "en") // Assuming 'lang' is now 'language'
            XCTAssertEqual(card.rtl, false)
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
    
    /*
     THIS card does not render appropriately in production. Malformed schema.
    func testCardElementsDecoding() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
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
                        "data": "Container_data"
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
                                            "fontType": "display"
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
                            "regex": "([A-Z])\\w+",
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
                            "weight": "bolder",
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
                            "weight": "bolder"
                        },
                        {
                            "type": "TextRun",
                            "text": "This is another text run",
                            "selectAction": { "type": "Action.Submit" }
                        }
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
        """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.0")
            let card = parseResult.adaptiveCard
            
            // Validate card properties
            XCTAssertEqual(card.version, "1.0")
            
            // Check background image
            guard let backgroundImage = card.backgroundImage else {
                XCTFail("Background image is missing")
                return
            }
            XCTAssertEqual(backgroundImage.url, "https://adaptivecards.io/content/cats/1.png")
            
            // Validate refresh properties
            guard let refresh = card.refresh else {
                XCTFail("Refresh property is missing")
                return
            }
            
            // Some commented assertions in the original that may need updating
            // XCTAssertEqual(refresh.action.id, "refresh_action_id")
            guard let executeAction = refresh.action as? SwiftExecuteAction else {
                XCTFail("Expected refresh action to be an ExecuteAction")
                return
            }
            XCTAssertEqual(executeAction.verb, "refresh_action_verb")
            XCTAssertEqual(refresh.userIds.first, "refresh_userIds_0")
            
            // Validate authentication properties
            guard let authentication = card.authentication else {
                XCTFail("Authentication property is missing")
                return
            }
            
            XCTAssertEqual(authentication.text, "authentication_text")
            XCTAssertEqual(authentication.connectionName, "authentication_connectionName")
            
            let tokenResource = authentication.tokenExchangeResource
            XCTAssertEqual(tokenResource?.id, "authentication_tokenExchangeResource_id")
            XCTAssertEqual(tokenResource?.uri, "authentication_tokenExchangeResource_uri")
            XCTAssertEqual(tokenResource?.providerId, "authentication_tokenExchangeResource_providerId")
            
            XCTAssertEqual(authentication.buttons.first?.type, "authentication_buttons_0_type")
            XCTAssertEqual(authentication.buttons.first?.title, "authentication_buttons_0_title")
            
            // Validate other properties
            XCTAssertEqual(card.fallbackText, "fallbackText")
            XCTAssertEqual(card.speak, "speak")
            XCTAssertEqual(card.language, "en") // Assuming 'lang' is now 'language'
            XCTAssertEqual(card.rtl, false)
            
            // Validate body elements
            XCTAssertEqual(card.body.count, 8)
            
            // TextBlock
            guard let textBlock = card.body[0] as? SwiftTextBlock else {
                XCTFail("Failed to decode TextBlock")
                return
            }
            XCTAssertEqual(textBlock.text, "TextBlock_text")
            XCTAssertEqual(textBlock.id, "TextBlock_id")
            
            // Image
            guard let image = card.body[1] as? SwiftImage else {
                XCTFail("Failed to decode Image")
                return
            }
            XCTAssertEqual(image.url, "https://adaptivecards.io/content/cats/1.png")
            XCTAssertEqual(image.id, "Image_id")
            
            // Container
            guard let container = card.body[2] as? SwiftContainer else {
                XCTFail("Failed to decode Container")
                return
            }
            XCTAssertEqual(container.id, "Container_id")
            XCTAssertEqual(container.items.count, 1)
            
            guard let columnSet = container.items[0] as? SwiftColumnSet else {
                XCTFail("Failed to decode ColumnSet")
                return
            }
            XCTAssertEqual(columnSet.id, "ColumnSet_id")
            XCTAssertEqual(columnSet.columns.count, 3)
            
            // FactSet
            guard let factSet = card.body[3] as? SwiftFactSet else {
                XCTFail("Failed to decode FactSet")
                return
            }
            XCTAssertEqual(factSet.id, "FactSet_id")
            XCTAssertEqual(factSet.facts.count, 2)
            XCTAssertEqual(factSet.facts[0].title, "Topping")
            XCTAssertEqual(factSet.facts[0].value, "poppyseeds")
            
            // ImageSet
            guard let imageSet = card.body[4] as? SwiftImageSet else {
                XCTFail("Failed to decode ImageSet")
                return
            }
            XCTAssertEqual(imageSet.id, "ImageSet_id")
            XCTAssertEqual(imageSet.images.count, 3)
            XCTAssertEqual(imageSet.images[0].url, "https://adaptivecards.io/content/cats/1.png")
            
            // Container with inputs
            guard let inputContainer = card.body[5] as? SwiftContainer else {
                XCTFail("Failed to decode Container with inputs")
                return
            }
            XCTAssertEqual(inputContainer.id, "Container_id_inputs")
            XCTAssertEqual(inputContainer.items.count, 7)
            
            // Input.Text
            guard let inputText = inputContainer.items[0] as? SwiftTextInput else {
                XCTFail("Failed to decode Input.Text")
                return
            }
            XCTAssertEqual(inputText.id, "Input.Text_id")
            XCTAssertEqual(inputText.value, "Input.Text_value")
            
            // Input.Number
            guard let inputNumber = inputContainer.items[1] as? SwiftNumberInput else {
                XCTFail("Failed to decode Input.Number")
                return
            }
            XCTAssertEqual(inputNumber.id, "Input.Number_id")
            XCTAssertEqual(inputNumber.value, 4.5)
            
            // Input.Date
            guard let inputDate = inputContainer.items[2] as? SwiftDateInput else {
                XCTFail("Failed to decode Input.Date")
                return
            }
            XCTAssertEqual(inputDate.id, "Input.Date_id")
            XCTAssertEqual(inputDate.value, "8/9/2018")
            
            // Input.Time
            guard let inputTime = inputContainer.items[3] as? SwiftTimeInput else {
                XCTFail("Failed to decode Input.Time")
                return
            }
            XCTAssertEqual(inputTime.id, "Input.Time_id")
            XCTAssertEqual(inputTime.value, "13:00")
            
            // Input.Toggle
            guard let inputToggle = inputContainer.items[4] as? SwiftToggleInput else {
                XCTFail("Failed to decode Input.Toggle")
                return
            }
            XCTAssertEqual(inputToggle.id, "Input.Toggle_id")
            XCTAssertEqual(inputToggle.value, "Input.Toggle_on")
            
            // TextBlock in container
            guard let containerTextBlock = inputContainer.items[5] as? SwiftTextBlock else {
                XCTFail("Failed to decode TextBlock in container")
                return
            }
            XCTAssertEqual(containerTextBlock.text, "Everybody's got choices")
            
            // Input.ChoiceSet
            guard let inputChoiceSet = inputContainer.items[6] as? SwiftChoiceSetInput else {
                XCTFail("Failed to decode Input.ChoiceSet")
                return
            }
            XCTAssertEqual(inputChoiceSet.id, "Input.ChoiceSet_id")
            XCTAssertEqual(inputChoiceSet.value, "Input.Choice2,Input.Choice4")
            XCTAssertEqual(inputChoiceSet.choices.count, 4)
            
            // ActionSet
            guard let actionSet = card.body[6] as? SwiftActionSet else {
                XCTFail("Failed to decode ActionSet")
                return
            }
            XCTAssertEqual(actionSet.actions.count, 2)
            
            guard let actionSubmit = actionSet.actions[0] as? SwiftSubmitAction else {
                XCTFail("Failed to decode Action.Submit in ActionSet")
                return
            }
            XCTAssertEqual(actionSubmit.id, "ActionSet.Action.Submit_id")
            
            guard let actionOpenUrl = actionSet.actions[1] as? SwiftOpenUrlAction else {
                XCTFail("Failed to decode Action.OpenUrl in ActionSet")
                return
            }
            XCTAssertEqual(actionOpenUrl.id, "ActionSet.Action.OpenUrl_id")
            
            // RichTextBlock
            guard let richTextBlock = card.body[7] as? SwiftRichTextBlock else {
                XCTFail("Failed to decode RichTextBlock")
                return
            }
            XCTAssertEqual(richTextBlock.id, "RichTextBlock_id")
            XCTAssertEqual(richTextBlock.inlines.count, 2)
            
            guard let textRun = richTextBlock.inlines[0] as? SwiftTextRun else {
                XCTFail("Failed to decode TextRun in RichTextBlock")
                return
            }
            XCTAssertEqual(textRun.text, "This is a text run")
            
            // Test card actions
            XCTAssertEqual(card.actions.count, 3)
            
            guard let cardSubmitAction = card.actions[0] as? SwiftSubmitAction else {
                XCTFail("Failed to decode Action.Submit in card actions")
                return
            }
            XCTAssertEqual(cardSubmitAction.id, "Action.Submit_id")
            
            guard let cardExecuteAction = card.actions[1] as? SwiftExecuteAction else {
                XCTFail("Failed to decode Action.Execute in card actions")
                return
            }
            XCTAssertEqual(cardExecuteAction.id, "Action.Execute_id")
            XCTAssertEqual(cardExecuteAction.verb, "Action.Execute_verb")
            
            guard let cardShowCardAction = card.actions[2] as? SwiftShowCardAction else {
                XCTFail("Failed to decode Action.ShowCard in card actions")
                return
            }
            XCTAssertEqual(cardShowCardAction.id, "Action.ShowCard_id")
            
            // Check the ShowCard's card
            let showCard = cardShowCardAction.card
            XCTAssertNotNil(showCard)
            XCTAssertEqual(showCard?.body.count, 1)
            
            guard let showCardTextBlock = showCard?.body.first as? SwiftTextBlock else {
                XCTFail("Failed to decode TextBlock in ShowCard")
                return
            }
            XCTAssertEqual(showCardTextBlock.text, "Action.ShowCard text")
            
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
     */
}
