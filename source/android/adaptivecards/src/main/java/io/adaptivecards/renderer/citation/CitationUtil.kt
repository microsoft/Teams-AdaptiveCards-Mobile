package io.adaptivecards.renderer.citation

import android.content.Context
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.text.style.URLSpan
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.CitationRun
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.Inline
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.readonly.DateTimeParser
import io.adaptivecards.renderer.view.RoundedBackgroundSpan
import java.util.Locale

object CitationUtil {

    private const val CITATION_SPAN_PADDING_HORIZONTAL = 4f
    private const val CITATION_SPAN_PADDING_VERTICAL = 0f
    private const val CITATION_SPAN_CORNER_RADIUS = 4f
    private const val CITATION_SPAN_MARGIN_HORIZONTAL = 2f

    @JvmStatic
    fun isCitationUrlSpansPresent(htmlString: CharSequence) : Boolean {
        val paragraph = SpannableStringBuilder(htmlString)
        val urlSpans = paragraph.getSpans(0, paragraph.length, URLSpan::class.java)
        val citeRegex = Regex("""^cite:(.+)$""")
        return urlSpans.any { citeRegex.matches(it.url) }
    }

    @JvmStatic
    fun handleCitationSpansForTextBlock(
        context: Context,
        htmlString: CharSequence,
        textColor: Int,
        backgroundColor: Int,
        renderedCard: RenderedAdaptiveCard,
        cardActionHandler: ICardActionHandler,
        fragmentManager: FragmentManager,
        hostConfig: HostConfig,
        renderArgs: RenderArgs) : SpannableStringBuilder {
        val paragraph = SpannableStringBuilder(htmlString)
        val urlSpans = paragraph.getSpans(0, paragraph.length, URLSpan::class.java)
        val citeRegex = Regex("""^cite:(.+)$""")

        for (span in urlSpans) {
            val url = span.url
            val start = paragraph.getSpanStart(span)
            val end = paragraph.getSpanEnd(span)
            val matchResult = citeRegex.matchEntire(url)

            if (matchResult != null) {
                // Remove the URLSpan regardless
                paragraph.removeSpan(span)

                val index = matchResult.groupValues[1].toIntOrNull() ?: -1

                applyCitationSpans(
                        context,
                        start,
                        end,
                        paragraph,
                        textColor,
                        backgroundColor,
                        renderedCard,
                        index,
                        cardActionHandler,
                        fragmentManager,
                        hostConfig,
                        renderArgs
                )
            }
        }
        return paragraph
    }

    @JvmStatic
    fun applyCitationSpans(
        context: Context,
        spanStart: Int,
        spanEnd: Int,
        paragraph : SpannableStringBuilder,
        textColor: Int,
        backgroundColor: Int,
        renderedCard: RenderedAdaptiveCard,
        referenceIndex: Int,
        cardActionHandler: ICardActionHandler,
        fragmentManager: FragmentManager,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ) {
        val citationReference = getCitationReference(referenceIndex, renderedCard)

        // Apply styling related spans for citations
        paragraph.setSpan(ForegroundColorSpan(textColor), spanStart, spanEnd, Spannable.SPAN_INCLUSIVE_EXCLUSIVE)

        if (citationReference != null) {
            val roundedBackgroundSpan = RoundedBackgroundSpan(
                    context,
                    backgroundColor,
                    textColor,
                    CITATION_SPAN_CORNER_RADIUS,
                    CITATION_SPAN_PADDING_HORIZONTAL,
                    CITATION_SPAN_PADDING_VERTICAL,
                    CITATION_SPAN_MARGIN_HORIZONTAL
            )
            paragraph.setSpan(roundedBackgroundSpan, spanStart, spanEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)

            val clickableSpan = CitationClickableSpan(citationReference, context, renderedCard, cardActionHandler, fragmentManager,
                    hostConfig, renderArgs)

            paragraph.setSpan(clickableSpan, spanStart, spanEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
    }

    @JvmStatic
    fun Inline.castToCitationRun(): CitationRun {
        return if (this is CitationRun) {
            this
        } else {
            CitationRun.dynamic_cast(this) ?: throw InternalError("Unable to convert BaseCardElement to TextBlock object model.")
        }
    }

    @JvmStatic
    fun CitationRun.getCitationText(renderedCard: RenderedAdaptiveCard) : String {
        val parser = DateTimeParser(Locale.getDefault().language)
        val formattedText = parser.GenerateString(this.GetTextForDateParsing())
        return renderedCard.replaceStringResources(formattedText)
    }

    @JvmStatic
    fun getCitationReference(referenceIndex: Int, renderedCard: RenderedAdaptiveCard): References? {
        val index = referenceIndex - 1
        return renderedCard.adaptiveCard.GetReferences()
            ?.takeIf { index in it.indices }
            ?.get(index)
    }
}