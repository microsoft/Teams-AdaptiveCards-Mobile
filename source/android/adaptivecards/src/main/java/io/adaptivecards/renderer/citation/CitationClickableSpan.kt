package io.adaptivecards.renderer.citation

import android.content.Context
import android.text.style.ClickableSpan
import android.view.View
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

class CitationClickableSpan(
    val reference: References,
    val context: Context,
    val renderedCard: RenderedAdaptiveCard,
    val cardActionHandler: ICardActionHandler,
    val fragmentManager: FragmentManager,
    val hostConfig: HostConfig,
    val renderArgs: RenderArgs
) : ClickableSpan() {

    override fun onClick(view: View) {
        val card = reference.GetContent()
        if (card != null) {
            showCitationCard(card)
        } else {
            showCitationReference()
        }
    }

    private fun showCitationReference() {
        val factory = CitationBottomSheetDialogFragmentFactory(
                context,
                reference,
                renderedCard,
                cardActionHandler,
                hostConfig,
                renderArgs
        )
        fragmentManager.fragmentFactory = factory

        val fragment = factory.instantiate(
                ClassLoader.getSystemClassLoader(),
                CitationBottomSheetDialogFragment::class.java.name
        )

        if (fragment is CitationBottomSheetDialogFragment) {
            fragment.show(fragmentManager, CitationBottomSheetDialogFragment.TAG)
        }
    }

    private fun showCitationCard(adaptiveCard: AdaptiveCard) {
        val factory = CitationCardFragmentFactory(
                context,
                adaptiveCard,
                renderedCard,
                cardActionHandler,
                hostConfig,
                renderArgs
        )
        fragmentManager.fragmentFactory = factory

        val fragment = factory.instantiate(
                ClassLoader.getSystemClassLoader(),
                CitationCardFragment::class.java.name
        )

        if (fragment is CitationCardFragment) {
            fragment.show(fragmentManager, CitationCardFragment.TAG)
        }
    }
}
