import XCTest
@testable import SwiftAdaptiveCards  // Change to your module name

/// Helper function for a basic enum test.
func assertEnumConversion<T: Equatable>(
    toString: (T) -> String,
    fromString: (String) -> T?,
    value: T,
    expectedString: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(toString(value), expectedString, file: file, line: line)
    XCTAssertEqual(fromString(expectedString), value, file: file, line: line)
    XCTAssertNil(fromString("This is invalid"), "Invalid string should return nil", file: file, line: line)
}

/// For enums with additional reverse mapping (i.e. alternate strings mapping to the same value).
func assertEnumConversionWithReverse<T: Equatable>(
    toString: (T) -> String,
    fromString: (String) -> T?,
    value: T,
    expectedString: String,
    reverseMap: [String: T],
    file: StaticString = #file,
    line: UInt = #line
) {
    assertEnumConversion(toString: toString, fromString: fromString, value: value, expectedString: expectedString, file: file, line: line)
    for (altString, expectedValue) in reverseMap {
        XCTAssertEqual(fromString(altString), expectedValue, "Reverse mapping failed for \(altString)", file: file, line: line)
    }
}

class EnumTests: XCTestCase {

    func testActionAlignment() {
        // Expected: ActionAlignment.Center -> "Center"
        assertEnumConversion(
            toString: SwiftActionAlignment.toString,
            fromString: SwiftActionAlignment.fromString,
            value: .center,
            expectedString: "Center"
        )
    }

    func testActionMode() {
        // Expected: ActionMode.Popup -> "Popup"
        assertEnumConversion(
            toString: SwiftActionMode.toString,
            fromString: SwiftActionMode.fromString,
            value: .popup,
            expectedString: "Popup"
        )
    }

    func testActionsOrientation() {
        // Expected: ActionsOrientation.Vertical -> "Vertical"
        assertEnumConversion(
            toString: SwiftActionsOrientation.toString,
            fromString: SwiftActionsOrientation.fromString,
            value: .vertical,
            expectedString: "Vertical"
        )
    }

    func testActionType() {
        // Expected: ActionType.OpenUrl -> "Action.OpenUrl"
        assertEnumConversion(
            toString: SwiftActionType.toString,
            fromString: SwiftActionType.fromString,
            value: .openUrl,
            expectedString: "Action.OpenUrl"
        )
    }

    func testAdaptiveCardSchemaKey() {
        // Expected: AdaptiveCardSchemaKey.Accent -> "accent"
        assertEnumConversion(
            toString: SwiftAdaptiveCardSchemaKey.toString,
            fromString: SwiftAdaptiveCardSchemaKey.fromString,
            value: .accent,
            expectedString: "accent"
        )
    }

    func testCardElementType() {
        // Expected: CardElementType.AdaptiveCard -> "AdaptiveCard"
        assertEnumConversion(
            toString: SwiftCardElementType.toString,
            fromString: SwiftCardElementType.fromString,
            value: .adaptiveCard,
            expectedString: "AdaptiveCard"
        )
    }

    func testChoiceSetStyle() {
        // Expected: ChoiceSetStyle.Filtered -> "Filtered"
        assertEnumConversion(
            toString: SwiftChoiceSetStyle.toString,
            fromString: SwiftChoiceSetStyle.fromString,
            value: .filtered,
            expectedString: "Filtered"
        )
    }

    func testContainerStyle() {
        // Expected: ContainerStyle.Emphasis -> "Emphasis"
        assertEnumConversion(
            toString: SwiftContainerStyle.toString,
            fromString: SwiftContainerStyle.fromString,
            value: .emphasis,
            expectedString: "Emphasis"
        )
    }

    func testFontType() {
        // Expected: FontType.Monospace -> "Monospace"
        assertEnumConversion(
            toString: SwiftFontType.toString,
            fromString: SwiftFontType.fromString,
            value: .monospace,
            expectedString: "Monospace"
        )
    }

    func testForegroundColor() {
        // Expected: ForegroundColor.Accent -> "Accent"
        assertEnumConversion(
            toString: SwiftForegroundColor.toString,
            fromString: SwiftForegroundColor.fromString,
            value: .accent,
            expectedString: "Accent"
        )
    }

    func testHeightType() {
        // Expected: HeightType.Auto -> "Auto"
        assertEnumConversion(
            toString: SwiftHeightType.toString,
            fromString: SwiftHeightType.fromString,
            value: .auto,
            expectedString: "Auto"
        )
    }

    func testHorizontalAlignment() {
        // Expected: HorizontalAlignment.Center -> "center" (note lowercase expected)
        assertEnumConversion(
            toString: SwiftHorizontalAlignment.toString,
            fromString: SwiftHorizontalAlignment.fromString,
            value: .center,
            expectedString: "center"
        )
    }

    func testIconPlacement() {
        // Expected: IconPlacement.LeftOfTitle -> "LeftOfTitle"
        assertEnumConversion(
            toString: SwiftIconPlacement.toString,
            fromString: SwiftIconPlacement.fromString,
            value: .leftOfTitle,
            expectedString: "LeftOfTitle"
        )
    }

    func testImageSize() {
        // Expected: ImageSize.Large -> "Large"
        assertEnumConversion(
            toString: SwiftImageSize.toString,
            fromString: SwiftImageSize.fromString,
            value: .large,
            expectedString: "Large"
        )
    }

    func testImageStyle() {
        // Expected: ImageStyle.Person -> "person"
        assertEnumConversion(
            toString: SwiftImageStyle.toString,
            fromString: SwiftImageStyle.fromString,
            value: .person,
            expectedString: "person"
        )
    }

    func testSeparatorThickness() {
        // Expected: SeparatorThickness.Thick -> "thick"
        assertEnumConversion(
            toString: SwiftSeparatorThickness.toString,
            fromString: SwiftSeparatorThickness.fromString,
            value: .thick,
            expectedString: "thick"
        )
    }

    func testSpacing() {
        // Expected: Spacing.None -> "none"
        assertEnumConversion(
            toString: SwiftSpacing.toString,
            fromString: SwiftSpacing.fromString,
            value: .none,
            expectedString: "none"
        )
    }

    func testTextInputStyle() {
        // Expected: TextInputStyle.Password -> "Password"
        assertEnumConversion(
            toString: SwiftTextInputStyle.toString,
            fromString: SwiftTextInputStyle.fromString,
            value: .password,
            expectedString: "Password"
        )
    }

    func testTextSize() {
        // Expected: TextSize.Large -> "Large"
        // Additional reverse mapping: "Normal" should return .default
        assertEnumConversionWithReverse(
            toString: SwiftTextSize.toString,
            fromString: SwiftTextSize.fromString,
            value: .large,
            expectedString: "Large",
            reverseMap: ["Normal": .defaultSize]
        )
    }

    func testTextWeight() {
        // Expected: TextWeight.Bolder -> "Bolder"
        // Additional reverse mapping: "Normal" should return .defaultWeight
        assertEnumConversionWithReverse(
            toString: SwiftTextWeight.toString,
            fromString: SwiftTextWeight.fromString,
            value: .bolder,
            expectedString: "Bolder",
            reverseMap: ["Normal": .defaultWeight]
        )
    }

    func testVerticalContentAlignment() {
        // Expected: VerticalContentAlignment.Center -> "Center"
        assertEnumConversion(
            toString: SwiftVerticalContentAlignment.toString,
            fromString: SwiftVerticalContentAlignment.fromString,
            value: .center,
            expectedString: "Center"
        )
    }
}
