package io.adaptivecards.renderer

import android.app.Dialog
import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Resources
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

class PopoverBottomSheetDailogFragment(
    private val context: Context,
    private val popoverAction: PopoverAction,
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
        val view = inflater.inflate(R.layout.popover_bottom_sheet_layout, container, false)

        // set close button
        val closeButton = view.findViewById<ImageButton>(R.id.popover_closeButton)
        setCloseButton(closeButton)

        // add content to popover
        val contentLayout = view.findViewById<LinearLayout>(R.id.popover_contentLayout)
        val dialogContentViewId = Util.getViewId(view).toInt()
        renderPopoverContent(popoverAction, contentLayout, dialogContentViewId)

        return view;
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
            Log.e("BaseActionElementRend", "Error rendering popover content", e)
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
                Log.d("BottomSheet", "Bottom sheet height: $height")

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

    val Float.dpToPx: Float
        get() = this * Resources.getSystem().displayMetrics.density

    private fun getPeekHeight(contentHeight: Int): Int {
        val screenHeight = Utils.getScreenActualAvailableHeight(context)
        val minHeight = screenHeight / 5
        val maxHeight = (screenHeight * 2) / 3
        return contentHeight.coerceIn(minHeight, maxHeight)
    }

    companion object {
        val CLOSE_ICON_URL: String = "icon:Dismiss"
    }

}

class PopoverBottomSheetDailogFragmentFactory(
    private val context: Context,
    private val popoverAction: PopoverAction,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : FragmentFactory() {
    override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
        return when (className) {
            PopoverBottomSheetDailogFragment::class.java.name -> PopoverBottomSheetDailogFragment(
                context,
                popoverAction,
                renderedAdaptiveCard,
                actionHandler,
                hostConfig,
                renderArgs
            )

            else -> super.instantiate(classLoader, className)
        }
    }
}

