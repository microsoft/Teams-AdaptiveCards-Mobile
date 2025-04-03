// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.content.Context
import android.content.res.Configuration
import io.adaptivecards.objectmodel.Theme

object Utils {

    /**
     * Gets the current app theme as either Dark or Light.
     * @return `Theme.Dark` if using dark theme, `Theme.Light` otherwise.
     */
    @JvmStatic
    fun Context.getTheme() : Theme {
        return if (isDarkTheme()) Theme.Dark else Theme.Light
    }

    /**
     * Checks if the app is in dark mode.
     * @return `true` if using dark theme, `false` otherwise.
     */
    private fun Context.isDarkTheme() : Boolean {
        val nightModeFlags: Int = this.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        return nightModeFlags == Configuration.UI_MODE_NIGHT_YES
    }
}
