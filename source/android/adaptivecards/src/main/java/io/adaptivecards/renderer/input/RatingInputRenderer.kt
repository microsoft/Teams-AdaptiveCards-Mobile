// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.input

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingInput
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.inputhandler.InputUtils.updateInputHandlerInputWatcher
import io.adaptivecards.renderer.inputhandler.RatingInputHandler
import io.adaptivecards.renderer.layout.RatingStarInputView
import io.adaptivecards.renderer.readonly.RatingElementRendererUtil

/**
 * Renderer for rating input element
 **/
object RatingInputRenderer: BaseCardElementRenderer() {
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
        val ratingInput = Util.castTo(baseCardElement, RatingInput::class.java)
        val ratingInputHandler = RatingInputHandler(ratingInput, renderedCard, renderArgs.containerCardId)
        val view = RatingStarInputView(
            context,
            hostConfig,
            ratingInput
        ) as LinearLayout
        RatingElementRendererUtil.applyHorizontalAlignment(view, ratingInput.GetHorizontalAlignment(), renderArgs)
        ratingInputHandler.setView(view)
        renderedCard.registerInputHandler(ratingInputHandler, renderArgs.containerCardId)
        ratingInputHandler.updateInputHandlerInputWatcher()
        view.tag = TagContent(ratingInput, ratingInputHandler)
        viewGroup.addView(view)
        return view
    }

}