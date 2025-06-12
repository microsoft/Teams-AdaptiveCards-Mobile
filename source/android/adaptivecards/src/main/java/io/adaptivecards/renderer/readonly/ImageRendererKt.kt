// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.graphics.Matrix
import android.widget.ImageView
import io.adaptivecards.objectmodel.HorizontalContentAlignment
import io.adaptivecards.objectmodel.Image
import io.adaptivecards.objectmodel.ImageFitMode
import io.adaptivecards.objectmodel.VerticalContentAlignment
import kotlin.math.max
import kotlin.math.min

object ImageRendererKt {

    @JvmStatic
    fun setImageFitMode(image: Image, imageView: ImageView) {
        val imageFitMode = image.GetImageFitMode() ?: ImageFitMode.Fill

        if (imageFitMode == ImageFitMode.Fill) {
            imageView.scaleType = ImageView.ScaleType.FIT_XY
            return
        }

        imageView.scaleType = ImageView.ScaleType.MATRIX
        imageView.viewTreeObserver.addOnGlobalLayoutListener {
            val drawable = imageView.drawable ?: return@addOnGlobalLayoutListener
            val viewWidth = imageView.width.toFloat()
            val viewHeight = imageView.height.toFloat()

            val dWidth = drawable.intrinsicWidth
            val dHeight = drawable.intrinsicHeight

            val scale = when (image.GetImageFitMode()) {
                ImageFitMode.Contain -> min((viewWidth / dWidth).toDouble(), (viewHeight / dHeight).toDouble())
                    .toFloat()
                ImageFitMode.Cover -> max((viewWidth / dWidth).toDouble(), (viewHeight / dHeight).toDouble())
                    .toFloat()
                else -> return@addOnGlobalLayoutListener
            }

            val scaledWidth = scale * dWidth
            val scaledHeight = scale * dHeight

            val dx = when (image.GetHorizontalContentAlignment() ?: HorizontalContentAlignment.Left) {
                HorizontalContentAlignment.Left -> 0f
                HorizontalContentAlignment.Center -> (viewWidth - scaledWidth) / 2f
                HorizontalContentAlignment.Right -> viewWidth - scaledWidth
            }
            val dy = when (image.GetVerticalContentAlignment() ?: VerticalContentAlignment.Top) {
                VerticalContentAlignment.Top -> 0f
                VerticalContentAlignment.Center -> (viewHeight - scaledHeight) / 2f
                VerticalContentAlignment.Bottom -> viewHeight - scaledHeight
            }

            val matrix = Matrix()
            matrix.setScale(scale, scale)
            matrix.postTranslate(dx, dy)
            imageView.imageMatrix = matrix
        }
    }
}