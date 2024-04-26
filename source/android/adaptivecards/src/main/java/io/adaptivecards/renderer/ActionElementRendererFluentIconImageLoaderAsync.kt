package io.adaptivecards.renderer

import android.graphics.drawable.Drawable
import android.view.View
import android.widget.Button
import io.adaptivecards.objectmodel.IconPlacement

class ActionElementRendererFluentIconImageLoaderAsync(
    renderedCard: RenderedAdaptiveCard,
    iconSize: Long,
    view: View,
    val iconPlacement: IconPlacement,
    val padding: Long
): FluentIconImageLoaderAsync(renderedCard, iconSize,"" ,view) {
    override fun renderFluentIcon(drawable: Drawable?) {
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
}