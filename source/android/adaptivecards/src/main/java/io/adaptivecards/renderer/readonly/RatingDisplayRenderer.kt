// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingLabel
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.RatingStarDisplayView

/**
 * Renderer for read only rating element
 **/
object RatingDisplayRenderer: BaseCardElementRenderer() {
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
        val ratingLabel = Util.castTo(baseCardElement, RatingLabel::class.java)
        val view = RatingStarDisplayView(context, ratingLabel, hostConfig)
        RatingElementRendererUtil.applyHorizontalAlignment(view, ratingLabel.GetHorizontalAlignment(), renderArgs)
        view.tag = TagContent(ratingLabel)
        viewGroup.addView(view)
        return view
    }
}