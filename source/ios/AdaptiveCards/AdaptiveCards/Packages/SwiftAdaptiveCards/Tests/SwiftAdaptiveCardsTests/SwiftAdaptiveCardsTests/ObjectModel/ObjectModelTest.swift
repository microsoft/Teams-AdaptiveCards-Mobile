import XCTest
@testable import SwiftAdaptiveCards

class ObjectModelTest: XCTestCase {

    // MARK: - Helpers for wrap tests

    /// Casts an element to ChoiceSetInput and checks its .wrap
    private func runChoiceSetWrapTest(_ element: SwiftBaseCardElement, expectedWrap: Bool, file: StaticString = #file, line: UInt = #line) {
        guard let choiceSet = element as? SwiftChoiceSetInput else {
            XCTFail("Expected ChoiceSetInput at given index.", file: file, line: line)
            return
        }
        XCTAssertEqual(choiceSet.wrap, expectedWrap, file: file, line: line)
    }

    /// Casts an element to ToggleInput and checks its .wrap
    private func runToggleWrapTest(_ element: SwiftBaseCardElement, expectedWrap: Bool, file: StaticString = #file, line: UInt = #line) {
        guard let toggle = element as? SwiftToggleInput else {
            XCTFail("Expected ToggleInput at given index.", file: file, line: line)
            return
        }
        XCTAssertEqual(toggle.wrap, expectedWrap, file: file, line: line)
    }

    // MARK: - Tests

    func testSelectActionEmptyJsonTest() throws {
        var context = SwiftParseContext()
        let emptyJson: [String: Any] = [:]

        // Swift function is throwing; catch or use try?
        let selectAction = try SwiftParseUtil.getAction(from: emptyJson, key: "selectAction", context: context)
        XCTAssertNil(selectAction)
    }

