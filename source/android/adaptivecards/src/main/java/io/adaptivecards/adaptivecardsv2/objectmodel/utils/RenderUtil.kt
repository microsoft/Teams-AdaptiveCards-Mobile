package io.adaptivecards.adaptivecardsv2.objectmodel.utils

import android.text.Html
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.URLSpan
import io.adaptivecards.adaptivecardsv2.objectmodel.markdown.MarkDownParser
import io.adaptivecards.renderer.http.UrlPolicy

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
        return removeDisallowedLinks(htmlString)
    }

    /**
     * Strips every [URLSpan] whose scheme is not permitted by [UrlPolicy].
     *
     * Link text comes from a remote card author and `URLSpan.onClick` launches an implicit
     * `ACTION_VIEW` intent for whatever URL it holds. Removing the span here covers every way the
     * platform can activate it rather than guarding each activation site individually.
     */
    private fun removeDisallowedLinks(htmlString: Spanned): Spanned {
        val spans = htmlString.getSpans(0, htmlString.length, URLSpan::class.java)
        if (spans.none { !UrlPolicy.isAllowedNavigationUrl(it.url) }) {
            return htmlString
        }

        // The span instances are copied by value into the builder, so look the replacements up from
        // the copy rather than reusing the instances obtained from the original Spanned.
        val sanitized = SpannableStringBuilder(htmlString)
        sanitized.getSpans(0, sanitized.length, URLSpan::class.java)
            .filterNot { UrlPolicy.isAllowedNavigationUrl(it.url) }
            .forEach { sanitized.removeSpan(it) }
        return sanitized
    }
}