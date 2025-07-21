import com.example.ac_sdk.objectmodel.utils.RenderUtil
import org.junit.Assert.assertEquals
import org.junit.Test

class MarkDownTest {

    @Test
    fun handlesEmptyString() {
        val textWithNewLines = ""
        val expectedHtml = ""

        val html = RenderUtil.handleSpecialText(textWithNewLines).toString()
        assertEquals(expectedHtml, html)
    }

    @Test
    fun handlesOnlyLineBreaks() {
        val textWithNewLines = "\n\r\r\n\n"
        val expectedHtml = ""

        val html = RenderUtil.handleSpecialText(textWithNewLines).toString()

        assertEquals(expectedHtml, html)
    }

    @Test
    fun handlesMixedContent() {
        val textWithNewLines = "Line1\nLine2\r\nLine3\rLine4"
        val expectedHtml = "Line1\nLine2\nLine3\nLine4"

        val html = RenderUtil.handleSpecialText(textWithNewLines).toString()

        assertEquals(expectedHtml, html)
    }

    @Test
    fun handlesHtmlTags() {
        val textWithNewLines = "<b>Bold</b>\n<i>Italic</i>"
        val expectedHtml = "<b>Bold</b>\n<i>Italic</i>"

        val html = RenderUtil.handleSpecialText(textWithNewLines).toString()

        assertEquals(expectedHtml, html)
    }

    @Test
    @Throws(Exception::class)
    fun testNumberedListIncrementsCorrectly() {
        val textWithNewLines = "18. Green\r18. Orange\r18. Blue"
        // This looks counter intuitive but without the replacement of '\n\r' for "<br/>" the
        // output will only contain a blank space where '\n' is expected
        val expectedHtml = "18. Green\n19. Orange\n20. Blue"

        val html: String = RenderUtil.handleSpecialText(textWithNewLines).toString()

        assertEquals(expectedHtml, html)
    }

    @Test
    @Throws(java.lang.Exception::class)
    fun testNumberedListHonoursStart() {
        val textWithNewLines = "18. Gr\r18. Or";
        // This looks counter intuitive but without the replacement of '\n\r' for "<br/>" the
        // output will only contain a blank space where '\n' is expected
        val expectedHtml = "18. Gr\n19. Or";

        val html: String = RenderUtil.handleSpecialText(textWithNewLines).toString()

        assertEquals(expectedHtml, html)
    }
}