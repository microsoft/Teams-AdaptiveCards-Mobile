package io.adaptivecards.renderer

import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.view.ViewGroup
import io.adaptivecards.objectmodel.CardElementType
import io.adaptivecards.objectmodel.HostConfig

object ViewUtils {
    @JvmStatic
    fun ViewGroup.applyRoundedCorners(
        hostConfig: HostConfig,
        cardElementType: CardElementType?,
        roundedCorners: Boolean
    ) {
        Log.e("PRPATWA", "applyRoundedCorners")
        if (roundedCorners) {
            val cornerRadiusInPixels = 400f
            if (this.background is GradientDrawable) {
                (this.background as GradientDrawable).cornerRadius =
                    cornerRadiusInPixels
            } else {
                val gradientDrawable = GradientDrawable()
                gradientDrawable.cornerRadius = cornerRadiusInPixels
                this.background = gradientDrawable
            }
        }
    }

    @JvmStatic
    fun ViewGroup.applyCircularBackground(
        hostConfig: HostConfig,
        cardElementType: CardElementType?
    ) {
        if (this.background is GradientDrawable) {
            (this.background as GradientDrawable).shape = GradientDrawable.OVAL
        } else {
            val gradientDrawable = GradientDrawable()
            gradientDrawable.shape = GradientDrawable.OVAL
            this.background = gradientDrawable
        }
    }
}