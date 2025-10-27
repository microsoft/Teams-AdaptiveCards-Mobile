package io.adaptivecards.renderer.citation

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentFactory
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import io.adaptivecards.R
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.References
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

class CitationBottomSheetDialogFragment(
    private val context: Context,
    private val citationReference: References,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : BottomSheetDialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState) as BottomSheetDialog
        return dialog
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {

        val view = inflater.inflate(R.layout.popover_bottom_sheet_layout, container, false)


        // add content to popover
        val contentLayout = view.findViewById<LinearLayout>(R.id.popover_contentLayout)
        val dialogContentViewId = Util.getViewId(view).toInt()
        //renderPopoverContent(popoverAction, contentLayout, dialogContentViewId)

        return view;
    }

    private fun renderCitationContent() {

    }

    companion object {
        const val TAG = "CitationBottomSheetDialog"
    }
}

class CitationBottomSheetDialogFragmentFactory(
    private val context: Context,
    private val citationReference: References,
    private val renderedAdaptiveCard: RenderedAdaptiveCard,
    private val actionHandler: ICardActionHandler,
    private val hostConfig: HostConfig,
    private val renderArgs: RenderArgs
) : FragmentFactory() {

    override fun instantiate(classLoader: ClassLoader, className: String): Fragment {
        return when (className) {
            CitationBottomSheetDialogFragment::class.java.name -> CitationBottomSheetDialogFragment(
                    context,
                    citationReference,
                    renderedAdaptiveCard,
                    actionHandler,
                    hostConfig,
                    renderArgs
            )

            else -> super.instantiate(classLoader, className)
        }
    }
}
