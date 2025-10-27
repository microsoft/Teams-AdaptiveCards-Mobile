package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Resources
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.LinearLayout
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
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.renderer.AdaptiveCardRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Utils
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

class CitationCardFragment(
    private val context: Context,
    private val adaptiveCard: AdaptiveCard,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : BottomSheetDialogFragment() {

    val Float.dpToPx: Float
        get() = this * Resources.getSystem().displayMetrics.density

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState) as BottomSheetDialog
        return dialog
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {

        val view = inflater.inflate(R.layout.citation_card_bottom_sheet_layout, container, false)

        // Add Card to BottomSheet
        val contentLayout = view.findViewById<LinearLayout>(R.id.citation_card_contentLayout)
        //val dialogContentViewId = Util.getViewId(view).toInt()
        renderCitationCard(contentLayout)
        return view
    }

    private fun renderCitationCard(contentLayout: ViewGroup) {
        try {
            val cardView = AdaptiveCardRenderer.getInstance().internalRender(
                    renderedAdaptiveCard,
                    context,
                    fragmentManager,
                    adaptiveCard,
                    actionHandler,
                    hostConfig,
                    false,
                    View.NO_ID.toLong())
            contentLayout.addView(cardView)
        } catch (e: Exception) {
            // Error rendering card content
        }
    }

    override fun onStart() {
        super.onStart()

        val dialog = dialog as? BottomSheetDialog
        // store dialog object in rendered card to auto dismiss it on submit/execute
        renderedAdaptiveCard.setPopoverDialog(dialog)

        val bottomSheet =
            dialog?.findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)

        bottomSheet?.background = MaterialShapeDrawable().apply {
            shapeAppearanceModel = ShapeAppearanceModel.builder()
                .setTopLeftCorner(CornerFamily.ROUNDED, 10f.dpToPx)
                .setTopRightCorner(CornerFamily.ROUNDED, 10f.dpToPx)
                .setBottomLeftCorner(CornerFamily.ROUNDED, 0f)
                .setBottomRightCorner(CornerFamily.ROUNDED, 0f)
                .build()
            fillColor = ColorStateList.valueOf(hostConfig.GetActions().getPopover().getBackgroundColor().toColorInt())
        }

        bottomSheet?.viewTreeObserver?.addOnGlobalLayoutListener(object :
            ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                bottomSheet.viewTreeObserver.removeOnGlobalLayoutListener(this)
                val height = bottomSheet.height
                Log.d(TAG, "Bottom sheet height: $height")

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
        val minHeight = screenHeight / 5
        val maxHeight = (screenHeight * 2) / 3
        return contentHeight.coerceIn(minHeight, maxHeight)
    }

    companion object {
        const val TAG = "CitationCardFragment"
    }
}

class CitationCardFragmentFactory(
    private val context: Context,
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
