// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.graphics.Color
import android.os.AsyncTask
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.ContainerStyle
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.Icon
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.FluentIconImageLoaderAsync
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

object FluentIconsRenderer : BaseCardElementRenderer() {

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
        val icon = Util.castTo(baseCardElement, Icon::class.java)
        val view = ImageView(context)
        val svgURL = icon.GetSVGResourceURL()
        val foregroundColor = hostConfig.GetForegroundColor(ContainerStyle.Default, icon.forgroundColor, false)

        Log.d("FluentIconsRenderer", "iconSize: ${icon.iconSize}")
        Log.d("FluentIconsRenderer", "icon color: $foregroundColor")
        Log.d("FluentIconsRenderer", "icon size: ${icon.size}")
        Log.d("FluentIconsRenderer", "SVG URL: $svgURL")

        val fluentIconImageLoaderAsync = FluentIconImageLoaderAsync(
            renderedCard,
            icon.size,
            foregroundColor,
            view
        )

        fluentIconImageLoaderAsync.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, svgURL)

        viewGroup.addView(view)
        view.tag = TagContent(icon)

        ContainerRenderer.setSelectAction(renderedCard, icon.GetSelectAction(), view, cardActionHandler, renderArgs)

        return view
    }
}
