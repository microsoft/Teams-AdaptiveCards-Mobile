// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.app.Dialog
import android.content.res.Configuration
import android.util.TypedValue
import android.view.View
import android.view.Window
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.adaptivecards.R

/**
 * Extension functions for edge-to-edge support across adaptive card bottom sheets.
 */

/**
 * Represents the sides of a view where edge-to-edge insets can be applied.
 */
enum class InsetSide {
    START, END, TOP, BOTTOM
}

private data class OriginalPadding(val start: Int, val top: Int, val end: Int, val bottom: Int)

/**
 * Applies edge-to-edge insets as **padding** for the specified [sides], accounting for
 * system bars and display cutout areas.
 *
 * @param addToOriginal When `true` (default), inset values are added to the view's
 *   original padding (captured once via a view tag on the first call), preserving any
 *   XML-defined or programmatic padding. Safe to call multiple times — the baseline
 *   is stored once and reused. When `false`, specified sides are set to the raw inset value.
 *   Sides not included in [sides] always retain their current padding.
 */
fun View.applyEdgeToEdgePaddingInsets(
    vararg sides: InsetSide,
    addToOriginal: Boolean = true
) {
    val sideSet = sides.toSet()

    // Store baseline padding once via view tag to prevent accumulation across repeated calls
    val original = if (addToOriginal) {
        (getTag(R.id.ac_edge_to_edge_original_padding) as? OriginalPadding) ?: OriginalPadding(
            paddingStart,
            paddingTop,
            paddingEnd,
            paddingBottom
        ).also { setTag(R.id.ac_edge_to_edge_original_padding, it) }
    } else {
        null
    }

    ViewCompat.setOnApplyWindowInsetsListener(this) { view, windowInsets ->
        val insets = windowInsets.getCombinedSysBarAndCutoutInsets()
        view.setPaddingRelative(
            if (InsetSide.START in sideSet) (original?.start ?: 0) + insets.left else view.paddingStart,
            if (InsetSide.TOP in sideSet) (original?.top ?: 0) + insets.top else view.paddingTop,
            if (InsetSide.END in sideSet) (original?.end ?: 0) + insets.right else view.paddingEnd,
            if (InsetSide.BOTTOM in sideSet) (original?.bottom ?: 0) + insets.bottom else view.paddingBottom
        )
        windowInsets
    }
    ViewCompat.requestApplyInsets(this)
}

/**
 * Enables edge-to-edge display for this dialog's window by allowing content to draw behind system bars.
 * Status/navigation bar icon appearance is determined by the host app's theme.
 */
fun Dialog.setupEdgeToEdge() {
    window?.let { setupEdgeToEdgeForWindow(it, context) }
}

/**
 * Enables edge-to-edge display for a window by allowing content to draw behind system bars.
 * Status/navigation bar icon appearance is determined by the theme.
 */
private fun setupEdgeToEdgeForWindow(window: Window, context: android.content.Context) {
    WindowCompat.setDecorFitsSystemWindows(window, false)
    val typedValue = TypedValue()
    val isLightTheme = if (context.theme.resolveAttribute(androidx.appcompat.R.attr.isLightTheme, typedValue, true)) {
        typedValue.data != 0
    } else {
        (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) != Configuration.UI_MODE_NIGHT_YES
    }
    WindowCompat.getInsetsController(window, window.decorView).apply {
        isAppearanceLightStatusBars = isLightTheme
        isAppearanceLightNavigationBars = isLightTheme
    }
}

/**
 * Returns max of sysBarInsets and cutoutInsets to handle both system bars and display cutouts.
 */
fun WindowInsetsCompat.getCombinedSysBarAndCutoutInsets(): Insets {
    val sysBarInsets = getInsets(WindowInsetsCompat.Type.systemBars())
    val cutoutInsets = getInsets(WindowInsetsCompat.Type.displayCutout())
    return Insets.max(sysBarInsets, cutoutInsets)
}
