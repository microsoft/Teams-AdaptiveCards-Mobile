@testable import SwiftAdaptiveCards
import XCTest

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

    /*
    func testStrongDelimiterTest_DelimiterWithSpaceInvalidCaseTest() {
        let parser = MarkDownParser("** foo bar**")
        XCTAssertEqual(parser.transformToHtml(), "<p>** foo bar**</p>")
        let parser1 = MarkDownParser("__ foo bar__")
        XCTAssertEqual(parser1.transformToHtml(), "<p>__ foo bar__</p>")
        let parser2 = MarkDownParser("**foo bar **")
        XCTAssertEqual(parser2.transformToHtml(), "<p>**foo bar **</p>")
        let parser3 = MarkDownParser("__foo bar __")
        XCTAssertEqual(parser3.transformToHtml(), "<p>__foo bar __</p>")
    }

    func testStrongDelimiterTest_DelimiterSurroundingPuntuationInvalidCaseTest() {
        let parser = MarkDownParser("a**\"foo bar\"**")
        XCTAssertEqual(parser.transformToHtml(), "<p>a**&quot;foo bar&quot;**</p>")
        let parser2 = MarkDownParser("a__\"foo bar\"__")
        XCTAssertEqual(parser2.transformToHtml(), "<p>a__&quot;foo bar&quot;__</p>")
    }
    
    func testStrongDelimiterTest_IntraWordTest() {
        let parser = MarkDownParser("**foo**bar")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong>foo</strong>bar</p>")
        let parser2 = MarkDownParser("__foo__bar")
        XCTAssertEqual(parser2.transformToHtml(), "<p>__foo__bar</p>")
    }
    
    func testStrongDelimiterTest_PunctuationDelimitersTest() {
        let parser = MarkDownParser("**(**foo)")
        XCTAssertEqual(parser.transformToHtml(), "<p>**(**foo)</p>")
        
        let parser2 = MarkDownParser("__(__foo")
        XCTAssertEqual(parser2.transformToHtml(), "<p>__(__foo</p>")
        
        let parser3 = MarkDownParser("foo-__(bar)__")
        XCTAssertEqual(parser3.transformToHtml(), "<p>foo-<strong>(bar)</strong></p>")
        
        let parser4 = MarkDownParser("(**foo**)")
        XCTAssertEqual(parser4.transformToHtml(), "<p>(<strong>foo</strong>)</p>")
        
        let parser5 = MarkDownParser("(__foo__)")
        XCTAssertEqual(parser5.transformToHtml(), "<p>(<strong>foo</strong>)</p>")
        
        let parser6 = MarkDownParser("__(foo)__.")
        XCTAssertEqual(parser6.transformToHtml(), "<p><strong>(foo)</strong>.</p>")
    }
    
    func testDelimiterNestingTest_PunctuationDelimitersTest() {
        let parser = MarkDownParser("_foo __bar__ baz_")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo <strong>bar</strong> baz</em></p>")
        
        let parser2 = MarkDownParser("*foo *bar**")
        XCTAssertEqual(parser2.transformToHtml(), "<p><em>foo <em>bar</em></em></p>")
        
        let parser3 = MarkDownParser("_foo _bar_ baz_")
        XCTAssertEqual(parser3.transformToHtml(), "<p><em>foo <em>bar</em> baz</em></p>")
        
        let parser4 = MarkDownParser("*foo **bar** baz*")
        XCTAssertEqual(parser4.transformToHtml(), "<p><em>foo <strong>bar</strong> baz</em></p>")
        
        let parser5 = MarkDownParser("*foo **bar *baz* bim** bop*")
        XCTAssertEqual(parser5.transformToHtml(), "<p><em>foo <strong>bar <em>baz</em> bim</strong> bop</em></p>")
        
        let parser6 = MarkDownParser("***foo** bar*")
        XCTAssertEqual(parser6.transformToHtml(), "<p><em><strong>foo</strong> bar</em></p>")
        
        let parser7 = MarkDownParser("*foo **bar***")
        XCTAssertEqual(parser7.transformToHtml(), "<p><em>foo <strong>bar</strong></em></p>")
        
        let parser8 = MarkDownParser("** is not an empty emphasis")
        XCTAssertEqual(parser8.transformToHtml(), "<p>** is not an empty emphasis</p>")
        
        let parser9 = MarkDownParser("**** is not an empty emphasis")
        XCTAssertEqual(parser9.transformToHtml(), "<p>**** is not an empty emphasis</p>")
        
        let parser10 = MarkDownParser("**foo\nbar**")
        XCTAssertEqual(parser10.transformToHtml(), "<p><strong>foo\nbar</strong></p>")
        
        let parser11 = MarkDownParser("__foo __bar__ baz__")
        XCTAssertEqual(parser11.transformToHtml(), "<p><strong>foo <strong>bar</strong> baz</strong></p>")
        
        let parser12 = MarkDownParser("**foo **bar****")
        XCTAssertEqual(parser12.transformToHtml(), "<p><strong>foo <strong>bar</strong></strong></p>")
        
        let parser13 = MarkDownParser("**foo *bar **baz**\n bim* bop**")
        XCTAssertEqual(parser13.transformToHtml(), "<p><strong>foo <em>bar <strong>baz</strong>\n bim</em> bop</strong></p>")
    }
    
    func testRule11_12Test_UnevenMatchingDelimiter() {
        let parser = MarkDownParser("**foo*")
        XCTAssertEqual(parser.transformToHtml(), "<p>*<em>foo</em></p>")
        
        let parser1 = MarkDownParser("*foo**")
        XCTAssertEqual(parser1.transformToHtml(), "<p><em>foo</em>*</p>")
        
        let parser2 = MarkDownParser("***foo**")
        XCTAssertEqual(parser2.transformToHtml(), "<p>*<strong>foo</strong></p>")
        
        let parser3 = MarkDownParser("*foo****")
        XCTAssertEqual(parser3.transformToHtml(), "<p><em>foo</em>***</p>")
        
        let parser4 = MarkDownParser("**Gomphocarpus (*Gomphocarpus physocarpus*, syn.\n*Asclepias physocarpa*)**")
        XCTAssertEqual(parser4.transformToHtml(), "<p><strong>Gomphocarpus (<em>Gomphocarpus physocarpus</em>, syn.\n<em>Asclepias physocarpa</em>)</strong></p>")
        
        let parser5 = MarkDownParser("*Hello* abc ***Hello* def *world***")
        XCTAssertEqual(parser5.transformToHtml(), "<p><em>Hello</em> abc <strong><em>Hello</em> def <em>world</em></strong></p>")
        
        let parser6 = MarkDownParser("*foo**bar**baz*")
        XCTAssertEqual(parser6.transformToHtml(), "<p><em>foo<strong>bar</strong>baz</em></p>")
    }
    
    func testRule13Test_strongEmphasisNesting() {
        let parser = MarkDownParser("****foo****")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong><strong>foo</strong></strong></p>")
        let parser2 = MarkDownParser("******foo******")
        XCTAssertEqual(parser2.transformToHtml(), "<p><strong><strong><strong>foo</strong></strong></strong></p>")
    }
    
    func testRule14Test_strongAndEmphasisNesting() {
        let parser = MarkDownParser("***foo***")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong><em>foo</em></strong></p>")
        
        let parser2 = MarkDownParser("_____foo_____")
        XCTAssertEqual(parser2.transformToHtml(), "<p><strong><strong><em>foo</em></strong></strong></p>")
    }
    
    func testRule15Test_OverlappingTest() {
        let parser = MarkDownParser("*foo _bar* baz_")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo _bar</em> baz_</p>")
        
        let parser2 = MarkDownParser("*foo __bar *baz bim__ bam*")
        XCTAssertEqual(parser2.transformToHtml(), "<p><em>foo <strong>bar *baz bim</strong> bam</em></p>")
    }
    
    func testRule16Test_strongEmphasis() {
        let parser = MarkDownParser("**foo **bar baz**")
        XCTAssertEqual(parser.transformToHtml(), "<p>**foo <strong>bar baz</strong></p>")
        
        let parser2 = MarkDownParser("*foo *bar baz*")
        XCTAssertEqual(parser2.transformToHtml(), "<p>*foo <em>bar baz</em></p>")
        
        let parser3 = MarkDownParser("**K *J *foo**bar* *cool*")
        XCTAssertEqual(parser3.transformToHtml(), "<p><strong>K *J *foo</strong>bar* <em>cool</em></p>")
        
        let parser4 = MarkDownParser("**m *J *foo**bar *cool**")
        XCTAssertEqual(parser4.transformToHtml(), "<p><strong>m *J *foo</strong>bar <em>cool</em>*</p>")
        
        let parser5 = MarkDownParser("**H *foo**bar***")
        XCTAssertEqual(parser5.transformToHtml(), "<p><strong>H *foo</strong>bar***</p>")
        
        let parser6 = MarkDownParser("*hello *hi **H foo** bar**")
        XCTAssertEqual(parser6.transformToHtml(), "<p><em>hello <em>hi <strong>H foo</strong> bar</em></em></p>")
        
        let parser7 = MarkDownParser("hello **how are** *you **i** am **great** *thank* **you***")
        XCTAssertEqual(parser7.transformToHtml(), "<p>hello <strong>how are</strong> <em>you <strong>i</strong> am <strong>great</strong> <em>thank</em> <strong>you</strong></em></p>")
        
        let parser8 = MarkDownParser("hello, **how are__ you**")
        XCTAssertEqual(parser8.transformToHtml(), "<p>hello, <strong>how are__ you</strong></p>")
        
        let parser9 = MarkDownParser("hello, __how **are__ you?**")
        XCTAssertEqual(parser9.transformToHtml(), "<p>hello, <strong>how **are</strong> you?**</p>")
        
        let parser10 = MarkDownParser("hello, **how are__ you**")
        XCTAssertEqual(parser10.transformToHtml(), "<p>hello, <strong>how are__ you</strong></p>")
    }
    
    func testRule16Test_TempTest() {
        let parser = MarkDownParser("*hello *hello**h*")
        XCTAssertEqual(parser.transformToHtml(), "<p>*hello <em>hello**h</em></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithUnMatchingBrackets() {
        let parser = MarkDownParser("[[[[hello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[[[<a href=\"www.naver.com\">hello</a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets() {
        let parser = MarkDownParser("[[hello]](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\">[hello]</a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets2() {
        let parser = MarkDownParser("[*[hello]*](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\"><em>[hello]</em></a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets3() {
        let parser = MarkDownParser("[*[hello[hello]hello]*](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\"><em>[hello[hello]hello]</em></a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets4() {
        let parser = MarkDownParser("[*hello[hello]hello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\">*hello[hello]hello</a></p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets6() {
        let parser = MarkDownParser("[Bug [021356]](https://msn.com): Markdown link parsing")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://msn.com\">Bug [021356]</a>: Markdown link parsing</p>")
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithUnMatchingBracketsWithChars() {
        let parser = MarkDownParser("[a[b[hello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[a[b<a href=\"www.naver.com\">hello</a></p>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithUnMatchingBracketsWithCharsAndParenthesis() {
        let parser = MarkDownParser("[[a[b[h(ello](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>[[a[b<a href=\"www.naver.com\">h(ello</a></p>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithEscapedDelimiters() {
        let parser = MarkDownParser("[[cool link!]](https://contoso.com/New%20Document%20(1\\).docx)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://contoso.com/New%20Document%20(1).docx\">[cool link!]</a></p>")
    }
    
    func testLinkBasicValidationTest_LinkTextWithNumberAndPunchuations() {
        let parser = MarkDownParser("[1234.5](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"www.naver.com\">1234.5</a></p>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testLinkBasicValidationTest_OutSideEmphasisAndLinkTest() {
        let parser = MarkDownParser("*[hello](www.naver.com)*")
        XCTAssertEqual(parser.transformToHtml(), "<p><em><a href=\"www.naver.com\">hello</a></em></p>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testLinkBasicValidationTest_UmatchingEmphasisAndLinkTextTest() {
        let parser = MarkDownParser("*[*hello*](www.naver.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>*<a href=\"www.naver.com\"><em>hello</em></a></p>")
    }
    
    func testLinkBasicValidationTest_EmphasisAndLinkDestinationTest() {
        let parser = MarkDownParser("*[*hello*](*www.naver.com*)")
        XCTAssertEqual(parser.transformToHtml(), "<p>*<a href=\"*www.naver.com*\"><em>hello</em></a></p>")
    }
    
    func testLinkBasicValidationTest_LinkWithComplexEmphasisString() {
        let parser = MarkDownParser("**Hello** *[*hello*](*www.naver.com*)*")
        XCTAssertEqual(parser.transformToHtml(), "<p><strong>Hello</strong> <em><a href=\"*www.naver.com*\"><em>hello</em></a></em></p>")
    }
    
    func testLinkBasicValidationTest_TwoLinksTest() {
        let parser = MarkDownParser("*Hello* *[*hello*](*www.naver.com*)** Hello, [second](www.microsoft.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>Hello</em> <em><a href=\"*www.naver.com*\"><em>hello</em></a></em>* Hello, <a href=\"www.microsoft.com\">second</a></p>")
    }
    
    func testLinkNestedParenthesisTest_2() {
        let parser = MarkDownParser("[Stay tuned to Know [aaa] m (aa)ore](https://aaa.bbb.com/(a)sites(Test).doc?somegar)bageValue*afterstar()")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://aaa.bbb.com/(a)sites(Test).doc?somegar\">Stay tuned to Know [aaa] m (aa)ore</a>bageValue*afterstar()</p>")
    }
    
    func testLinkNestedParenthesisTest_3() {
        let parser = MarkDownParser("[Stay tuned to Know more](https://aaa.bbb.com/(a)sites(Test).doc?somegarbageValue)*afterstar()")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://aaa.bbb.com/(a)sites(Test).doc?somegarbageValue\">Stay tuned to Know more</a>*afterstar()</p>")
    }
    
    func testLinkNestedParenthesisTest_4() {
        let parser = MarkDownParser("[Stay tuned to Know more](https://aaa.bbb.com/(a)sit(es(Test).doc?somegarbageValue)*afafafafafafa)*")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://aaa.bbb.com/(a)sit(es(Test).doc?somegarbageValue)*afafafafafafa\">Stay tuned to Know more</a>*</p>")
    }
    
    func testLinkNestedParenthesisTest_5() {
        let parser = MarkDownParser("[Stay tuned to Know more](https://aaa.bbb.com/(a)sit(es(Test).doc?somegarbageValue)*afafafafafafa)")
        XCTAssertEqual(parser.transformToHtml(), "<p><a href=\"https://aaa.bbb.com/(a)sit(es(Test).doc?somegarbageValue)*afafafafafafa\">Stay tuned to Know more</a></p>")
    }
    
    func testLinkNestedParenthesisTest_7() {
        let parser = MarkDownParser("[](()")
        XCTAssertEqual(parser.transformToHtml(), "<p>[](()</p>")
    }
    
    func testListTest_MultipleSimpleValidListTest() {
        let parser = MarkDownParser("- hello\n- world\n- hi")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello</li><li>world</li><li>hi</li></ul>")
        let parser2 = MarkDownParser("* hello\n* world\n* hi")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello</li><li>world</li><li>hi</li></ul>")
        let parser3 = MarkDownParser("* hello\n- Hi")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello</li><li>Hi</li></ul>")
        let parser4 = MarkDownParser("+ hello\n+ world\n+ hi")
        XCTAssertEqual(parser4.transformToHtml(), "<ul><li>hello</li><li>world</li><li>hi</li></ul>")
    }
    
    func testListTest_MultipleListWithHyphenTests() {
        let parser = MarkDownParser("- hello world - hello hello\r- winner winner chicken dinner")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello world - hello hello</li><li>winner winner chicken dinner</li></ul>")
        let parser2 = MarkDownParser("* hello world * hello hello\r* winner winner chicken dinner")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello world * hello hello</li><li>winner winner chicken dinner</li></ul>")
        let parser3 = MarkDownParser("+ hello world * hello hello\r+ winner winner chicken dinner")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello world * hello hello</li><li>winner winner chicken dinner</li></ul>")
    }
    
    func testListTest_MultipleListWithHyphenAndEmphasisTests() {
        let parser = MarkDownParser("- hello world - hello hello\r- ***winner* winner** chicken dinner")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello world - hello hello</li><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>")
        let parser2 = MarkDownParser("* hello world * hello hello\r* ***winner* winner** chicken dinner")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello world * hello hello</li><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>")
        let parser3 = MarkDownParser("+ hello world * hello hello\r+ ***winner* winner** chicken dinner")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello world * hello hello</li><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>")
    }
    
    func testListTest_MultipleListWithLinkTest() {
        let parser = MarkDownParser("- hello world\r- hello hello\r- new site = [adaptive card](www.adaptivecards.io)")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>hello world</li><li>hello hello</li><li>new site = <a href=\"www.adaptivecards.io\">adaptive card</a></li></ul>")
        let parser2 = MarkDownParser("* hello world\r* hello hello\r* new site = [adaptive card](www.adaptivecards.io)")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>hello world</li><li>hello hello</li><li>new site = <a href=\"www.adaptivecards.io\">adaptive card</a></li></ul>")
        let parser3 = MarkDownParser("+ hello world\r+ hello hello\r+ new site = [adaptive card](www.adaptivecards.io)")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>hello world</li><li>hello hello</li><li>new site = <a href=\"www.adaptivecards.io\">adaptive card</a></li></ul>")
    }
    
    func testListTest_PtagedBlockElementFollowedByListTest() {
        let parser = MarkDownParser("Hello\r- my list")
        XCTAssertEqual(parser.transformToHtml(), "<p>Hello</p><ul><li>my list</li></ul>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
        let parser2 = MarkDownParser("Hello\r* my list")
        XCTAssertEqual(parser2.transformToHtml(), "<p>Hello</p><ul><li>my list</li></ul>")
        XCTAssertEqual(parser2.hasHtmlTags(), true)
        let parser3 = MarkDownParser("Hello\r+ my list")
        XCTAssertEqual(parser3.transformToHtml(), "<p>Hello</p><ul><li>my list</li></ul>")
        XCTAssertEqual(parser3.hasHtmlTags(), true)
    }
    
    func testListTest_ListFollowedWithNewLineCharTest() {
        let parser = MarkDownParser("- my list\rHello")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>my list\rHello</li></ul>")
        let parser2 = MarkDownParser("* my list\rHello")
        XCTAssertEqual(parser2.transformToHtml(), "<ul><li>my list\rHello</li></ul>")
        let parser3 = MarkDownParser("+ my list\rHello")
        XCTAssertEqual(parser3.transformToHtml(), "<ul><li>my list\rHello</li></ul>")
    }
    
    func testListTest_LeftDelimiterFalseCaseWithSpaceTest() {
        let parser = MarkDownParser("* foo bar*")
        XCTAssertEqual(parser.transformToHtml(), "<ul><li>foo bar*</li></ul>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testOrderedListTest_MultipleSimpleValidListTest() {
        let parser = MarkDownParser("1. hello\n2. Hi")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello</li><li>Hi</li></ol>")
    }
    
    func testOrderedListTest_ListTestsWithInterHyphen() {
        let parser = MarkDownParser("1. hello world - hello hello")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello world - hello hello</li></ol>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testOrderedListTest_MultipleListWithHyphenTests() {
        let parser = MarkDownParser("1. hello world - hello hello\r2. winner winner chicken dinner")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello world - hello hello</li><li>winner winner chicken dinner</li></ol>")
    }
    
    func testOrderedListTest_MultipleListWithHyphenAndEmphasisTests() {
        let parser = MarkDownParser("1. hello world - hello hello\r- ***winner* winner** chicken dinner")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello world - hello hello</li></ol><ul><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>")
    }
    
    func testOrderedListTest_MultipleListWithLinkTest() {
        let parser = MarkDownParser("1. hello world\r2. hello hello\r3. new site = [adaptive card](www.adaptivecards.io)")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>hello world</li><li>hello hello</li><li>new site = <a href=\"www.adaptivecards.io\">adaptive card</a></li></ol>")
    }
    
    func testOrderedListTest_PtagedBlockElementFollowedByListTest() {
        let parser = MarkDownParser("Hello\r1. my list")
        XCTAssertEqual(parser.transformToHtml(), "<p>Hello</p><ol start=\"1\"><li>my list</li></ol>")
        XCTAssertEqual(parser.hasHtmlTags(), true)
    }
    
    func testOrderedListTest_ListFollowedWithNewLineCharTest() {
        let parser = MarkDownParser("1. my list\rHello")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>my list\rHello</li></ol>")
    }
    
    func testOrderedListTest_ListStartsWithRandomNumberTest() {
        let parser = MarkDownParser("777. my list\rHello")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"777\"><li>my list\rHello</li></ol>")
    }

    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterFalseCaseWithAlphaNumericInfrontAndPuntuationBehind() {
        let parser = MarkDownParser("a_\"foo\"_")
        XCTAssertEqual(parser.transformToHtml(), "<p>a_&quot;foo&quot;_</p>")
    }
    
    func testNonLatinCharacters_NewlineWithLink() {
        let parser = MarkDownParser("It's OK!\rClick [以前の製品のリンクで検索](https://www.microsoft.com)\rClick [以前の製品のリンクで検索](https://www.microsoft.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>It's OK!\rClick <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a>\rClick <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></p>")
    }
    
    func testNonLatinCharacters_NumberedListWithLink() {
        let parser = MarkDownParser("1. Click [以前の製品のリンクで検索](https://www.microsoft.com)\r2. Click [以前の製品のリンクで検索](https://www.microsoft.com)")
        XCTAssertEqual(parser.transformToHtml(), "<ol start=\"1\"><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li></ol>")
    }
    
    func testNonLatinCharacters_NumberedListWithLinkLeadingText() {
        let parser = MarkDownParser("It's not OK!\r1. Click [以前の製品のリンクで検索](https://www.microsoft.com)\r2. Click [以前の製品のリンクで検索](https://www.microsoft.com)")
        XCTAssertEqual(parser.transformToHtml(), "<p>It's not OK!</p><ol start=\"1\"><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li></ol>")
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterNumericIntraWordEmphasis() {
        let parser = MarkDownParser("5*6*78")
        XCTAssertEqual(parser.transformToHtml(), "<p>5<em>6</em>78</p>")
    }
    
    func testEmphasisDelimiterTest_ValidDelimitersSurroundedByPunctuationTest() {
        let parser = MarkDownParser("*(*foo*)*")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>(<em>foo</em>)</em></p>")
    }
    
    func testEmphasisDelimiterTest_ValidIntraWordEmphasisTest() {
        let parser = MarkDownParser("*foo*bar")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>foo</em>bar</p>")
    }
    
    func testEmphasisDelimiterTest_RightDelimiterFollowedByPunctuationValidTest() {
        let parser = MarkDownParser("_(bar)_.")
        XCTAssertEqual(parser.transformToHtml(), "<p><em>(bar)</em>.</p>")
    }
     */
}
