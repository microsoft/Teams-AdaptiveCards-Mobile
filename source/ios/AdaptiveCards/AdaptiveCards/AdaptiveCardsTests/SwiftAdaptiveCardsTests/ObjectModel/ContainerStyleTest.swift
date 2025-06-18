//
//  ContainerStyleTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

class ContainerStyleTests: XCTestCase {

    func testCanCheckParentalContainerStyle() throws {
        let testJsonString = """
        {
            "type": "AdaptiveCard",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Test"
                        }
                    ]
                }
            ],
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.2"
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard let container = card.body.first as? SwiftContainer else {
            XCTFail("Failed to parse AdaptiveCard or Container")
            return
        }
        XCTAssertEqual(container.style, SwiftContainerStyle.emphasis)
    }

    func testHaveValidPaddingFlagSet() throws {
        let testJsonString = """
        {
            "type": "AdaptiveCard",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        {
                            "type": "Container",
                            "style": "default"
                        }
                    ]
                }
            ],
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.2"
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard let parentContainer = card.body.first as? SwiftContainer,
              let childContainer = parentContainer.items.last as? SwiftContainer else {
            XCTFail("Failed to parse parent or child container")
            return
        }
        // When the child container’s style differs from its parent, it should have padding.
        XCTAssertTrue(childContainer.padding)
    }

    func testColumnContainerStyle() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "No Style"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "style": "default",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Default Style"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "style": "emphasis",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Emphasis Style"
                                },
                                {
                                    "type": "Container",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Container no style"
                                        }
                                    ]
                                },
                                {
                                    "type": "Container",
                                    "style": "default",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Container default style"
                                        }
                                    ]
                                },
                                {
                                    "type": "Container",
                                    "style": "emphasis",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Container emphasis style"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard let columnSet = card.body.first as? SwiftColumnSet else {
            XCTFail("Failed to parse ColumnSet")
            return
        }
        let columns = columnSet.columns
        guard columns.count >= 3,
              let column1 = columns[0] as? SwiftColumn,
              let column2 = columns[2] as? SwiftColumn else {
            XCTFail("Expected three columns")
            return
        }
        XCTAssertEqual(column1.style, SwiftContainerStyle.none)
        XCTAssertEqual(column2.style, SwiftContainerStyle.emphasis)
        
        let items = column2.items
        guard items.count >= 4,
              let container1 = items[1] as? SwiftContainer,
              let container2 = items[2] as? SwiftContainer,
              let container3 = items[3] as? SwiftContainer else {
            XCTFail("Expected containers in the third column")
            return
        }
        XCTAssertEqual(container1.style, SwiftContainerStyle.none)
        XCTAssertFalse(container1.padding)
        
        XCTAssertEqual(container2.style, SwiftContainerStyle.`default`)
        XCTAssertTrue(container2.padding)
        
        XCTAssertEqual(container3.style, SwiftContainerStyle.emphasis)
        XCTAssertFalse(container3.padding)
    }

    func testCanParseBleedProperty() throws {
        let jsonStrings = [
            """
            {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "Container",
                        "style": "emphasis",
                        "bleed": true,
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Test"
                            }
                        ]
                    }
                ],
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "version": "1.2"
            }
            """,
            """
            {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "Container",
                        "style": "emphasis",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Test"
                            }
                        ]
                    }
                ],
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "version": "1.2"
            }
            """
        ]
        var containers: [SwiftContainer] = []
        for json in jsonStrings {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.2")
            let card = parseResult.adaptiveCard
            guard let container = card.body.first as? SwiftContainer else {
                XCTFail("Failed to parse container")
                continue
            }
            containers.append(container)
        }
        // Use 'canBleed' instead of 'bleed'
        XCTAssertTrue(containers[0].canBleed)
        XCTAssertFalse(containers[1].canBleed)
    }

    func testCanSerializeBleedProperty() throws {
        let jsonStrings = [
            """
            {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "Container",
                        "style": "Emphasis",
                        "bleed": true,
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Test"
                            }
                        ]
                    }
                ],
                "actions": [
                    {
                        "type": "Alert",
                        "title": "Submit",
                        "data": {
                            "id": "1234567890"
                        }
                    }],
                "version": "1.2"
            }
            """,
            """
            {
                "type": "AdaptiveCard",
                "body": [
                    {
                        "type": "Container",
                        "style": "Emphasis",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "Test"
                            }
                        ]
                    }
                ],
                "actions": [
                    {
                        "type": "Alert",
                        "title": "Submit",
                        "data": {
                            "id": "1234567890"
                        }
                    }],
                "version": "1.2"
            }
            """
        ]
        for json in jsonStrings {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.2")
            let expectedValue = SwiftParseUtil.getJsonValue(from: json)
            let expectedString = try SwiftParseUtil.jsonToString(expectedValue)
            let card = parseResult.adaptiveCard
            let serializedCard = try card.serializeToJsonValue()
            let serializedCardAsString = try SwiftParseUtil.jsonToString(serializedCard)
            XCTAssertEqual(expectedString, serializedCardAsString)
            // Removing direct dictionary comparison since [String: Any] is not Equatable.
            // XCTAssertEqual(expectedValue, serializedCard)
        }
    }

    func testBleedPropertyConveysCorrectInformation() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ColumnSet",
                    "id": "0",
                    "columns": [
                        {
                            "type": "Column",
                            "id": "1",
                            "style": "emphasis",
                            "items": [
                                {
                                    "type": "Container",
                                    "id": "2",
                                    "style": "default",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "id": "3",
                                            "text": "Container default style"
                                        },
                                        {
                                            "type": "Container",
                                            "id": "4",
                                            "style": "default",
                                            "items": [
                                                {
                                                    "type": "Container",
                                                    "id": "5",
                                                    "style": "emphasis",
                                                    "bleed": true,
                                                    "items": [
                                                        {
                                                            "id": "6",
                                                            "type": "TextBlock",
                                                            "text": "Container Emphasis style"
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard let columnSet = card.body.first as? SwiftColumnSet,
              let column1 = columnSet.columns.first as? SwiftColumn else {
            XCTFail("Failed to parse required elements")
            return
        }
        XCTAssertEqual(column1.style, SwiftContainerStyle.emphasis)
        
        guard let container1 = column1.items.last as? SwiftContainer else {
            XCTFail("Container1 not found")
            return
        }
        XCTAssertEqual(container1.style, SwiftContainerStyle.`default`)
        XCTAssertFalse(container1.canBleed)
        
        guard let container2 = container1.items.last as? SwiftContainer else {
            XCTFail("Container2 not found")
            return
        }
        XCTAssertEqual(container2.id, "4")
        XCTAssertEqual(container2.style, SwiftContainerStyle.`default`)
        XCTAssertFalse(container2.canBleed)
        
        guard let container3 = container2.items.last as? SwiftContainer else {
            XCTFail("Container3 not found")
            return
        }
        XCTAssertEqual(container3.id, "5")
        XCTAssertEqual(container3.style, SwiftContainerStyle.emphasis)
        XCTAssertTrue(container3.canBleed)
        // Verify that container3 reports container1’s internal id as its parental id.
        XCTAssertEqual(container1.internalId, container3.parentalId)
    }

    func testBleedPropertyColumnSet() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.2",
            "body": [
                {
                    "type": "ColumnSet",
                    "style": "emphasis",
                    "bleed": true,
                    "columns": [
                        {
                            "type": "Column",
                            "width": "stretch",
                            "style": "default",
                            "bleed": true,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Dis is a textblock",
                                    "wrap": true
                                },
                                {
                                    "type": "Container",
                                    "style": "emphasis",
                                    "bleed": true,
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Dis is a textblock"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "stretch",
                            "style": "default",
                            "bleed": true,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Dis is a textblock",
                                    "wrap": true
                                },
                                {
                                    "type": "Container",
                                    "style": "emphasis",
                                    "bleed": true,
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Dis is a textblock"
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "stretch",
                            "style": "default",
                            "bleed": true,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Dis is a textblock",
                                    "wrap": true
                                },
                                {
                                    "type": "Container",
                                    "style": "emphasis",
                                    "bleed": true,
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Dis is a textblock"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ],
            "actions": [ ]
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard let columnSet = card.body.first as? SwiftColumnSet else {
            XCTFail("Failed to parse ColumnSet")
            return
        }
        XCTAssertEqual(columnSet.style, SwiftContainerStyle.emphasis)
        
        let columns = columnSet.columns
        guard columns.count >= 3,
              let column1 = columns[0] as? SwiftColumn,
              let column2 = columns[1] as? SwiftColumn,
              let column3 = columns[2] as? SwiftColumn else {
            XCTFail("Not enough columns")
            return
        }
        
        XCTAssertEqual(column1.style, SwiftContainerStyle.`default`)
        let expectedDirectionColumn1: SwiftContainerBleedDirection = [.bleedDown, .bleedLeft, .bleedUp]
        XCTAssertEqual(column1.bleedDirection, expectedDirectionColumn1)
        
        guard let container = column1.items.last as? SwiftContainer else {
            XCTFail("Container in column1 not found")
            return
        }
        let expectedDirectionContainer: SwiftContainerBleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
        XCTAssertEqual(container.bleedDirection, expectedDirectionContainer)
        XCTAssertEqual(column1.internalId, container.parentalId)
        
        XCTAssertEqual(column2.style, SwiftContainerStyle.`default`)
        XCTAssertTrue(column2.padding)
        let expectedDirectionColumn2: SwiftContainerBleedDirection = [.bleedDown, .bleedUp]
        XCTAssertEqual(column2.bleedDirection, expectedDirectionColumn2)
        guard let container2 = column2.items.last as? SwiftContainer else {
            XCTFail("Container in column2 not found")
            return
        }
        let expectedDirectionContainer2: SwiftContainerBleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
        XCTAssertEqual(container2.bleedDirection, expectedDirectionContainer2)
        
        XCTAssertEqual(column3.style, SwiftContainerStyle.`default`)
        let expectedDirectionColumn3: SwiftContainerBleedDirection = [.bleedDown, .bleedRight, .bleedUp]
        XCTAssertEqual(column3.bleedDirection, expectedDirectionColumn3)
        guard let container3 = column3.items.last as? SwiftContainer else {
            XCTFail("Container in column3 not found")
            return
        }
        let expectedDirectionContainer3: SwiftContainerBleedDirection = [.bleedDown, .bleedRight, .bleedLeft]
        XCTAssertEqual(container3.bleedDirection, expectedDirectionContainer3)
        XCTAssertEqual(column3.internalId, container3.parentalId)
    }
    
    func testBleedSequentialColumnSets() throws {
        let testJsonString = """
        {
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "style": "good",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 1"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "style": "attention",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 2"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "style": "warning",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 3"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "style": "good",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 1"
                                }
                            ],
                            "bleed": true
                        },
                        {
                            "type": "Column",
                            "style": "attention",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 2"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "style": "warning",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 3"
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        let card = parseResult.adaptiveCard
        guard card.body.count >= 2,
              let secondColumnSet = card.body[1] as? SwiftColumnSet,
              let firstColumn = secondColumnSet.columns.first as? SwiftColumn else {
            XCTFail("Failed to parse second ColumnSet or its first column")
            return
        }
        XCTAssertTrue(firstColumn.canBleed)
        let expectedDirection: SwiftContainerBleedDirection = [.bleedDown, .bleedLeft]
        XCTAssertEqual(firstColumn.bleedDirection, expectedDirection)
    }
}
