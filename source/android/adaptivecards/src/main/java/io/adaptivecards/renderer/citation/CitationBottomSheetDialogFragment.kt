package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.drawable.Drawable
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
import androidx.core.net.toUri
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
import androidx.fragment.app.FragmentManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import io.adaptivecards.R
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.shape.CornerFamily
import com.google.android.material.shape.MaterialShapeDrawable
import com.google.android.material.shape.ShapeAppearanceModel
import io.adaptivecards.renderer.Utils
import io.adaptivecards.renderer.Utils.dpToPx


class CitationBottomSheetDialogFragment(
    private val context: Context,
    private val citationText: SpannableStringBuilder,
    private val title: String,
    private val keywords: String,
    private val abstract: String,
    private val iconDrawable: Drawable?,
    private val url: String?,
    private val bottomSheetTextColor: String,
    private val bottomSheetKeywordsColor: String,
    private val bottomSheetMoreDetailColor: String,
    private val bottomSheetBackgroundColor: String,
    private val dividerColor: String,
    private val onTitleClickListener: (() -> Unit)?,
    private val onMoreDetailsClickListener: ((Int?) -> Unit)?
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
        header.setTextColor(bottomSheetTextColor.toColorInt())

        val divider = view.findViewById<View>(R.id.divider)
        divider.setBackgroundColor(dividerColor.toColorInt())

        val referenceNumber = view.findViewById<TextView>(R.id.text_reference_number)
        referenceNumber.text = citationText
        referenceNumber.setTextColor(bottomSheetTextColor.toColorInt())

        val icon = view.findViewById<ImageView>(R.id.citation_icon)
        if (iconDrawable != null) {
            icon.setImageDrawable(iconDrawable)
        } else {
            icon.layoutParams.width = 0
            icon.requestLayout()
        }

        val titleView = view.findViewById<TextView>(R.id.citation_title)
        titleView.text = title
        titleView.setTextColor(bottomSheetTextColor.toColorInt())

        // Set click listener: custom listener takes priority, otherwise open URL in browser
        if (url != null) {
            titleView.setOnClickListener {
                if (onTitleClickListener != null) {
                    // Custom behavior provided by caller
                    onTitleClickListener.invoke()
                } else {
                    // Default behavior: open URL in browser
                    val uri = url.toUri()
                    val browserIntent = Intent(Intent.ACTION_VIEW, uri)
                    context.startActivity(browserIntent)
                }
            }
        }

        val keywordsView = view.findViewById<TextView>(R.id.citation_keywords)
        keywordsView.text = keywords
        keywordsView.setTextColor(bottomSheetKeywordsColor.toColorInt())

        val abstractView = view.findViewById<TextView>(R.id.citation_abstract)
        abstractView.text = abstract
        abstractView.setTextColor(bottomSheetTextColor.toColorInt())

        onMoreDetailsClickListener?.let { listener ->
            val moreDetails = view.findViewById<TextView>(R.id.citation_more_details)
            moreDetails.visibility = View.VISIBLE
            moreDetails.setTextColor(bottomSheetMoreDetailColor.toColorInt())
            moreDetails.setOnClickListener {
                val bottomSheet =
                    dialog?.findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)
                listener.invoke(bottomSheet?.height)
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
            fillColor = ColorStateList.valueOf(bottomSheetBackgroundColor.toColorInt())
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

    companion object {
        const val TAG = "CitationBottomSheetDialog"

        /**
         * Shows the citation bottom sheet dialog.
         *
         * @param fragmentManager FragmentManager to show the dialog
         * @param config Configuration object containing all citation data and UI parameters
         */
        @JvmStatic
        fun show(
            fragmentManager: FragmentManager,
            config: CitationBottomSheetConfig
        ) {
            // Create factory with config parameters
            val factory = object : FragmentFactory() {
                override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
                    return when (className) {
                        CitationBottomSheetDialogFragment::class.java.name -> CitationBottomSheetDialogFragment(
                            config.context,
                            config.citationText,
                            config.title,
                            config.keywords,
                            config.abstract,
                            config.iconDrawable,
                            config.url,
                            config.bottomSheetTextColor,
                            config.bottomSheetKeywordsColor,
                            config.bottomSheetMoreDetailColor,
                            config.bottomSheetBackgroundColor,
                            config.dividerColor,
                            config.onTitleClickListener,
                            config.onMoreDetailsClickListener
                        )
                        else -> super.instantiate(classLoader, className)
                    }
                }
            }

            // Set factory and create fragment
            fragmentManager.fragmentFactory = factory
            val fragment = factory.instantiate(
                ClassLoader.getSystemClassLoader(),
                CitationBottomSheetDialogFragment::class.java.name
            )

            // Show the dialog
            if (fragment is CitationBottomSheetDialogFragment) {
                fragment.show(fragmentManager, TAG)
            }
        }
    }
}

/**
 * Configuration class for CitationBottomSheetDialogFragment.
 *
 * Create an instance of this class with your citation data and pass it to
 * CitationBottomSheetDialogFragment.show() to display the dialog.
 *
 * @param context Android Context
 * @param citationText Citation text as SpannableStringBuilder (can include custom formatting)
 * @param title Citation title
 * @param keywords Keywords string (e.g., "keyword1 | keyword2 | keyword3")
 * @param abstract Citation abstract/description text
 * @param iconDrawable Optional icon drawable
 * @param url Optional URL - opens in browser when title clicked (unless custom listener provided)
 * @param bottomSheetTextColor Hex color string for main text (e.g., "#FFFFFF")
 * @param bottomSheetKeywordsColor Hex color string for keywords text
 * @param bottomSheetMoreDetailColor Hex color string for "More Details" link
 * @param bottomSheetBackgroundColor Hex color string for background
 * @param dividerColor Hex color string for divider line
 * @param onTitleClickListener Optional: Custom click handler for title (overrides default URL opening)
 * @param onMoreDetailsClickListener Optional: Click handler for "More Details" button (button hidden if null)
 */
data class CitationBottomSheetConfig(
    val context: Context,
    val citationText: SpannableStringBuilder,
    val title: String,
    val keywords: String,
    val abstract: String,
    val iconDrawable: Drawable? = null,
    val url: String? = null,
    val bottomSheetTextColor: String,
    val bottomSheetKeywordsColor: String,
    val bottomSheetMoreDetailColor: String,
    val bottomSheetBackgroundColor: String,
    val dividerColor: String,
    val onTitleClickListener: (() -> Unit)? = null,
    val onMoreDetailsClickListener: ((Int?) -> Unit)? = null
)
