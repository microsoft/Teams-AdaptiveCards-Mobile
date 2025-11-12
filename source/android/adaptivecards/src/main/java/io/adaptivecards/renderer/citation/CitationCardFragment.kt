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
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
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
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Utils
import io.adaptivecards.renderer.Utils.dpToPx
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.citation.CitationUtil.applyDrawableColor

class CitationCardFragment(
    private val context: Context,
    private val minHeight: Int?,
    private val adaptiveCard: AdaptiveCard,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
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
        val view = inflater.inflate(R.layout.citation_card_bottom_sheet_layout, container, false)

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
    }
}

class CitationCardFragmentFactory(
    private val context: Context,
    private val minHeight: Int?,
    private val adaptiveCard: AdaptiveCard,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : FragmentFactory() {

    override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
        return when (className) {
            CitationCardFragment::class.java.name -> CitationCardFragment(
                context,
                minHeight,
                adaptiveCard,
                renderedAdaptiveCard,
                actionHandler,
                hostConfig,
                renderArgs
            )

            else -> super.instantiate(classLoader, className)
        }
    }
}
