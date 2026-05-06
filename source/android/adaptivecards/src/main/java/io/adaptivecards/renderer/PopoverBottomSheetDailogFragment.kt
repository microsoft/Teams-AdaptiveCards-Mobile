package io.adaptivecards.renderer

import android.app.Dialog
import android.content.Context
import android.content.res.ColorStateList
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.ImageButton
import android.widget.LinearLayout
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import io.adaptivecards.R
import io.adaptivecards.objectmodel.ContainerStyle
import io.adaptivecards.objectmodel.ForegroundColor
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.PopoverAction
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.readonly.TextRendererUtil
import io.adaptivecards.renderer.registration.CardRendererRegistration
import androidx.core.graphics.toColorInt
import com.google.android.material.shape.CornerFamily
import com.google.android.material.shape.MaterialShapeDrawable
import com.google.android.material.shape.ShapeAppearanceModel
import io.adaptivecards.renderer.Utils.dpToPx

class PopoverBottomSheetDailogFragment(
    private val context: Context,
    private val popoverAction: PopoverAction,
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
        val view = inflater.inflate(R.layout.popover_bottom_sheet_layout, container, false)

        // Apply edge-to-edge insets if enabled
        if (isEdgeToEdgeEnabled) {
            // Apply horizontal insets to root view
            view.applyEdgeToEdgePaddingInsets(InsetSide.START, InsetSide.END)

            // Apply bottom insets to scrollable content
            val contentLayout = view.findViewById<LinearLayout>(R.id.popover_contentLayout)
            contentLayout.applyEdgeToEdgePaddingInsets(InsetSide.BOTTOM)
        }

        // set close button
        val closeButton = view.findViewById<ImageButton>(R.id.popover_closeButton)
        setCloseButton(closeButton)

        // add content to popover
        val contentLayout = view.findViewById<LinearLayout>(R.id.popover_contentLayout)
        val dialogContentViewId = Util.getViewId(view).toInt()
        renderPopoverContent(popoverAction, contentLayout, dialogContentViewId)

        return view
    }

    private fun setCloseButton(
        closeButton: ImageButton
    ) {
        IconUtils.getIcon(
            context,
            CLOSE_ICON_URL,
            popoverAction.GetSVGPath(CLOSE_ICON_URL),
            TextRendererUtil.getTextColor(ForegroundColor.Default, hostConfig, false, ContainerStyle.Default),
            false,
            24,
            callback = { drawable ->
                drawable?.let {
                    setCloseButtomImage(closeButton, it)
                }
            }
        )

        closeButton.setOnClickListener {
            renderedAdaptiveCard.getPopoverDialog()?.let {
                it.dismiss()
                renderedAdaptiveCard.setPopoverDialog(null)
            }
        }
    }

    private fun setCloseButtomImage(closeButton: ImageButton, drawable: Drawable) {
        Handler(Looper.getMainLooper()).post {
            closeButton.setImageDrawable(drawable)
        }
    }

    private fun renderPopoverContent(
        action: PopoverAction,
        viewGroup: ViewGroup,
        parentViewId: Int
    ) {
        try {
            CardRendererRegistration.getInstance().renderElementAndPerformFallback(
                renderedAdaptiveCard,
                viewGroup.context,
                fragmentManager,
                action.GetContent(),
                viewGroup,
                actionHandler,
                hostConfig,
                RenderArgs(renderArgs, parentViewId),
                CardRendererRegistration.getInstance().featureRegistration
            )
        } catch (e: Exception) {
            // Error rendering popover content
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
                .setTopLeftCorner(CornerFamily.ROUNDED, 10f.dpToPx(context))
                .setTopRightCorner(CornerFamily.ROUNDED, 10f.dpToPx(context))
                .setBottomLeftCorner(CornerFamily.ROUNDED, 0f)
                .setBottomRightCorner(CornerFamily.ROUNDED, 0f)
                .build()
            fillColor = ColorStateList.valueOf(hostConfig.GetActions().getPopover().getBackgroundColor().toColorInt())
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
        val CLOSE_ICON_URL: String = "icon:Dismiss"
        val TAG = "PopoverBottomSheetDailogFragment"
    }

}

class PopoverBottomSheetDailogFragmentFactory(
    private val context: Context,
    private val popoverAction: PopoverAction,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs,
    private val isEdgeToEdgeEnabled: Boolean = false
) : FragmentFactory() {
    override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
        return when (className) {
            PopoverBottomSheetDailogFragment::class.java.name -> PopoverBottomSheetDailogFragment(
                context,
                popoverAction,
                renderedAdaptiveCard,
                actionHandler,
                hostConfig,
                renderArgs,
                isEdgeToEdgeEnabled
            )

            else -> super.instantiate(classLoader, className)
        }
    }
}

