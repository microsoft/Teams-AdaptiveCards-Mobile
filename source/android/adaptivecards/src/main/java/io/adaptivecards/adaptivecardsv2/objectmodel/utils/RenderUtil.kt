package io.adaptivecards.adaptivecardsv2.objectmodel.utils

import android.text.Html
import android.text.Spanned
import android.text.style.URLSpan
import io.adaptivecards.adaptivecardsv2.objectmodel.markdown.MarkDownParser

object RenderUtil {


    class SpecialTextHandleResult
        (val htmlString: CharSequence, val hasLinks: Boolean, val isALink: Boolean)

    fun handleSpecialText(textWithFormattedDates: String): CharSequence {
        val spanned: Spanned = getSpecialTextSpans(textWithFormattedDates)
        return trimHtmlString(spanned)
    }

    private fun firstAndLastSpansAreTheSame(spanned: Spanned): Boolean {
        val firstSpan = spanned.getSpans(0, 1, URLSpan::class.java)
        val lastSpan = spanned.getSpans(spanned.length - 2, spanned.length, URLSpan::class.java)
        // If there's only one span, then the first and last characters should each have that span.
        return firstSpan.size == 1 && lastSpan.size == 1
    }

    fun handleSpecialTextAndQueryLinks(textWithFormattedDates: String): SpecialTextHandleResult {
        val spanned: Spanned = getSpecialTextSpans(textWithFormattedDates)
        val spans = spanned.getSpans(0, spanned.length, URLSpan::class.java)
        val isALink = if (spans.size == 1) firstAndLastSpansAreTheSame(spanned) else false
        return SpecialTextHandleResult(trimHtmlString(spanned), spans.isNotEmpty(), isALink)
    }


    private fun trimHtmlString(htmlString: Spanned): CharSequence {
        var numToRemoveFromEnd = 0
        var numToRemoveFromStart = 0

        for (i in htmlString.length - 1 downTo 0) {
            if (htmlString[i] == '\n') {
                numToRemoveFromEnd++
            } else {
                break
            }
        }

        for (element in htmlString) {
            if (element == '\n') {
                numToRemoveFromStart++
            } else {
                break
            }
        }

        // Sanity check
        if (numToRemoveFromStart + numToRemoveFromEnd >= htmlString.length) {
            return htmlString
        }

        return htmlString.subSequence(numToRemoveFromStart, htmlString.length - numToRemoveFromEnd)
    }

    private fun getSpecialTextSpans(textWithFormattedDates: String): Spanned {
        val markdownParser = MarkDownParser(textWithFormattedDates)
        var textString: String = markdownParser.transformToHtml()
        // preprocess string to change <li> to <listItem> so we get a chance to handle them
        textString = textString.replace("<li>", "<listItem>")
        textString = textString.replace(Regex("(${System.lineSeparator()}|\\r\\n|\\n\\r|\\r|\\n)"), "<br/>")
        val htmlString =
            Html.fromHtml(
                textString,
                Html.FROM_HTML_MODE_COMPACT,
                null,
                UlTagHandler()
            )
        return htmlString
    }
}