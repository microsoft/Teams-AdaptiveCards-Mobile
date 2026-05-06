package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.content.res.ColorStateList
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.graphics.toColorInt
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
import androidx.fragment.app.FragmentManager
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.shape.CornerFamily
import com.google.android.material.shape.MaterialShapeDrawable
import com.google.android.material.shape.ShapeAppearanceModel
import io.adaptivecards.R
import io.adaptivecards.objectmodel.ActionType
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.CardElementType
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.renderer.AdaptiveCardRenderer
import io.adaptivecards.renderer.InsetSide
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Utils
import io.adaptivecards.renderer.Utils.dpToPx
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.applyEdgeToEdgePaddingInsets
import io.adaptivecards.renderer.citation.CitationUtil.applyDrawableColor
import io.adaptivecards.renderer.getCombinedSysBarAndCutoutInsets
import io.adaptivecards.renderer.setupEdgeToEdge

class CitationCardFragment(
    private val context: Context,
    private val minHeight: Int?,
    private val adaptiveCard: AdaptiveCard,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs,
    private val isEdgeToEdgeEnabled: Boolean = false
) : BottomSheetDialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState) as BottomSheetDialog

        // Enable edge-to-edge if enabled
        if (isEdgeToEdgeEnabled) {
            dialog.setupEdgeToEdge()
        }

        return dialog
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val view = inflater.inflate(R.layout.citation_card_bottom_sheet_layout, container, false)

        // Apply edge-to-edge insets if enabled
        if (isEdgeToEdgeEnabled) {
            // Apply horizontal insets to root view
            view.applyEdgeToEdgePaddingInsets(InsetSide.START, InsetSide.END)

            // Apply bottom insets to content layout
            val contentLayout = view.findViewById<LinearLayout>(R.id.adaptiveCard_contentLayout)
            contentLayout.applyEdgeToEdgePaddingInsets(InsetSide.BOTTOM)
        }

        val header = view.findViewById<TextView>(R.id.header)
        header.setTextColor(hostConfig.GetCitationBlock().bottomSheetTextColor.toColorInt())

        val divider = view.findViewById<View>(R.id.divider)
        divider.setBackgroundColor(hostConfig.GetCitationBlock().dividerColor.toColorInt())

        val back = view.findViewById<ImageButton>(R.id.back_button)
        val drawable = ContextCompat.getDrawable(context, R.drawable.ic_icon_back).apply {
            this.applyDrawableColor(hostConfig.GetCitationBlock().iconColor.toColorInt())
        }
        back.setImageDrawable(drawable)

        back.setOnClickListener {
            dismiss()
        }

        val contentLayout = view.findViewById<LinearLayout>(R.id.adaptiveCard_contentLayout)
        //val dialogContentViewId = Util.getViewId(view).toInt()
        renderCitationCard(contentLayout)

        return view
    }

    private fun renderCitationCard(contentLayout: ViewGroup) {
        try {
            val renderArgsUpdated =
                RenderArgs(renderArgs, unsupportedElements, unsupportedActionItems)

            val cardView = AdaptiveCardRenderer.getInstance().internalRender(
                renderedAdaptiveCard,
                context,
                fragmentManager,
                adaptiveCard,
                actionHandler,
                hostConfig,
                false,
                View.NO_ID.toLong(),
                renderArgsUpdated,
                hostConfig.GetCitationBlock().bottomSheetBackgroundColor
            )
            contentLayout.addView(cardView)
        } catch (e: Exception) {
            // Error rendering card content
        }
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
            fillColor =
                ColorStateList.valueOf(hostConfig.GetCitationBlock().bottomSheetBackgroundColor.toColorInt())
        }

        // Apply edge-to-edge insets to bottom sheet if enabled
        if (isEdgeToEdgeEnabled) {
            bottomSheet?.let {
                // Remove default horizontal margins for edge-to-edge
                (it.layoutParams as? ViewGroup.MarginLayoutParams)?.let { params ->
                    params.leftMargin = 0
                    params.rightMargin = 0
                    it.layoutParams = params
                }

                ViewCompat.setOnApplyWindowInsetsListener(it) { v, insets ->
                    val currInsets = insets.getCombinedSysBarAndCutoutInsets()
                    // Apply horizontal insets to bottom sheet
                    v.setPaddingRelative(
                        currInsets.left,
                        it.paddingTop,
                        currInsets.right,
                        it.paddingBottom
                    )
                    insets
                }
                ViewCompat.requestApplyInsets(it)
            }
        }

        bottomSheet?.viewTreeObserver?.addOnGlobalLayoutListener(object :
            ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                bottomSheet.viewTreeObserver.removeOnGlobalLayoutListener(this)
                val height = bottomSheet.height

                bottomSheet.let {
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
        val minHeight = minHeight ?: (screenHeight / 3)
        val maxHeight = screenHeight / 2
        return contentHeight.coerceIn(minHeight, maxHeight)
    }

    companion object {
        const val TAG = "CitationCardFragment"

        private val unsupportedElements = setOf(
            CardElementType.ActionSet,
            CardElementType.AdaptiveCard,
            CardElementType.ChoiceInput,
            CardElementType.ChoiceSetInput,
            CardElementType.DateInput,
            CardElementType.NumberInput,
            CardElementType.RatingInput,
            CardElementType.TimeInput,
            CardElementType.TextInput,
            CardElementType.ToggleInput,
            CardElementType.CompoundButton,
        )

        private val unsupportedActionItems = setOf(
            ActionType.Unsupported,
            ActionType.Execute,
            ActionType.OpenUrl,
            ActionType.Popover,
            ActionType.ShowCard,
            ActionType.Submit,
            ActionType.ToggleVisibility,
            ActionType.Custom,
            ActionType.UnknownAction,
            ActionType.Overflow
        )

        /**
         * Shows the citation card fragment.
         *
         * @param fragmentManager FragmentManager to show the dialog
         * @param config Configuration object containing all citation card data
         */
        @JvmStatic
        fun show(
            fragmentManager: FragmentManager,
            config: CitationCardConfig
        ) {
            // Create factory with config parameters
            val factory = object : FragmentFactory() {
                override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
                    return when (className) {
                        CitationCardFragment::class.java.name -> CitationCardFragment(
                            config.context,
                            config.minHeight,
                            config.adaptiveCard,
                            config.renderedAdaptiveCard,
                            config.actionHandler,
                            config.hostConfig,
                            config.renderArgs,
                            config.isEdgeToEdgeEnabled
                        )
                        else -> super.instantiate(classLoader, className)
                    }
                }
            }

            // Set factory and create fragment
            fragmentManager.fragmentFactory = factory
            val fragment = factory.instantiate(
                ClassLoader.getSystemClassLoader(),
                CitationCardFragment::class.java.name
            )

            // Show the dialog
            if (fragment is CitationCardFragment) {
                fragment.show(fragmentManager, TAG)
            }
        }
    }
}

/**
 * Configuration class for CitationCardFragment.
 *
 * Create an instance of this class with your citation card data and pass it to
 * CitationCardFragment.show() to display the fragment.
 *
 * @param context Android Context
 * @param minHeight Minimum height for the bottom sheet (optional)
 * @param adaptiveCard The adaptive card to render
 * @param renderedAdaptiveCard The rendered adaptive card context
 * @param actionHandler Handler for card actions
 * @param hostConfig Host configuration for styling
 * @param renderArgs Rendering arguments
 * @param isEdgeToEdgeEnabled Flag to enable edge-to-edge display mode
 */
data class CitationCardConfig(
    val context: Context,
    val minHeight: Int?,
    val adaptiveCard: AdaptiveCard,
    val renderedAdaptiveCard: RenderedAdaptiveCard,
    val actionHandler: ICardActionHandler,
    val hostConfig: HostConfig,
    val renderArgs: RenderArgs,
    val isEdgeToEdgeEnabled: Boolean = false
)
