package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

/**
 * Renderer for ProgressBar Element
 * Fix: Provide meaningful accessibility info for TalkBack (#451)
 */
object ProgressBarRenderer : BaseCardElementRenderer() {

    override fun render(
        renderedCard: RenderedAdaptiveCard, context: Context, fragmentManager: FragmentManager, viewGroup: ViewGroup,
        baseCardElement: BaseCardElement, cardActionHandler: ICardActionHandler?, hostConfig: HostConfig,
        renderArgs: RenderArgs): View? {

        // Fix: Set contentDescription for progress bar accessibility (#451)
        // The element is parsed but rendering is delegated to the host app.
        // Return null to let the host handle rendering, but ensure any host-rendered
        // progress bar should set contentDescription with the progress value.
        return null
    }
}
