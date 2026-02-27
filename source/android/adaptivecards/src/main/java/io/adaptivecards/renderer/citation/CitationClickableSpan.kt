package io.adaptivecards.renderer.citation

import android.content.Context
import android.content.Intent
import android.text.SpannableStringBuilder
import android.text.style.ClickableSpan
import android.view.View
import androidx.core.net.toUri
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.ReferenceType
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.registration.CardRendererRegistration

class CitationClickableSpan(
    private val citationText: String,
    val reference: References,
    val context: Context,
    val renderedCard: RenderedAdaptiveCard,
    val cardActionHandler: ICardActionHandler,
    val fragmentManager: FragmentManager,
    val hostConfig: HostConfig,
    val renderArgs: RenderArgs
) : ClickableSpan() {

    override fun onClick(view: View) {
        showCitationReference()
    }

    private fun showCitationReference() {
        // Prepare formatted citation text
        val text = SpannableStringBuilder(citationText)
        CitationUtil.applyCitationSpanForBottomSheet(context, text, hostConfig)

        // Get icon drawable
        val iconDrawable = CardRendererRegistration.getInstance()
            .drawableResolver?.getDrawableForReferenceIcon(context, reference.GetIcon(), hostConfig)

        // Create more details click listener if content is available
        val hasMoreDetails = reference.GetType() == ReferenceType.AdaptiveCard && reference.GetContent() != null
        val onMoreDetailsClickListener: ((Int?) -> Unit)? = if (hasMoreDetails) {
            { sheetHeight -> showCitationCard(sheetHeight, reference.GetContent()) }
        } else {
            null
        }

        // Create config and show the dialog
        val citationBlock = hostConfig.GetCitationBlock()
        val config = CitationBottomSheetConfig(
            context = context,
            citationText = text,
            title = reference.GetTitle() ?: "",
            keywords = reference.GetKeywords()?.joinToString(" | ") ?: "",
            abstract = reference.GetAbstract() ?: "",
            iconDrawable = iconDrawable,
            url = reference.GetUrl(),
            bottomSheetTextColor = citationBlock.bottomSheetTextColor,
            bottomSheetKeywordsColor = citationBlock.bottomSheetKeywordsColor,
            bottomSheetMoreDetailColor = citationBlock.bottomSheetMoreDetailColor,
            bottomSheetBackgroundColor = citationBlock.bottomSheetBackgroundColor,
            dividerColor = citationBlock.dividerColor,
            onTitleClickListener = null, // Let bottom sheet handle default browser opening
            onMoreDetailsClickListener = onMoreDetailsClickListener
        )

        CitationBottomSheetDialogFragment.show(fragmentManager, config)
    }

    private fun showCitationCard(minHeight: Int?, adaptiveCard: io.adaptivecards.objectmodel.AdaptiveCard) {
        // Create config and show the citation card
        val config = CitationCardConfig(
            context = context,
            minHeight = minHeight,
            adaptiveCard = adaptiveCard,
            renderedAdaptiveCard = renderedCard,
            actionHandler = cardActionHandler,
            hostConfig = hostConfig,
            renderArgs = renderArgs
        )

        CitationCardFragment.show(fragmentManager, config)
    }
}
