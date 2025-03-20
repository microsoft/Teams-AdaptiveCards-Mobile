// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.action

import android.widget.Button
import io.adaptivecards.renderer.FluentIconUtils.applyIconColor
import io.adaptivecards.renderer.FluentIconUtils.getHexColor

object ActionElementUtil {

    @JvmStatic
    fun Button.applyIconColor(iconColor : Int? = null) {
        val color = iconColor ?: currentTextColor
        getHexColor(color).apply {
            compoundDrawables[0]?.applyIconColor(this)
            compoundDrawables[1]?.applyIconColor(this)
            compoundDrawables[2]?.applyIconColor(this)
            compoundDrawables[3]?.applyIconColor(this)
        }
    }
}
