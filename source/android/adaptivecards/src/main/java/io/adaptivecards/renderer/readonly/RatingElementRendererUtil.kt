// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.graphics.Color
import android.widget.LinearLayout
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingColor
import io.adaptivecards.renderer.RenderArgs
import java.text.NumberFormat
import java.util.Locale

object RatingElementRendererUtil {

    /**
     * returns the color of the star based on the activated state
     * if the star is activated, it returns the filled star color else it returns the empty star color from the hostConfig
     **/
     fun getInputStarColor(color: RatingColor, isActivated: Boolean, hostConfig: HostConfig): Int {
        return if (isActivated) {
            when (color) {
                RatingColor.Neutral -> getColorFromHexCode(hostConfig.GetRatingInputConfig().filledStar.neutralColor)
                RatingColor.Marigold -> getColorFromHexCode(hostConfig.GetRatingInputConfig().filledStar.marigoldColor)
            }
        } else {
            when (color) {
                RatingColor.Neutral -> getColorFromHexCode(hostConfig.GetRatingInputConfig().emptyStar.neutralColor)
                RatingColor.Marigold -> getColorFromHexCode(hostConfig.GetRatingInputConfig().emptyStar.marigoldColor)
            }
        }
    }

    /**
     * returns the color of the read only stars based on the activated state
     * if the star is activated, it returns the filled star color else it returns the empty star color from the hostConfig
     **/
    fun getReadOnlyStarColor(color: RatingColor, isActivated: Boolean, hostConfig: HostConfig): Int {
        return if (isActivated) {
            when (color) {
                RatingColor.Neutral -> getColorFromHexCode(hostConfig.GetRatingLabelConfig().filledStar.neutralColor)
                RatingColor.Marigold -> getColorFromHexCode(hostConfig.GetRatingLabelConfig().filledStar.marigoldColor)
            }
        } else {
            when (color) {
                RatingColor.Neutral -> getColorFromHexCode(hostConfig.GetRatingLabelConfig().emptyStar.neutralColor)
                RatingColor.Marigold -> getColorFromHexCode(hostConfig.GetRatingLabelConfig().emptyStar.marigoldColor)
            }
        }
    }

    fun formatNumberWithCommas(number: Long): String {
        return NumberFormat.getNumberInstance(Locale.getDefault()).format(number)
    }

    /**
     * parse the hexcode and return the color
     **/
    fun getColorFromHexCode(hexcode: String): Int {
        return try {
            Color.parseColor(hexcode)
        } catch (e: IllegalArgumentException) {
            Color.BLACK
        }
    }

    fun applyHorizontalAlignment(view: LinearLayout, horizontalAlignment: HorizontalAlignment?, renderArgs: RenderArgs) {
        when (horizontalAlignment ?: renderArgs.horizontalAlignment ?: HorizontalAlignment.Left) {
            HorizontalAlignment.Center -> view.gravity = android.view.Gravity.CENTER_HORIZONTAL
            HorizontalAlignment.Right -> view.gravity = android.view.Gravity.END
            else -> view.gravity = android.view.Gravity.START
        }
    }
}