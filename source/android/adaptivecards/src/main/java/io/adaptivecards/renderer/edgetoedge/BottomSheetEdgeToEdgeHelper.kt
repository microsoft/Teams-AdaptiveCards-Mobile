/**
 * Copyright © Microsoft Corporation. All rights reserved.
 */
package io.adaptivecards.renderer.edgetoedge

import android.app.Dialog
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.util.TypedValue
import android.view.View
import android.view.ViewGroup
import android.view.Window
import androidx.annotation.MainThread
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

/**
 * Helper utilities for edge-to-edge bottom sheets.
 *
 * Bottom sheets require special handling for edge-to-edge because:
 * 1. They need their own window configuration
 * 2. Content must not be obscured by the navigation bar
 * 3. The sheet's drag handle and content need proper padding
 *
 * Usage:
 * ```kotlin
 * class MyBottomSheet : BottomSheetDialogFragment() {
 *     override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
 *         super.onViewCreated(view, savedInstanceState)
 *         setupEdgeToEdgeBottomSheet(extendBehindNavBar = true)
 *     }
 * }
 * ```
 */
object BottomSheetEdgeToEdgeHelper {

    /**
     * Configure a BottomSheetDialogFragment for edge-to-edge display.
     *
     * The default path (`extendBehindNavBar = false`) preserves historical behaviour:
     * the sheet stops at the navigation bar and the caller's [contentView] receives bottom
     * inset padding. This keeps every existing call-site unchanged.
     *
     * When [extendBehindNavBar] is true, the sheet's background extends **behind** the
     * navigation bar — required on API 36+, where the platform forces the system nav bar
     * transparent and a sheet that stops at the nav bar shows the activity behind it as
     * a coloured strip. In that mode the helper additionally:
     *  - Applies [setEdgeToEdgeEnabled] to the dialog (disables `fitsSystemWindows` on
     *    Material's `container` / `coordinator` wrappers so the sheet can paint all the
     *    way down).
     *  - Calls [configureNavBarAppearance] on the window to suppress the system contrast
     *    scrim and sync the nav-bar icon colour to the dialog's theme.
     *  - Applies bottom inset padding to the first descendant of [contentView] with a
     *    non-null background (capped at depth 3) — typically the inner styled container
     *    that supplies the sheet's rounded-top drawable.
     *
     * @param bottomSheetFragment The fragment to configure
     * @param contentView Content view that receives the bottom inset
     * @param extendBehindNavBar Opt-in for the API-36 seamless-nav-bar behaviour. Defaults
     *   to `false` so existing callers are unaffected.
     */
    @MainThread
    fun setup(
        bottomSheetFragment: BottomSheetDialogFragment,
        contentView: View,
        extendBehindNavBar: Boolean = false
    ) {
        val dialog = bottomSheetFragment.dialog ?: return
        dialog.window?.let(::configureWindow)

        if (extendBehindNavBar) {
            dialog.window?.let(::configureNavBarAppearance)
            setEdgeToEdgeEnabled(dialog)
            // Pad the styled background-bearing descendant rather than the (often
            // backgroundless) root: a View's background fills its full padded bounds, so
            // adding nav-bar-inset padding to the inner styled container extends the
            // sheet's existing rounded-top drawable straight down behind the (transparent)
            // nav bar.
            applyBottomInsets(findInsetTarget(contentView))
        } else {
            applyBottomInsets(contentView)
        }
    }

    /**
     * Walk down the view tree (capped at depth 3) and return the first descendant with a
     * non-null background. Falls back to [root] if none is found. Used so the nav-bar inset
     * lands on the styled container whose background should extend behind the nav bar,
     * rather than on a backgroundless root that would leave a transparent strip.
     */
    private fun findInsetTarget(root: View, maxDepth: Int = 3): View {
        if (root.background != null) return root
        if (maxDepth <= 0 || root !is ViewGroup) return root
        for (i in 0 until root.childCount) {
            val target = findInsetTarget(root.getChildAt(i), maxDepth - 1)
            if (target.background != null) return target
        }
        return root
    }

