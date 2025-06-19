//
//  MarkDownUnitTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

final class MarkDownTests: XCTestCase {
    
    func testMarkDownBasicSanityTest_CanHandleEmptyStringTest() {
        let parser = SwiftMarkDownParser("")
        XCTAssertEqual(parser.transformToHtml(), "<p></p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testMarkDownBasicSanityTest_CanHandleEmphasisTest() {
        let parser = SwiftMarkDownParser("*")
        XCTAssertEqual(parser.transformToHtml(), "<p>*</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testMarkDownBasicSanityTest_CanHandleStrongEmphasisTest() {
        let parser = SwiftMarkDownParser("**")
        XCTAssertEqual(parser.transformToHtml(), "<p>**</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterTest() {
        let parser = SwiftMarkDownParser("*foo bar*")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo bar</em></p>")
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterTest() {
        let parser = SwiftMarkDownParser("_foo bar_")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo bar</em></p>")
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterFalseCaseWithSpaceTest() {
        let parser = SwiftMarkDownParser("_ foo bar_")
        XCTAssertEqual(parser.transformToHtml(), "<p>_ foo bar_</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterFalseCaseWithAlphaNumericInfrontAndPuntuationBehind() {
        let parser = SwiftMarkDownParser("a*\"foo\"*")
        XCTAssertEqual(parser.transformToHtml(), "<p>a*&quot;foo&quot;*</p>")
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterIntraWordEmphasis() {
        let parser = SwiftMarkDownParser("foo*bar*")
        XCTAssertEqual(parser.transformToHtml(), "<p>foo<em>bar</em></p>")
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterIntraWordEmphasis() {
        let parser = SwiftMarkDownParser("foo_bar_")
        XCTAssertEqual(parser.transformToHtml(), "<p>foo_bar_</p>")
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterNumericIntraWordEmphasis() {
        let parser = SwiftMarkDownParser("5_6_78")
        XCTAssertEqual(parser.transformToHtml(), "<p>5_6_78</p>")
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterCanBeProceededAndFollowedByPunct() {
        let parser = SwiftMarkDownParser("foo-_(bar)_")
        XCTAssertEqual(parser.transformToHtml(), "<p>foo-<em>(bar)</em></p>")
    }
    
    func testEmphasisDelimiterTest_MatchingRightDelimiterTest() {
        let parser = SwiftMarkDownParser("_foo_")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo</em></p>")
    }
    
    func testEmphasisDelimiterTest_NonMatchingDelimiterTest() {
        let parser = SwiftMarkDownParser("_foo*")
        XCTAssertEqual(parser.transformToHtml(), "<p>_foo*</p>")
    }
    
    func testEmphasisDelimiterTest_MatchingRightDelimiterWithSpaceTest() {
        let parser = SwiftMarkDownParser("*foo *")
        XCTAssertEqual(parser.transformToHtml(), "<p>*foo *</p>")
    }
    
    func testEmphasisDelimiterTest_PunctuationSurroundedByDelimiterValidTest() {
        let parser = SwiftMarkDownParser("*(foo)*")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>(foo)</em></p>")
    }
    
    func testEmphasisDelimiterTest_WhiteSpaceClosingEmphasisInvalidTest() {
        let parser = SwiftMarkDownParser("_foo bar _")
        XCTAssertEqual(parser.transformToHtml(), "<p>_foo bar _</p>")
    }
    
    func testEmphasisDelimiterTest_InvalidIntraWordEmphasisTest() {
        let parser = SwiftMarkDownParser("_foo_bar")
        XCTAssertEqual(parser.transformToHtml(), "<p>_foo_bar</p>")
    }
    
    func testStrongDelimiterTest_SimpleValidCaseTest() {
        let parser = SwiftMarkDownParser("**foo bar**")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong>foo bar</strong></p>")
        let parser1 = SwiftMarkDownParser("__foo bar__")
        XCTAssertEqual(parser1.transformToHtml(), "<p><strong>foo bar</strong></p>")
    }
    
    func testRule11_12Test_EscapeTest() {
        let parser = SwiftMarkDownParser("foo *\\**")
        XCTAssertEqual(parser.transformToHtml(), "<p>foo <em>*</em></p>")
        
        let parser2 = SwiftMarkDownParser("foo **\\***")
        XCTAssertEqual(parser2.transformToHtml(), "<p>foo <strong>*</strong></p>")
        
        let parser3 = SwiftMarkDownParser("foo __\\___")
        XCTAssertEqual(parser3.transformToHtml(), "<p>foo <strong>_</strong></p>")
    }
    
    func testLinkBasicValidationTest_CanGenerateValidHtmlTagForLinkTest() {
        let parser = SwiftMarkDownParser("[hello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\">hello</a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets5() {
        let parser = SwiftMarkDownParser("[*hellohello]hello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[*hellohello]hello](www.naver.com)</p>")
    }
    
    func testLinkBasicValidationTest_InvalidLinkTest() {
        let parser = SwiftMarkDownParser("[hello(www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[hello(www.naver.com)</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testLinkBasicValidationTest_InvalidLinkTestWithInvalidEmphasis() {
        let parser = SwiftMarkDownParser("*[*hello(www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>*[*hello(www.naver.com)</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testLinkBasicValidationTest_InvalidLinkTestWithValidEmphasis() {
        let parser = SwiftMarkDownParser("*[*hello(www.naver.com)*")
        XCTAssertEqual(parser.transformToHtml(), "<p>*[<em>hello(www.naver.com)</em></p>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testLinkBasicValidationTest_InvalidCharsBetweenLinkTextAndDestination() {
        let parser = SwiftMarkDownParser("[hello]a(www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[hello]a(www.naver.com)</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testLinkBasicValidationTest_EmphasisAndLinkTextTest() {
        let parser = SwiftMarkDownParser("[*hello*](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\"><em>hello</em></a></p>")
    }
    
    func testLinkNestedParenthesisTest_1() {
        let parser = SwiftMarkDownParser("[empty destination]()")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"\">empty destination</a></p>")
    }

    func testLinkNestedParenthesisTest_6() {
        let parser = SwiftMarkDownParser("[Stay tuned to Know)]()afafafa()")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"\">Stay tuned to Know)</a>afafafa()</p>")
    }
    
    func testListTest_SimpleValidListTest() {
        let parser = SwiftMarkDownParser("- hello")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello</li></ul>")
        let parser2 = SwiftMarkDownParser("* hello")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello</li></ul>")
        let parser3 = SwiftMarkDownParser("+ hello")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello</li></ul>")
    }
    
    func testListTest_ListTestsWithInterHyphen() {
        let parser = SwiftMarkDownParser("- hello world - hello hello")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello world - hello hello</li></ul>")
        let parser2 = SwiftMarkDownParser("* hello world - hello hello")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello world - hello hello</li></ul>")
        let parser3 = SwiftMarkDownParser("- hello world + hello hello")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello world + hello hello</li></ul>")
    }
    
    func testListTest_ListFollowedByPtagedBlockElementTest() {
        let parser = SwiftMarkDownParser("- my list\r\rHello")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>my list</li></ul><p>Hello</p>")
        let parser2 = SwiftMarkDownParser("* my list\r\rHello")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>my list</li></ul><p>Hello</p>")
        let parser3 = SwiftMarkDownParser("+ my list\r\rHello")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>my list</li></ul><p>Hello</p>")
    }
    
    func testListTest_InvalidListStringReturnedUnchangedTest() {
        let parser = SwiftMarkDownParser("023-34-567")
        XCTAssertEqual(parser.transformToHtml(), "<p>023-34-567</p>")
        XCTAssertEqual(parser.hasHtmlTags(), false)
    }
    
    func testOrderedListTest_SimpleValidListTest() {
        let parser = SwiftMarkDownParser("1. hello")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello</li></ol>")
    }
    
    func testOrderedListTest_ListFollowedByPtagedBlockElementTest() {
        let parser = SwiftMarkDownParser("1. my list\r\rHello")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>my list</li></ol><p>Hello</p>")
    }
    
    func testEscapeHtmlCharactersTest_GreaterThanTest() {
        let parser = SwiftMarkDownParser("5>3")
        XCTAssertEqual(parser.transformToHtml(), "<p>5&gt;3</p>")
    }
    
    func testEscapeHtmlCharactersTest_LessThanTest() {
        let parser = SwiftMarkDownParser("3<5")
        XCTAssertEqual(parser.transformToHtml(), "<p>3&lt;5</p>")
    }
    
    func testEscapeHtmlCharactersTest_QuotationTest() {
        let parser = SwiftMarkDownParser("\"Hello World!\"")
        XCTAssertEqual(parser.transformToHtml(), "<p>&quot;Hello World!&quot;</p>")
    }
    
    func testEscapeHtmlCharactersTest_AmpersandTest() {
        let parser = SwiftMarkDownParser("Green Eggs & Ham")
        XCTAssertEqual(parser.transformToHtml(), "<p>Green Eggs &amp; Ham</p>")
    }
    
    func testNonLatinCharacters_NoMarkdown() {
        let parser = SwiftMarkDownParser("以前の製品のリンクで検索")
        XCTAssertEqual(parser.transformToHtml(), "<p>以前の製品のリンクで検索</p>")
    }
    
    func testNonLatinCharacters_Bold() {
        let parser = SwiftMarkDownParser("**以前の製品のリンクで検索**")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong>以前の製品のリンクで検索</strong></p>")
    }
    
    func testNonLatinCharacters_BoldSentence() {
        let parser = SwiftMarkDownParser("How about **以前の製品のリンクで検索**")
        XCTAssertEqual(parser.transformToHtml(), "<p>How about <strong>以前の製品のリンクで検索</strong></p>")
    }
    
    func testNonLatinCharacters_BoldSentenceLeadingNonLatin() {
        let parser = SwiftMarkDownParser("以前の製品のリンクで検索 **以前の製品のリンクで検索**")
        XCTAssertEqual(parser.transformToHtml(), "<p>以前の製品のリンクで検索 <strong>以前の製品のリンクで検索</strong></p>")
    }
    
    func testNonLatinCharacters_BoldSentenceLeadingNonLatinNoSpace() {
        let parser = SwiftMarkDownParser("以前の製品のリンクで検索**以前の製品のリンクで検索**")
        XCTAssertEqual(parser.transformToHtml(), "<p>以前の製品のリンクで検索<strong>以前の製品のリンクで検索</strong></p>")
    }
    
    func testNonLatinCharacters_BoldSentenceNoWhitespace() {
        let parser = SwiftMarkDownParser("How about**以前の製品のリンクで検索**")
        XCTAssertEqual(parser.transformToHtml(), "<p>How about<strong>以前の製品のリンクで検索</strong></p>")
    }
    
    func testRule9Test_MultipleOf3Test() {
        XCTAssertEqual(SwiftMarkDownParser("Hello***World***").transformToHtml(), "<p>Hello***World***</p>")
    }
   
   func testEscapeHtmlCharactersTest_CanDetectEscapeTest() {
       let parser = SwiftMarkDownParser("")
       XCTAssertEqual(parser.isEscapedText(), false)
       
       _ = parser.transformToHtml()
       XCTAssertEqual(parser.isEscapedText(), false)
       
       let parser1 = SwiftMarkDownParser("&")
       _ = parser1.transformToHtml()
       XCTAssertEqual(parser1.isEscapedText(), true)
       
       let parser2 = SwiftMarkDownParser("Hello World&")
       _ = parser2.transformToHtml()
       XCTAssertEqual(parser2.isEscapedText(), true)
       
       let parser3 = SwiftMarkDownParser(" & ")
       _ = parser3.transformToHtml()
       XCTAssertEqual(parser3.isEscapedText(), true)
   }
}
