package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import io.adaptivecards.R
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.PopoverAction
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.registration.CardRendererRegistration

class PopoverRenderer(
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
        val dialogContentViewId = Util.getViewId(view).toInt()
        bottomSheetDialog.setContentView(view)

        // add background to popover
        val parentLayout = view.findViewById<LinearLayout>(R.id.popover_parentContentLayout)
        parentLayout.setBackgroundColor(
            Color.parseColor(
                hostConfig.GetActions().getPopover().getBackgroundColor()
            )
        )

        // add content to popover
        renderPopoverContent(popoverAction, parentLayout, dialogContentViewId)

        // show dialog
        bottomSheetDialog.show()

        // store dialog object in rendered card to dismiss it later
        renderedAdaptiveCard.setPopoverDialog(bottomSheetDialog)
    }

    protected fun renderPopoverContent(
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
}