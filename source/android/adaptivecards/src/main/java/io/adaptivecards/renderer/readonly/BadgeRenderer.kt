package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.Badge
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingLabel
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.BadgeView
import io.adaptivecards.renderer.layout.RatingStarDisplayView

object BadgeRenderer: BaseCardElementRenderer() {
    override fun render(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        viewGroup: ViewGroup,
        baseCardElement: BaseCardElement,
        cardActionHandler: ICardActionHandler?,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): View {
        val badge = Util.castTo(baseCardElement, Badge::class.java)
        val view = BadgeView(context, badge, hostConfig)
//        RatingElementRendererUtil.applyHorizontalAlignment(view, badge.GetHorizontalAlignment(), renderArgs)
        view.tag = TagContent(badge)
        view.layoutParams = LinearLayout.LayoutParams(android.widget.LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT)
        viewGroup.addView(view)
        return view
    }
}