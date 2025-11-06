package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.os.Bundle
import android.text.SpannableStringBuilder
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.ImageView
import android.widget.TextView
import androidx.core.graphics.toColorInt
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
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.shape.CornerFamily
import com.google.android.material.shape.MaterialShapeDrawable
import com.google.android.material.shape.ShapeAppearanceModel
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.ReferenceType
import io.adaptivecards.renderer.Utils
import io.adaptivecards.renderer.Utils.dpToPx
import io.adaptivecards.renderer.citation.CitationUtil.getDrawableForIcon


class CitationBottomSheetDialogFragment(
    private val context: Context,
    private val citationText: String,
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

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {

        val view = inflater.inflate(R.layout.citation_bottom_sheet_layout, container, false)

        val header = view.findViewById<TextView>(R.id.header)
        header.setTextColor(hostConfig.GetCitationBlock().bottomSheetTextColor.toColorInt())

        val divider = view.findViewById<View>(R.id.divider)
        divider.setBackgroundColor(hostConfig.GetCitationBlock().dividerColor.toColorInt())

        val referenceNumber = view.findViewById<TextView>(R.id.text_reference_number)

        val text = SpannableStringBuilder(citationText)
        CitationUtil.applyCitationSpanForBottomSheet(context, text, hostConfig)
        referenceNumber.text = text

        referenceNumber.setTextColor(hostConfig.GetCitationBlock().bottomSheetTextColor.toColorInt())

        val icon = view.findViewById<ImageView>(R.id.citation_icon)
        icon.setImageDrawable(citationReference.getDrawableForIcon(context, hostConfig))

        val title = view.findViewById<TextView>(R.id.citation_title)
        title.text = citationReference.GetTitle()
        title.setTextColor(hostConfig.GetCitationBlock().bottomSheetTextColor.toColorInt())
        title.setOnClickListener {
            val url = citationReference.GetUrl()?.toUri()
            url?.let {
                val browserIntent = Intent(Intent.ACTION_VIEW, url)
                this@CitationBottomSheetDialogFragment.startActivity(browserIntent)
            }
        }

        val keywords = view.findViewById<TextView>(R.id.citation_keywords)
        keywords.text = citationReference.GetKeywords().joinToString(" | ")
        keywords.setTextColor(hostConfig.GetCitationBlock().bottomSheetKeywordsColor.toColorInt())

        val abstract = view.findViewById<TextView>(R.id.citation_abstract)
        abstract.text = citationReference.GetAbstract()
        abstract.setTextColor(hostConfig.GetCitationBlock().bottomSheetTextColor.toColorInt())

        if (citationReference.GetType() == ReferenceType.AdaptiveCard && citationReference.GetContent() != null) {
            val moreDetails = view.findViewById<TextView>(R.id.citation_more_details)
            moreDetails.visibility = View.VISIBLE
            moreDetails.setTextColor(hostConfig.GetCitationBlock().bottomSheetMoreDetailColor.toColorInt())
            moreDetails.setOnClickListener {
                val bottomSheet =
                    dialog?.findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)
                showCitationCard(bottomSheet?.height, citationReference.GetContent())
            }
        }

        return view
    }

    override fun onStart() {
        super.onStart()

        val dialog = dialog as? BottomSheetDialog
        val bottomSheet =
            dialog?.findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)

        bottomSheet?.background = MaterialShapeDrawable().apply {
            shapeAppearanceModel = ShapeAppearanceModel.builder()
                .setTopLeftCorner(CornerFamily.ROUNDED, 10f.dpToPx(context))
                .setTopRightCorner(CornerFamily.ROUNDED, 10f.dpToPx(context))
                .setBottomLeftCorner(CornerFamily.ROUNDED, 0f)
                .setBottomRightCorner(CornerFamily.ROUNDED, 0f)
                .build()
            fillColor = ColorStateList.valueOf(hostConfig.GetCitationBlock().bottomSheetBackgroundColor.toColorInt())
        }

        bottomSheet?.viewTreeObserver?.addOnGlobalLayoutListener(object :
            ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                bottomSheet.viewTreeObserver.removeOnGlobalLayoutListener(this)
                val height = bottomSheet.height
                Log.d(CitationCardFragment.Companion.TAG, "Bottom sheet height: $height")

                bottomSheet?.let {
                    val behavior = BottomSheetBehavior.from(it)

                    it.layoutParams.height = getPeekHeight(height)
                    it.requestLayout()

                    // Set to collapsed and disable other states
                    behavior.state = BottomSheetBehavior.STATE_COLLAPSED
                    behavior.peekHeight = getPeekHeight(height)
                    behavior.isDraggable = false
                }
            }
        })
    }

    private fun getPeekHeight(contentHeight: Int): Int {
        val screenHeight = Utils.getScreenAvailableHeight(context)
        val minHeight = screenHeight / 3
        val maxHeight = screenHeight / 2
        return contentHeight.coerceIn(minHeight, maxHeight)
    }

    private fun showCitationCard(minHeight: Int?, adaptiveCard: AdaptiveCard) {
        val factory = CitationCardFragmentFactory(
            context,
            minHeight,
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
    private val citationText: String,
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
                citationText,
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
