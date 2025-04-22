package io.adaptivecards.renderer.readonly

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.ProgressRing
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

/**
 * Renderer for ProgressRing Element
 */
object ProgressRingRenderer : BaseCardElementRenderer() {

    override fun render(
        renderedCard: RenderedAdaptiveCard, context: Context, fragmentManager: FragmentManager, viewGroup: ViewGroup,
        baseCardElement: BaseCardElement, cardActionHandler: ICardActionHandler?, hostConfig: HostConfig,
        renderArgs: RenderArgs): View? {
        val progressRing = Util.castTo(baseCardElement, ProgressRing::class.java)
        val getSize = progressRing.GetSize()
        val getLabelPosition = progressRing.GetLabelPosition()
        val getLabel = progressRing.GetLabel()
        val horizontalAlignment = progressRing.GetHorizontalAlignment() ?: HorizontalAlignment.Left
        Log.d("ProgressRingRenderer", "render: ${getSize} ${getLabelPosition} ${getLabel} ${horizontalAlignment}")
        return null
    }
}