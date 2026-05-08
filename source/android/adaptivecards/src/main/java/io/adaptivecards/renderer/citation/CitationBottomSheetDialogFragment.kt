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
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.core.graphics.Insets
import android.util.TypedValue
import android.content.res.Configuration


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

    override fun getTheme(): Int {
        return R.style.CitationBottomSheetTheme
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

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
    }

    override fun onStart() {
        super.onStart()

        // Setup edge-to-edge in onStart() when dialog is fully initialized
        setupEdgeToEdgeBottomSheet()

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
        // With edge-to-edge, the sheet extends behind the nav bar and content has padding,
        // so we use full screen height for calculations
        val minHeight = screenHeight / 3
        val maxHeight = screenHeight / 2
        return contentHeight.coerceIn(minHeight, maxHeight)
    }

    /**
     * Set up edge-to-edge for this bottom sheet dialog.
     * Based on Teams Android BottomSheetEdgeToEdgeHelper pattern.
     */
    private fun setupEdgeToEdgeBottomSheet() {
        val dialog = dialog as? BottomSheetDialog
        if (dialog == null) {
            Log.d(TAG, "setupEdgeToEdgeBottomSheet: dialog is null")
            return
        }

        val contentView = view
        if (contentView == null) {
            Log.d(TAG, "setupEdgeToEdgeBottomSheet: contentView is null")
            return
        }

        Log.d(TAG, "setupEdgeToEdgeBottomSheet: Starting setup")

        // Configure window for edge-to-edge
        dialog.window?.let { window ->
            Log.d(TAG, "Configuring window")
            configureWindow(window)
            configureNavBarAppearance(window)
        }

        // Enable edge-to-edge (disable fitsSystemWindows on Material's container/coordinator)
        Log.d(TAG, "Setting edge-to-edge enabled")
        setEdgeToEdgeEnabled(dialog)

        // Apply bottom insets to the first descendant with a background
        val targetView = findInsetTarget(contentView)
        Log.d(TAG, "Applying bottom insets to: ${targetView.javaClass.simpleName}")
        applyBottomInsets(targetView)

        Log.d(TAG, "setupEdgeToEdgeBottomSheet: Setup complete")
    }

    /**
     * Configure window for edge-to-edge.
     */
    private fun configureWindow(window: android.view.Window) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        @Suppress("DEPRECATION")
        window.navigationBarColor = android.graphics.Color.TRANSPARENT
    }

    /**
     * Configure navigation bar appearance for seamless edge-to-edge on API 29+.
     */
    private fun configureNavBarAppearance(window: android.view.Window) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
        // Detect theme based on isLightTheme attribute or UI mode
        val typedValue = TypedValue()
        val isLightTheme = if (window.context.theme.resolveAttribute(android.R.attr.isLightTheme, typedValue, true)) {
            typedValue.data != 0
        } else {
            (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) != Configuration.UI_MODE_NIGHT_YES
        }

        WindowCompat.getInsetsController(window, window.decorView)?.let {
            it.isAppearanceLightStatusBars = isLightTheme
            it.isAppearanceLightNavigationBars = isLightTheme
        }
    }

    /**
     * Enable edge-to-edge by disabling fitsSystemWindows on Material's container and coordinator.
     * Equivalent to Material 1.4.0+'s BottomSheetDialog.setEdgeToEdgeEnabled(true).
     */
    private fun setEdgeToEdgeEnabled(dialog: Dialog) {
        dialog.findViewById<View>(com.google.android.material.R.id.container)
            ?.fitsSystemWindows = false
        dialog.findViewById<View>(com.google.android.material.R.id.coordinator)
            ?.fitsSystemWindows = false
    }

    /**
     * Find the first descendant with a non-null background (max depth 3).
     * This ensures the nav-bar inset lands on the styled container.
     */
    private fun findInsetTarget(root: View, maxDepth: Int = 3): View {
        if (root.background != null) return root
        if (maxDepth <= 0 || root !is ViewGroup) return root
        for (i in 0 until root.childCount) {
            val target = findInsetTarget(root.getChildAt(i), maxDepth - 1)
            if (target.background != null) return target
        }
        return root
    }

    /**
     * Apply bottom navigation bar insets to the target view.
     * Preserves existing padding and adds nav bar inset on top.
     * Uses combined system bars and cutout insets to handle display cutouts (notches, camera holes).
     */
    private fun applyBottomInsets(targetView: View) {
        val originalPaddingBottom = targetView.paddingBottom
        ViewCompat.setOnApplyWindowInsetsListener(targetView) { v, insets ->
            // Use combined insets (system bars + display cutout) to handle notches/cutouts
            val combinedInsets = getCombinedSysBarAndCutoutInsets(insets)
            v.updatePadding(bottom = originalPaddingBottom + combinedInsets.bottom)
            insets
        }
        targetView.requestApplyInsets()
    }

    /**
     * Returns the maximum of system bar insets and display cutout insets.
     * This ensures content is not obscured by notches, camera cutouts, or navigation bars.
     */
    private fun getCombinedSysBarAndCutoutInsets(windowInsets: WindowInsetsCompat): Insets {
        val sysBarInsets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
        val cutoutInsets = windowInsets.getInsets(WindowInsetsCompat.Type.displayCutout())
        return Insets.max(sysBarInsets, cutoutInsets)
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
