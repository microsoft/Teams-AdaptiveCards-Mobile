package io.adaptivecards.renderer.citation

import android.content.Context
import android.graphics.Color
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.URLSpan
import androidx.core.graphics.toColorInt
import androidx.fragment.app.FragmentManager
import io.adaptivecards.R
import io.adaptivecards.objectmodel.CitationRun
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.Inline
import io.adaptivecards.objectmodel.ReferenceIcon
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.citation.CitationUtil.isCitationUrlSpansPresent
import io.adaptivecards.renderer.readonly.DateTimeParser
import io.adaptivecards.renderer.view.RoundedBackgroundSpan
import java.util.Locale

object CitationUtil {

    @JvmStatic
    fun isCitationUrlSpansPresent(htmlString: CharSequence): Boolean {
        val paragraph = SpannableStringBuilder(htmlString)
        val urlSpans = paragraph.getSpans(0, paragraph.length, URLSpan::class.java)
        val citeRegex = Regex("""^cite:(.+)$""")
        return urlSpans.any { citeRegex.matches(it.url) }
    }

    @JvmStatic
    fun handleCitationSpansForTextBlock(
        context: Context,
        htmlString: CharSequence,
        renderedCard: RenderedAdaptiveCard,
        cardActionHandler: ICardActionHandler,
        fragmentManager: FragmentManager,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): SpannableStringBuilder {
        val paragraph = SpannableStringBuilder(htmlString)

        if (!isCitationUrlSpansPresent(htmlString)) {
            return paragraph
        }

        val urlSpans = paragraph.getSpans(0, paragraph.length, URLSpan::class.java)
        val citeRegex = Regex("""^cite:(.+)$""")

        for (span in urlSpans) {
            val url = span.url
            val start = paragraph.getSpanStart(span)
            val end = paragraph.getSpanEnd(span)
            val spanText = paragraph.subSequence(start, end).toString()
            val matchResult = citeRegex.matchEntire(url)

            if (matchResult != null) {
                // Remove the URLSpan regardless
                paragraph.removeSpan(span)

                val index = matchResult.groupValues[1].toIntOrNull() ?: -1

                applyCitationSpans(
                    context,
                    start,
                    end,
                    spanText,
                    paragraph,
                    hostConfig.GetCitationBlock().textColor.toColorInt(),
                    hostConfig.GetCitationBlock().backgroundColor.toColorInt(),
                    hostConfig.GetCitationBlock().borderColor.toColorInt(),
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
        citationText: String,
        paragraph: SpannableStringBuilder,
        textColor: Int,
        backgroundColor: Int,
        borderColor: Int,
        renderedCard: RenderedAdaptiveCard,
        referenceIndex: Int,
        cardActionHandler: ICardActionHandler,
        fragmentManager: FragmentManager,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ) {
        val citationReference = getCitationReference(referenceIndex, renderedCard)

        if (citationReference != null) {
            applyCitationBackgroundSpan(
                context,
                paragraph,
                textColor,
                backgroundColor,
                borderColor,
                spanStart,
                spanEnd
            )

            val clickableSpan = CitationClickableSpan(
                citationText,
                citationReference,
                context,
                renderedCard,
                cardActionHandler,
                fragmentManager,
                hostConfig,
                renderArgs
            )

            paragraph.setSpan(clickableSpan, spanStart, spanEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
    }

    @JvmStatic
    fun applyCitationSpanForBottomSheet(
        context: Context,
        paragraph: SpannableStringBuilder,
        hostConfig: HostConfig
    ) {
        applyCitationBackgroundSpan(
                context,
                paragraph,
                hostConfig.GetCitationBlock().textColor.toColorInt(),
                Color.TRANSPARENT,
                hostConfig.GetCitationBlock().borderColor.toColorInt(),
                0,
                paragraph.length,
        )
    }

    @JvmStatic
    private fun applyCitationBackgroundSpan(
        context: Context,
        paragraph: SpannableStringBuilder,
        textColor: Int,
        backgroundColor: Int,
        borderColor: Int,
        spanStart: Int,
        spanEnd: Int
    ) {
        val roundedBackgroundSpan = RoundedBackgroundSpan(
                context,
                textColor,
                backgroundColor,
                borderColor
        )
        paragraph.setSpan(
                roundedBackgroundSpan,
                spanStart,
                spanEnd,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
    }

    @JvmStatic
    fun Inline.castToCitationRun(): CitationRun {
        return if (this is CitationRun) {
            this
        } else {
            CitationRun.dynamic_cast(this)
                ?: throw InternalError("Unable to convert BaseCardElement to TextBlock object model.")
        }
    }

    @JvmStatic
    fun CitationRun.getCitationText(renderedCard: RenderedAdaptiveCard): String {
        val parser = DateTimeParser(Locale.getDefault().language)
        val formattedText = parser.GenerateString(this.GetTextForDateParsing())
        return renderedCard.checkAndReplaceStringResources(formattedText)
    }

    @JvmStatic
    fun getCitationReference(referenceIndex: Int, renderedCard: RenderedAdaptiveCard): References? {
        val index = referenceIndex - 1
        return renderedCard.adaptiveCard.GetReferences()
            ?.takeIf { index in it.indices }
            ?.get(index)
    }
}