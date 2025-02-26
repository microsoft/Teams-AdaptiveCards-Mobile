// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.graphics.drawable.Drawable
import android.view.View
import android.widget.Button
import io.adaptivecards.objectmodel.IconPlacement

/**
 * Responsible for rendering the Fluent Icon in the Action Element
 **/
class ActionElementRendererFluentIconImageLoaderAsync(
    renderedCard: RenderedAdaptiveCard,
    targetIconSize: Long,
    isFilledStyle: Boolean,
    view: View,
    iconColor: String,
    val iconPlacement: IconPlacement,
    val padding: Long,
    iconSizeFromConfig: Long
): FluentIconImageLoaderAsync(renderedCard, targetIconSize, iconColor, iconSizeFromConfig, isFilledStyle, view) {
    override fun renderFluentIcon(drawable: Drawable?, flipInRtl: Boolean) {
        val view = viewReference.get()
        if (view != null && view is Button && drawable != null) {

//            val flippedDrawable = IconUtils.flipDrawableHorizontally(renderedCard, drawable, view.context, flipInRtl)
//
//            val drawables = IconUtils.getDrawablesForActionElementIcon(flippedDrawable, view.compoundDrawablesRelative, iconPlacement)
//            view.compoundDrawablePadding = IconUtils.getPaddingForActionElementIcon(
//                    context = view.context,
//                    padding = padding,
//                    iconPlacement = iconPlacement,
//                    defaultPadding = view.compoundDrawablePadding)
//
//            view.setCompoundDrawablesRelativeWithIntrinsicBounds(
//                    drawables[0],
//                    drawables[1],
//                    drawables[2],
//                    drawables[3]
//            )

            val result = IconUtils.getIcon(view.context, renderedCard, drawable, flipInRtl, iconPlacement, padding, view.compoundDrawablesRelative, view.compoundDrawablePadding)
            view.compoundDrawablePadding = result.padding
            view.setCompoundDrawablesRelativeWithIntrinsicBounds(
                    result.drawables[0],
                    result.drawables[1],
                    result.drawables[2],
                    result.drawables[3],
            )
        }
    }
}