    /**
     * Configure the dialog window for edge-to-edge.
     *
     * Behaviour matches the Teams helper: `decorFitsSystemWindows=false` and the
     * (pre-API-35) transparent navigation bar colour.
     */
    @MainThread
    fun configureWindow(window: Window) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        // Deprecated on API 35+ (the platform enforces transparent regardless), but still
        // required for API < 35 to get the same end state.
        @Suppress("DEPRECATION")
        window.navigationBarColor = Color.TRANSPARENT
    }

    /**
     * Additional window setup used when a sheet extends behind the nav bar.
     *
     *  - On API 29+ the automatic system contrast scrim is disabled so it does not paint
     *    a translucent bar over a sheet that already extends behind it.
     *  - The nav-bar icon appearance is synced to the dialog's theme so the system
     *    back/home pill stays visible against the sheet background that now shows through
     *    the transparent nav bar.
     *
     * Kept as a separate method (rather than folded into [configureWindow]) so that
     * callers which previously relied on [configureWindow] are not retroactively changed.
     */
    @MainThread
    fun configureNavBarAppearance(window: Window) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
        val isLightTheme = detectLightTheme(window)
        WindowCompat.getInsetsController(window, window.decorView)
            ?.isAppearanceLightNavigationBars = isLightTheme
    }

    /**
     * Detect if the current theme is light or dark.
     * Uses isLightTheme attribute with fallback to UI_MODE_NIGHT_MASK.
     */
    private fun detectLightTheme(window: Window): Boolean {
        val typedValue = TypedValue()
        return if (window.context.theme.resolveAttribute(android.R.attr.isLightTheme, typedValue, true)) {
            typedValue.data != 0
        } else {
            val uiMode = window.context.resources.configuration.uiMode
            (uiMode and Configuration.UI_MODE_NIGHT_MASK) != Configuration.UI_MODE_NIGHT_YES
        }
    }

    /**
     * Equivalent of Material 1.4.0+'s `BottomSheetDialog.setEdgeToEdgeEnabled(true)`.
     *
     * Material 1.3.0's `design_bottom_sheet_dialog` layout wraps content in:
     *
     * ```
     * FrameLayout (@id/container, fitsSystemWindows=true)
     *   └─ CoordinatorLayout (@id/coordinator, fitsSystemWindows=true)
     *        └─ FrameLayout (@id/design_bottom_sheet)
     * ```
     *
     * Both wrappers consume the bottom nav-bar inset as padding, which prevents the sheet
     * from extending behind the nav bar. Material 1.4.0 added
     * `BottomSheetDialog.setEdgeToEdgeEnabled(boolean)` whose internal implementation is
     * **literally** `container.setFitsSystemWindows(false); coordinator.setFitsSystemWindows(false)`
     * — this method does the same thing.
     *
     * The two IDs used below — `R.id.container` and `R.id.coordinator` — are **public**
     * R.ids that Material Components has exposed since 1.0.0 and through 1.12+.
     */
    @MainThread
    fun setEdgeToEdgeEnabled(dialog: Dialog) {
        dialog.findViewById<View>(com.google.android.material.R.id.container)
            ?.fitsSystemWindows = false
        dialog.findViewById<View>(com.google.android.material.R.id.coordinator)
            ?.fitsSystemWindows = false
    }

    /**
     * Apply bottom navigation bar insets to the content view. The view's existing
     * `paddingBottom` (typically declared in XML / a style) is preserved — the nav-bar
     * inset is added on top — so that repeated insets dispatches do not compound.
     */
    @MainThread
    fun applyBottomInsets(contentView: View) {
        val originalPaddingBottom = contentView.paddingBottom
        ViewCompat.setOnApplyWindowInsetsListener(contentView) { v, insets ->
            val navBarInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars())
            v.updatePadding(bottom = originalPaddingBottom + navBarInsets.bottom)
            insets
        }
        contentView.requestApplyInsets()
    }
}

/**
 * Extension to set up edge-to-edge for a BottomSheetDialogFragment.
 * Call this in onViewCreated() after the view is inflated.
 *
 * @param contentView Optional specific content view. If not provided, uses the fragment's view.
 * @param extendBehindNavBar Opt-in for the API-36 seamless-nav-bar behaviour. See
 *   [BottomSheetEdgeToEdgeHelper.setup] for what changes when enabled. Defaults to `false`
 *   so existing callers are unaffected.
 */
@MainThread
fun BottomSheetDialogFragment.setupEdgeToEdgeBottomSheet(
    contentView: View? = null,
    extendBehindNavBar: Boolean = false
) {
    val targetView = contentView ?: view ?: return
    BottomSheetEdgeToEdgeHelper.setup(this, targetView, extendBehindNavBar)
}
