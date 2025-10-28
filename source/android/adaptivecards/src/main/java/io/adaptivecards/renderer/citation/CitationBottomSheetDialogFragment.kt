package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import io.adaptivecards.R
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import androidx.core.net.toUri
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.ReferenceType
import io.adaptivecards.renderer.citation.CitationUtil.getDrawableForIcon


class CitationBottomSheetDialogFragment(
    private val context: Context,
    private val citationReference: References,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val fragmentManager: FragmentManager,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : BottomSheetDialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState) as BottomSheetDialog
        return dialog
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {

        val view = inflater.inflate(R.layout.citation_bottom_sheet_layout, container, false)

        val title = view.findViewById<TextView>(R.id.citation_title)
        val abstract = view.findViewById<TextView>(R.id.citation_abstract)
        val keywords = view.findViewById<TextView>(R.id.citation_keywords)
        val moreDetails = view.findViewById<TextView>(R.id.citation_more_details)
        val icon = view.findViewById<ImageView>(R.id.citation_icon)

        icon.setImageResource(citationReference.getDrawableForIcon())

        title.text = citationReference.GetTitle()
        abstract.text = citationReference.GetAbstract()
        keywords.text = citationReference.GetKeywords().joinToString(" | ")

        title.setOnClickListener {
            val url = citationReference.GetUrl()?.toUri()
            url?.let {
                val browserIntent = Intent(Intent.ACTION_VIEW, url)
                this@CitationBottomSheetDialogFragment.startActivity(browserIntent)
            }
        }

        if (citationReference.GetType() == ReferenceType.AdaptiveCard && citationReference.GetContent() != null) {
            moreDetails.visibility = View.VISIBLE
            moreDetails.setOnClickListener {
                showCitationCard(citationReference.GetContent())
            }
        }

        return view
    }

    private fun showCitationCard(adaptiveCard: AdaptiveCard) {
        val factory = CitationCardFragmentFactory(
                context,
                adaptiveCard,
                renderedAdaptiveCard,
                actionHandler,
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

    companion object {
        const val TAG = "CitationBottomSheetDialog"
    }
}

class CitationBottomSheetDialogFragmentFactory(
    private val context: Context,
    private val citationReference: References,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val fragmentManager: FragmentManager,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : FragmentFactory() {

    override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
        return when (className) {
            CitationBottomSheetDialogFragment::class.java.name -> CitationBottomSheetDialogFragment(
                    context,
                    citationReference,
                    renderedAdaptiveCard,
                    fragmentManager,
                    actionHandler,
                    hostConfig,
                    renderArgs
            )

            else -> super.instantiate(classLoader, className)
        }
    }
}
