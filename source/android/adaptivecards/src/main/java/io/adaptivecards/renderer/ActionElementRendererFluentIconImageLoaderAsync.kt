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
    val padding: Long
): FluentIconImageLoaderAsync(renderedCard, targetIconSize, iconColor, isFilledStyle, view) {
    override fun renderFluentIcon(drawable: Drawable?, flipInRtl: Boolean) {
        val view = viewReference.get()
        if (view != null && view is Button) {
            val drawables = view.compoundDrawablesRelative

            drawable?.let {

                val flippedDrawable = flipDrawableHorizontally(it, view, flipInRtl)

                if (iconPlacement == IconPlacement.AboveTitle) {
                    drawables[1] = flippedDrawable
                } else {
                    if (iconPlacement == IconPlacement.RightOfTitle) {
                        drawables[2] = flippedDrawable
                    } else {
                        drawables[0] = flippedDrawable
                    }
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
    }

    /**
     * flips the drawable horizontally if the card is RTL and the flipInRtl property is true for the rendered svg
     **/
    private fun flipDrawableHorizontally(drawable: Drawable, view: View, flipInRtl: Boolean): Drawable {
        return if (renderedCard.adaptiveCard.GetRtl() == flipInRtl) {
            FluentIconUtils.flipDrawableHorizontally(drawable, view.context)
        } else {
            drawable
        }
    }
}