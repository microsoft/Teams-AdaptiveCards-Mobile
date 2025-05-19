import XCTest
@testable import SwiftAdaptiveCards

class TextParsingTests: XCTestCase {

    func testHtmlEncodingPositiveTest() {
        let input = "\"Foo &amp; Bar\"&nbsp;&lt;admin@example.com&gt;"
        // Note: the &nbsp; entity is expected to be decoded into a non-breaking space (U+00A0)
        let expected = "\"Foo & Bar\"\u{00A0}<admin@example.com>"
        let result = _getTextBlockText(input)
        XCTAssertEqual(expected, result, "Make sure supported HTML entities are decoded")
    }
    
    func testHtmlEncodingAmpTest() {
        // We expect a single-pass decoding, so "&amp;nbsp;" should become "&nbsp;"
        let input = "&amp;nbsp;"
        let expected = "&nbsp;"
        let result = _getTextBlockText(input)
        XCTAssertEqual(expected, result)
    }
    
    func testHtmlEncodingRoundtripTests() {
        let testStrings = [
            "some test text",
            "&foo;",
            "&am p;"
        ]
        
        for testString in testStrings {
            let result = _getTextBlockText(testString)
            XCTAssertEqual(testString, result)
        }
    }
    
    // Helper function analogous to the C++ _GetTextBlockText
    private func _getTextBlockText(_ testString: String) -> String {
        let textBlock = SwiftTextBlock()
        textBlock.setText(testString) // Alternatively, if TextBlock exposes a 'text' property:
                                      // textBlock.text = testString
        return textBlock.getText()    // Or simply return textBlock.text
    }
}