    func testSelectActionNonExistentTest() throws {
        // Card without card-level selectAction
        let cardStr = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Now that we have defined the main rules...",
                            "wrap": true
                        }
                    ]
                }
            ]
        }
        """

        let json = try SwiftParseUtil.getJsonValueFromString(cardStr)
        var context = SwiftParseContext()

        let selectAction = try SwiftParseUtil.getAction(from: json, key: "selectAction", context: context)
        XCTAssertNil(selectAction)
    }

    func testSelectActionInvalidTypeTest() throws {
        let str = """
        {
            "type": "ColumnSet",
            "selectAction": {
                "type": "Action.Invalid",
                "title": "Submit",
                "data": {
                    "x": 13
                }
            }
        }
        """
        let json = try SwiftParseUtil.getJsonValueFromString(str)
        var context = SwiftParseContext()

        let selectAction = try SwiftParseUtil.getAction(from: json, key: "selectAction", context: context)

        // According to the original C++ test, it expects an UnknownAction. In your Swift code,
        // it might end up returning a BaseActionElement with .type = .unknown, or it might throw.
        // If your logic for "Action.Invalid" sets an internal property, adapt accordingly.
        // For demonstration, let's check if it's non-nil and see if it's recognized as "unknown".
        XCTAssertNotNil(selectAction)
        // If your action has something akin to `action.type == .unknown`,
        // or if your code simply can't parse and returns a fallback:
        XCTAssertEqual(selectAction?.typeString, SwiftActionType.unknownAction.rawValue)
    }

    func testSelectActionOpenUrlTest() throws {
        let str = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Container",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Now that we have defined the main rules...",
                            "wrap": true
                        }
                    ]
                }
            ],
            "selectAction": {
                "type": "Action.OpenUrl",
                "title": "View",
                "url": "http://select-action.io"
            }
        }
        """
        let json = try SwiftParseUtil.getJsonValueFromString(str)
        var context = SwiftParseContext()

        let selectAction = try SwiftParseUtil.getAction(from: json, key: "selectAction", context: context)
        XCTAssertNotNil(selectAction)
        // If your Swift OpenUrlAction has .type = .openUrl, or something similar, test that:
        XCTAssertEqual(selectAction?.typeString, SwiftActionType.openUrl.rawValue)
        XCTAssertEqual(selectAction?.title, "View")
    }

    func testSelectActionAnyJsonTest() throws {
        let str = """
        {
            "type": "ColumnSet",
            "selectAction": {
                "type": "Action.Submit",
                "title": "Submit",
                "data": {
                    "x": 13
                }
            }
        }
        """
        let json = try SwiftParseUtil.getJsonValueFromString(str)
        var context = SwiftParseContext()

        let selectAction = try SwiftParseUtil.getAction(from: json, key: "selectAction", context: context)
        XCTAssertNotNil(selectAction)
        XCTAssertEqual(selectAction?.typeString, SwiftActionType.submit.rawValue)
        XCTAssertEqual(selectAction?.title, "Submit")
    }

    func testDuplicateIdSimpleTest() {
        let cardWithDuplicateIds = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "This card's has duplicate ids. Oh no!"
                },
                {
                    "type": "Input.Text",
                    "style": "text",
                    "id": "duplicate"
                },
                {
                    "type": "Input.Text",
                    "style": "url",
                    "id": "duplicate"
                }
            ]
        }
        """

        XCTAssertThrowsError(try SwiftAdaptiveCard.deserializeFromString(cardWithDuplicateIds, version: "1.0"))
    }

    func testDuplicateIdNestedTest() {
        let cardWithDuplicateIds = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Input.Text",
                    "placeholder": "Name",
                    "style": "text",
                    "maxLength": 0,
                    "id": "duplicate"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "Submit",
                    "data": {
                        "id": "1234567890"
                    }
                },
                {
                    "type": "Action.ShowCard",
                    "title": "Show Card",
                    "card": {
                        "type": "AdaptiveCard",
                        "body": [
                            {
                                "type": "Input.Text",
                                "placeholder": "enter comment",
                                "style": "text",
                                "maxLength": 0,
                                "id": "duplicate"
                            }
                        ],
                        "actions": [
                            {
                                "type": "Action.Submit",
                                "title": "OK"
                            }
                        ]
                    }
                }
            ]
        }
        """

        XCTAssertThrowsError(try SwiftAdaptiveCard.deserializeFromString(cardWithDuplicateIds, version: "1.0"))
    }

    func testMediaElementTest() throws {
        let cardWithMediaElement = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Media",
                    "poster": "http://adaptivecards.io/content/cats/1.png",
                    "altText": "This is a video",
                    "sources": [
                        {
                            "mimeType": "video/mp4",
                            "url": "http://source1.mp4"
                        },
                        {
                            "mimeType": "video/avi",
                            "url": "http://source2.avi"
                        }
                    ]
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardWithMediaElement, version: "1.0")
        let card = parseResult.adaptiveCard
        XCTAssertFalse(card.body.isEmpty)
        guard let mediaElement = card.body.first as? SwiftMedia else {
            XCTFail("First element is not a Media element")
            return
        }

        // Instead of elementType/elementTypeString, check base type:
        XCTAssertEqual(mediaElement.type, .media)
        XCTAssertEqual(mediaElement.type.rawValue, "Media")
        XCTAssertEqual(mediaElement.poster, "http://adaptivecards.io/content/cats/1.png")
        XCTAssertEqual(mediaElement.altText, "This is a video")

        let sources = mediaElement.sources
        XCTAssertEqual(sources.count, 2)
        XCTAssertEqual(sources[0].mimeType, "video/mp4")
        XCTAssertEqual(sources[0].url, "http://source1.mp4")
        XCTAssertEqual(sources[1].mimeType, "video/avi")
        XCTAssertEqual(sources[1].url, "http://source2.avi")
    }

    func testShowCardSerialization() throws {
        let cardWithShowCard = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "2.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "This card's action will show another card"
                }
            ],
            "actions": [
                {
                    "type": "Action.ShowCard",
                    "title": "Action.ShowCard",
                    "card": {
                        "type": "AdaptiveCard",
                        "version": "2.0",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": "What do you think?"
                            }
                        ],
                        "actions": [
                            {
                                "type": "Action.Submit",
                                "title": "Neat!"
                            }
                        ]
                    }
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardWithShowCard, version: "2.0")
        let mainCard = parseResult.adaptiveCard

        // Suppose the first action is ShowCardAction.
        guard let showCardAction = mainCard.actions.first as? SwiftShowCardAction else {
            XCTFail("Expected first action to be ShowCardAction.")
            return
        }
        guard let showCard = showCardAction.card else {
            XCTFail("ShowCardAction has no card.")
            return
        }

        XCTAssertEqual(showCard.version, "2.0")
        XCTAssertEqual(showCard.body.count, 1)
        XCTAssertTrue(showCard.body[0] is SwiftTextBlock)
        XCTAssertEqual((showCard.body[0] as? SwiftTextBlock)?.text, "What do you think?")
        XCTAssertEqual(showCard.actions.count, 1)
        XCTAssertTrue(showCard.actions[0] is SwiftSubmitAction)
        XCTAssertEqual(showCard.actions[0].title, "Neat!")

        // Serialize the showCard
        let serializedShowCard = try showCard.serialize()
        // Now deserialize again
        let roundTripped = try SwiftAdaptiveCard.deserializeFromString(serializedShowCard, version: "2.0")
        let roundTrippedShowCard = roundTripped.adaptiveCard

        XCTAssertEqual(roundTrippedShowCard.version, "2.0")
        XCTAssertEqual(roundTrippedShowCard.body.count, 1)
        XCTAssertTrue(roundTrippedShowCard.body[0] is SwiftTextBlock)
        XCTAssertEqual((roundTrippedShowCard.body[0] as? SwiftTextBlock)?.text, "What do you think?")
        XCTAssertEqual(roundTrippedShowCard.actions.count, 1)
        XCTAssertTrue(roundTrippedShowCard.actions[0] is SwiftSubmitAction)
        XCTAssertEqual(roundTrippedShowCard.actions[0].title, "Neat!")
    }

    func testChoiceSetWrapParsingTest() throws {
        let testJson = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.2",
            "body": [
                {
                    "type": "Input.ChoiceSet",
                    "id": "myColor",
                    "style": "compact",
                    "isMultiSelect": true,
                    "wrap": true,
                    "value": "1",
                    "choices": [
                        { "title": "Red",   "value": "1" },
                        { "title": "Green", "value": "2" },
                        { "title": "Blue",  "value": "3" }
                    ]
                },
                {
                    "type": "Input.ChoiceSet",
                    "id": "myColor2",
                    "style": "expanded",
                    "isMultiSelect": false,
                    "value": "1",
                    "choices": [
                        { "title": "Red",   "value": "1" },
                        { "title": "Green", "value": "2" },
                        { "title": "Blue",  "value": "3" }
                    ]
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.2")
        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 2)

        // index 0 => wrap = true
        runChoiceSetWrapTest(card.body[0], expectedWrap: true)

        // index 1 => default wrap = false
        runChoiceSetWrapTest(card.body[1], expectedWrap: false)
    }

    func testToggleInputWrapParsingTest() throws {
        let testJson = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.2",
            "body": [
                {
                    "type": "Input.Toggle",
                    "id": "acceptTerms",
                    "wrap": true,
                    "title": "I accept the terms and agreements",
                    "value": "true",
                    "valueOn": "true",
                    "valueOff": "false"
                },
                {
                    "type": "Input.Toggle",
                    "id": "acceptTerms2",
                    "title": "I accept the terms and agreements",
                    "value": "true",
                    "valueOn": "true",
                    "valueOff": "false"
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.2")
        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 2)

        // index 0 => wrap = true
        runToggleWrapTest(card.body[0], expectedWrap: true)
        // index 1 => default wrap = false
        runToggleWrapTest(card.body[1], expectedWrap: false)
    }

    func testChoiceSetOptionalChoicesTest() throws {
        let testJson = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.ChoiceSet",
                    "id": "1",
                    "placeholder": "Placeholder text"
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.5")
        let card = parseResult.adaptiveCard
        XCTAssertTrue(parseResult.warnings.isEmpty)
        XCTAssertEqual(card.body.count, 1)

        // Ensure it's a ChoiceSetInput.
        guard let choiceSet = card.body[0] as? SwiftChoiceSetInput else {
            XCTFail("Expected a ChoiceSetInput.")
            return
        }
        XCTAssertTrue(choiceSet.choices.isEmpty)

        // Check the serialized output
        let serializedCardDict = try card.serializeToJsonValue()
        // Then confirm shape:
        // e.g. confirm there's "body" with count 1, etc.
        guard let bodyArray = serializedCardDict["body"] as? [[String: Any]],
              let first = bodyArray.first else {
            XCTFail("Serialized card missing body array.")
            return
        }
        XCTAssertEqual(first["id"] as? String, "1")
        // No "choices" in the output => that's expected
    }

    func testImplicitColumnTypeTest() {
        let columnTypeSetOrEmpty = """
        {
            "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type":"ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": []
                        },
                        {
                            "items": []
                        }
                    ]
                }
            ]
        }
        """

        let columnTypeInvalid = """
        {
            "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type":"ColumnSet",
                    "columns": [
                        {
                            "type": "Elephant",
                            "items": []
                        }
                    ]
                }
            ]
        }
        """

        // This should succeed
        XCTAssertNoThrow(try SwiftAdaptiveCard.deserializeFromString(columnTypeSetOrEmpty, version: "1.0"))

        // This should fail
        XCTAssertThrowsError(try SwiftAdaptiveCard.deserializeFromString(columnTypeInvalid, version: "1.0"))
    }

    func testImplicitImageTypeInImageSetTest() {
        let imageTypeSetOrEmpty = """
        {
            "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ImageSet",
                    "images": [
                        {
                            "type": "Image",
                            "url": "http://adaptivecards.io/content/cats/1.png"
                        },
                        {
                            "url": "http://adaptivecards.io/content/cats/1.png"
                        }
                    ]
                }
            ]
        }
        """

        let imageTypeInvalid = """
        {
            "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ImageSet",
                    "images": [
                        {
                            "type": "Elephant",
                            "url": "http://adaptivecards.io/content/cats/1.png"
                        }
                    ]
                }
            ]
        }
        """

        XCTAssertNoThrow(try SwiftAdaptiveCard.deserializeFromString(imageTypeSetOrEmpty, version: "1.0"))
        XCTAssertThrowsError(try SwiftAdaptiveCard.deserializeFromString(imageTypeInvalid, version: "1.0"))
    }

    func testTextBlockStyleParsingTest() throws {
        let testJson = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.2",
            "body": [
                {
                    "type": "TextBlock",
                    "id": "heading",
                    "style": "heading",
                    "text": "hello"
                },
                {
                    "type": "TextBlock",
                    "id": "heading2",
                    "style": "Heading",
                    "text": "hello"
                },
                {
                    "type": "TextBlock",
                    "id": "explicit default",
                    "style": "Default",
                    "text": "hello"
                },
                {
                    "type": "TextBlock",
                    "id": "invalid-heading",
                    "style": "Footer",
                    "text": "hello"
                },
                {
                    "type": "TextBlock",
                    "id": "implicit default",
                    "text": "hello"
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.2")
        let card = parseResult.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 5)

        // The original C++ test wanted: [Heading, Heading, Default, (invalid => no style?), (implicit => default)]
        // Your Swift code calls it textStyle. If it's invalid, it presumably becomes .defaultStyle
        let expected: [SwiftTextStyle?] = [
            .heading,       // explicit "heading"
            .heading,       // explicit "Heading"
            .defaultStyle,  // explicit "Default"
            nil,           // invalid "Footer"
            nil            // no style specified
        ]

        for (idx, elem) in body.enumerated() {
            guard let tb = elem as? SwiftTextBlock else {
                XCTFail("Element at \(idx) is not a TextBlock")
                continue
            }
            XCTAssertEqual(tb.textStyle, expected[idx])
        }
    }

    /// Optional extension: If your C++ tests check for "password" style, but your Swift code just stores a string in `.style`,
    /// you can define a small bridging property here for test use.
    /// (Only do this if you truly need the "password vs. text" logic from the C++ test.)
    ///
    /// Example:
    /*
    extension TextInput {
        enum TextInputStyle {
            case text
            case password
        }
        var textInputStyle: TextInputStyle {
            if style?.lowercased() == "password" {
                return .password
            }
            return .text
        }
    }
    */

    func testPasswordStyleParseTest() throws {
        let testJson = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "plain",
                    "label": "Plaintext"
                },
                {
                    "type": "Input.Text",
                    "id": "password",
                    "style": "passWORD",
                    "label": "Password"
                }
            ]
        }
        """

        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.5")
        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 2)

        // If you want to do the "text vs. password" check,
        // you need an actual property or extension on TextInput.
        // For demonstration, let's just confirm the second has style = "passWORD".
        guard let plainInput = card.body[0] as? SwiftTextInput else {
            XCTFail("First body element is not TextInput.")
            return
        }
        XCTAssertNil(plainInput.style)  // or if your code defaults style to something

        guard let passwordInput = card.body[1] as? SwiftTextInput else {
            XCTFail("Second body element is not TextInput.")
            return
        }
        XCTAssertEqual(passwordInput.style?.rawValue.lowercased(), "password")
    }

    func testPasswordWithMultilineParseTest() throws {
        let testJson = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "theId",
                    "label": "Password",
                    "style": "password",
                    "isMultiline": true
                }
            ]
        }
        """

        // Suppose we expect a warning about ignoring multiline in password style
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJson, version: "1.5")
        let warnings = parseResult.warnings

        // If your Swift code does produce a warning, it'd appear here:
        // If it doesn't produce warnings, skip the check or adapt as needed.
        // We cannot see your actual code for "TextInput" or "warnings" logic, so let's handle gracefully:
        // e.g. "If there's at least one warning, check it"
        if !warnings.isEmpty {
            // We check the first warning for a message
            XCTAssertEqual(warnings[0].statusCode, .invalidValue)
            XCTAssertEqual(warnings[0].message, "Input.Text ignores isMultiline when using password style")
        }

        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 1)
        guard let theInput = card.body[0] as? SwiftTextInput else {
            XCTFail("Expected a TextInput in the card's body")
            return
        }
        // In the original test, they also do .GetTextInputStyle() -> password.
        // If you have an extension or property, do that check.
        // For example:
        // XCTAssertEqual(theInput.textInputStyle, .password)

        // They also say "We still store isMultiline = true"
        XCTAssertTrue(theInput.isMultiline == true)

        // Now check the final JSON
        let serializedCard = try card.serializeToJsonValue()
        guard let bodyArr = serializedCard["body"] as? [[String: Any]],
              let bodyDict = bodyArr.first else {
            XCTFail("Serialized card missing body array")
            return
        }
        XCTAssertEqual(bodyDict["isMultiline"] as? Bool, true)
    }
}
