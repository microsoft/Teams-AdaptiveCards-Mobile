// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.content.Context
import android.content.res.Configuration
import android.graphics.Rect
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowInsets
import android.view.WindowManager
import android.view.WindowMetrics
import io.adaptivecards.objectmodel.ACTheme
import java.util.Locale

object Utils {

    /**
     * Gets the current app theme as either Dark or Light.
     * @return `Theme.Dark` if using dark theme, `Theme.Light` otherwise.
     */
    @JvmStatic
    fun Context.getTheme() : ACTheme {
        return if (isDarkTheme()) ACTheme.Dark else ACTheme.Light
    }

    /**
     * Checks if the app is in dark mode.
     * @return `true` if using dark theme, `false` otherwise.
     */
    private fun Context.isDarkTheme() : Boolean {
        val nightModeFlags: Int = this.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        return nightModeFlags == Configuration.UI_MODE_NIGHT_YES
    }

    fun getScreenAvailableHeight(context: Context): Int {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // For API 30+ (Android 11+)
            val windowMetrics: WindowMetrics = windowManager.currentWindowMetrics
            val insets: WindowInsets = windowMetrics.windowInsets
            val insetsIgnoringVisibility = insets.getInsetsIgnoringVisibility(
                WindowInsets.Type.systemBars()
            )
            val bounds: Rect = windowMetrics.bounds
            val height = bounds.height() - insetsIgnoringVisibility.top - insetsIgnoringVisibility.bottom
            height
        } else {
            // For API 26–29
            val displayMetrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getMetrics(displayMetrics)
            displayMetrics.heightPixels
        }
    }

    @JvmStatic
    fun Context.getLanguageTag() : String {
        val locale: Locale = this.resources.configuration.locales[0]
        return locale.toLanguageTag()
    }
}
