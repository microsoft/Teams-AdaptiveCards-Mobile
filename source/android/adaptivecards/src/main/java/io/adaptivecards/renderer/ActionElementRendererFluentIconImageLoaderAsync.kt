// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.View
import android.widget.Button
import com.caverock.androidsvg.SVG
import io.adaptivecards.objectmodel.IconPlacement

/**
 * Responsible for rendering the Fluent Icon in the Action Element
 **/
class ActionElementRendererFluentIconImageLoaderAsync(
    renderedCard: RenderedAdaptiveCard,
    iconSize: Long,
    view: View,
    iconColor: String,
    val iconPlacement: IconPlacement,
    val padding: Long,
    private val iconSizeFromConfig: Long
): FluentIconImageLoaderAsync(renderedCard, iconSize, iconColor, view) {
    override fun renderFluentIcon(drawable: Drawable?, flipRtl: Boolean) {
        val view = viewReference.get()
        if (view != null && view is Button) {
            val drawables = view.compoundDrawablesRelative

            if (iconPlacement == IconPlacement.AboveTitle) {
                drawables[1] = drawable
            } else {
                drawables[0] = drawable
                view.compoundDrawablePadding = Util.dpToPixels(view.context, padding.toFloat())
            }

            view.setCompoundDrawablesRelativeWithIntrinsicBounds(
                drawables[0],
                drawables[1],
                drawables[2],
                drawables[3]
            )
        }
    }

    override fun parseSvgString(context: Context, svgString: String): SVG {
        val svg = SVG.getFromString(svgString)
        svg.documentWidth = Util.dpToPixels(context, iconSizeFromConfig.toFloat()).toFloat()
        svg.documentHeight = Util.dpToPixels(context, iconSizeFromConfig.toFloat()).toFloat()
        return svg
    }
}