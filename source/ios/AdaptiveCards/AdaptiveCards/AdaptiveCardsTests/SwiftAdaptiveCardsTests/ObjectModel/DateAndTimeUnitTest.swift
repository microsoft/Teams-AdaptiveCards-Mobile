//
//  DateAndTimeUnitTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

/// Helper to skip tests when not running in the Pacific timezone.
/// (Here we assume Pacific Standard Time is GMT–8, i.e. –28800 seconds.)
func skipTestIfNotPacificTimezone() throws {
    let currentTimeZone = TimeZone.current
    if currentTimeZone.secondsFromGMT() != -28800 {
        throw XCTSkip("Skipping test for non-Pacific timezone")
    }
}

final class TimeTest: XCTestCase {
    
    func testTransformToTimeTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-28T02:17:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "07:17 PM")
        XCTAssertEqual(token.format, .RegularString)
    }
    
    func testTransformToTimeTest2() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T18:19:09Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "11:19 AM")
        XCTAssertEqual(token.format, .RegularString)
    }
    
    func testTransformToTimeWithSmallPositiveOffsetTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-28T04:20:00+02:00)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "07:20 PM")
        XCTAssertEqual(token.format, .RegularString)
    }
    
    func testTransformToTimeWithLargePositiveOffsetTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-28T11:25:00+09:00)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "07:25 PM")
        XCTAssertEqual(token.format, .RegularString)
    }
    
    func testTransformToTimeWithMinusOffsetTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T22:27:00-04:00)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "07:27 PM")
        XCTAssertEqual(token.format, .RegularString)
    }
}

final class DateTest: XCTestCase {
    
    func testTransformDateTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-02-13T20:46:30Z, COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 13)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testTransformToDateWithSmallPositiveOffset() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-10-28T04:20:00+02:00, COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 27)
        XCTAssertEqual(token.month, 9)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testTransformToDateWithLargePositiveOffset() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-10-28T11:25:00+09:00, COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 27)
        XCTAssertEqual(token.month, 9)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testTransformToDateNegativeOffset() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-10-27T22:27:00-04:00, COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 27)
        XCTAssertEqual(token.month, 9)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testTransformToDateRespectsOptionalSpace() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-10-27T22:27:00-04:00,COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 27)
        XCTAssertEqual(token.month, 9)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testTransformToDateOnlyAllowsUpToOneSpaceBeforeModifier() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-10-27T22:27:00-04:00,  COMPACT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
}

final class TimeAndDateInputTest: XCTestCase {
    
    func testTimeWithShortFormat() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T22:07:00Z, SHORT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testTimeWithLongFormat() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T22:27:00-04:00, LONG)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testTimeWithLongFormatInText() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "Hello {{TIME(2017-10-27T26:27:00Z, LONG)}} World!"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testMissingLeadingDigitOfMinutesInputTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T22:7:00-04:00)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testMissingColumnDelimiterTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-10-27T2:7:00Q04:00)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testISO8601WithTextTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "You have arrived in New York on {{DATE(2017-10-27T22:23:00Z, SHORT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.last else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, "{{DATE(2017-10-27T22:23:00Z, SHORT)}}")
        XCTAssertEqual(token.format, .DateShort)
    }
    
    func testTwoISO8601WithText() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "You have arrived in New York on {{DATE(2017-10-27T22:27:00-04:00, SHORT)}} at {{TIME(2017-10-27T22:27:00-04:00)}}.\r have a good trip"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        let tokens = preparser.textTokens
        
        XCTAssertEqual(tokens.count, 5)
        
        XCTAssertEqual(tokens[0].text, "You have arrived in New York on ")
        XCTAssertEqual(tokens[0].format, .RegularString)
        
        XCTAssertEqual(tokens[1].text, "{{DATE(2017-10-27T22:27:00-04:00, SHORT)}}")
        XCTAssertEqual(tokens[1].day, 27)
        XCTAssertEqual(tokens[1].month, 9)
        XCTAssertEqual(tokens[1].year, 2017)
        XCTAssertEqual(tokens[1].format, .DateShort)
        
        XCTAssertEqual(tokens[2].text, " at ")
        XCTAssertEqual(tokens[2].format, .RegularString)
        
        XCTAssertEqual(tokens[3].text, "07:27 PM")
        XCTAssertEqual(tokens[3].format, .RegularString)
        
        XCTAssertEqual(tokens[4].text, ".\r have a good trip")
        XCTAssertEqual(tokens[4].format, .RegularString)
    }
    
    func testPrefixStringISO8650suffixStringTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "You will arrived in Seattle on {{DATE(2017-10-27T22:23:00Z, SHORT)}}; have a good trip"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        let tokens = preparser.textTokens
        
        XCTAssertEqual(tokens.count, 3)
        
        XCTAssertEqual(tokens[0].text, "You will arrived in Seattle on ")
        XCTAssertEqual(tokens[0].format, .RegularString)
        
        XCTAssertEqual(tokens[1].text, "{{DATE(2017-10-27T22:23:00Z, SHORT)}}")
        XCTAssertEqual(tokens[1].day, 27)
        XCTAssertEqual(tokens[1].month, 9)
        XCTAssertEqual(tokens[1].year, 2017)
        XCTAssertEqual(tokens[1].format, .DateShort)
        
        XCTAssertEqual(tokens[2].text, "; have a good trip")
        XCTAssertEqual(tokens[2].format, .RegularString)
    }
    
    func testMalformedCurlybracketsTest() {
        let blck = SwiftTextBlock()
        let testString = "{a{DATE(2017-02-13T20:46:30Z, SHORT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testMissingClosingCurlyBracketTest() {
        let blck = SwiftTextBlock()
        // Note: The original C++ test used a missing closing brace.
        let testString = "{{DATE(2017-02-13T20:46:30Z, SHORT)}}".dropLast()  // drop the last '}' to simulate the missing bracket
        blck.text = String(testString)
        XCTAssertEqual(blck.text, String(testString))
    }
    
    func testYearInBadFormatInputTest() {
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017a02-13T20:46:30Z, SHORT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testDateDefaultStyleInputTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-02-13T20:46:30Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 13)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testDateLONGStyleInputTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-02-13T20:46:30Z, LONG)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 13)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateLong)
    }
    
    func testDateSHORTStyleInputTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-02-13T20:46:30Z, SHORT)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 13)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 2017)
        XCTAssertEqual(token.format, .DateShort)
    }
    
    func testDateSmallCaseLONGStyleInputTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-02-13T20:46:30Z, Long)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testInvalidDateTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(2017-99-14T06:08:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testInvalidTimeTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{TIME(2017-99-14T06:08:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
    
    func testLeapYearValidDayTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(1992-02-29T18:08:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 29)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 1992)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testLeapYearValidDayOnlyAtUTCTest() throws {
        try skipTestIfNotPacificTimezone()
        let blck = SwiftTextBlock()
        let testString = "{{DATE(1992-02-29T07:59:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
        
        let preparser = blck.getTextForDateParsing()
        guard let token = preparser.textTokens.first else {
            XCTFail("Expected at least one token")
            return
        }
        XCTAssertEqual(token.text, testString)
        XCTAssertEqual(token.day, 28)
        XCTAssertEqual(token.month, 1)
        XCTAssertEqual(token.year, 1992)
        XCTAssertEqual(token.format, .DateCompact)
    }
    
    func testNoneLeapYearInvalidDayTest() {
        let blck = SwiftTextBlock()
        let testString = "{{DATE(1994-02-29T06:08:00Z)}}"
        blck.text = testString
        XCTAssertEqual(blck.text, testString)
    }
}
