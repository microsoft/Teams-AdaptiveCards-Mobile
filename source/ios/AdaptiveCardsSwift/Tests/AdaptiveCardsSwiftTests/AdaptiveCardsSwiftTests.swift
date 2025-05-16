import XCTest
@testable import AdaptiveCardsSwift

final class AdaptiveCardsSwiftTests: XCTestCase {
    func testSwiftAdaptiveCardParser() {
        XCTAssertNotNil(SwiftAdaptiveCardParser.self)
        
        // Enable the Swift parser
        SwiftAdaptiveCardParser.enableSwiftParser(true)
        XCTAssertTrue(SwiftAdaptiveCardParser.isSwiftParserEnabled())
        
        // Disable the Swift parser
        SwiftAdaptiveCardParser.enableSwiftParser(false)
        XCTAssertFalse(SwiftAdaptiveCardParser.isSwiftParserEnabled())
    }
}
