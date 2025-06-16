package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageButton
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import io.adaptivecards.R
import io.adaptivecards.objectmodel.ContainerStyle
import io.adaptivecards.objectmodel.ForegroundColor
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.IconPlacement
import io.adaptivecards.objectmodel.PopoverAction
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.readonly.TextRendererUtil
import io.adaptivecards.renderer.registration.CardRendererRegistration

class PopoverRenderer(
    private val context: Context,
    private val popoverAction: PopoverAction,
    private val clickedView: View,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val fragmentManager: FragmentManager,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) {

    fun showPopover() {
        // create popover dialog
        val context: Context = clickedView.getContext()
        val bottomSheetDialog = BottomSheetDialog(context, R.style.PopoverDialog)
        val inflater = LayoutInflater.from(context)
        val view: View = inflater.inflate(R.layout.popover_bottom_sheet_layout, null)
        bottomSheetDialog.setContentView(view)

        // add background to popover
        view.setBackgroundColor(
            Color.parseColor(
                hostConfig.GetActions().getPopover().getBackgroundColor()
            )
        )

        // set close button
        val closeButton = view.findViewById<ImageButton>(R.id.popover_closeButton)
        setCloseButton(closeButton)

        // add content to popover
        val contentLayout = view.findViewById<LinearLayout>(R.id.popover_contentLayout)
        val dialogContentViewId = Util.getViewId(view).toInt()
        renderPopoverContent(popoverAction, contentLayout, dialogContentViewId)

        // show dialog
        bottomSheetDialog.show()

        // store dialog object in rendered card to dismiss it later
        renderedAdaptiveCard.setPopoverDialog(bottomSheetDialog)
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

    fun setCloseButtomImage(closeButton: ImageButton, drawable: Drawable) {
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

    companion object {
        val CLOSE_ICON_URL: String = "icon:Dismiss"
    }

}