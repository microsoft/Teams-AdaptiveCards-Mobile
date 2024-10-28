// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.scrollingpage

import androidx.annotation.ColorInt

/**
 * ScrollingPageControlViewConfiguration
 * @param dotSize The diameter of a dot.
 * @param dotSelectedSize The diameter of a currently selected dot.
 * @param dotMinimumSize The minimum size for overflow dots.
 * @param dotColor The color of a dot.
 * @param dotSelectedColor The color of the currently selected dot.
 * @param dotSpacing The distance from center to center of each dot.
 * @param visibleDotCount The maximum number of dots which will be visible at the same time.
 * @param visibleDotThreshold The minimum number of dots which should be visible. If pager has less pages than visibleDotThreshold, no dots will be shown.
 * @param looped Looped pagers support.
 * @param entityDescription Entity description included as part of an overall contentDescription.
 */
class ScrollingPageControlViewConfiguration (
    val dotSize: Int? = null,
    val dotSelectedSize: Int? = null,
    val dotMinimumSize: Int? = null,
    @ColorInt val dotColor: Int,
    @ColorInt val dotSelectedColor: Int,
    val dotSpacing: Int? = null,
    val visibleDotCount: Int? = null,
    val visibleDotThreshold: Int? = null,
    val looped: Boolean = false,
    val entityDescription: String? = null,
)
