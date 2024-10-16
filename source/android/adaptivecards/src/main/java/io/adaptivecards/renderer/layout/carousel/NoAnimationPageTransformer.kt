// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.carousel

import android.view.View
import androidx.viewpager2.widget.ViewPager2
import io.adaptivecards.objectmodel.Carousel
import kotlin.math.abs

/**
 * [ViewPager2.PageTransformer] implementation for None animation for [Carousel]
 */
class NoAnimationPageTransformer : ViewPager2.PageTransformer {

    override fun transformPage(page: View, position: Float) {
        if (position < -1) { // [-Infinity,-1)
            page.alpha = 0f // This page is way off-screen to the left.
        } else if (position <= 1) { // [-1,1]
            // Fade in/out the page faster
            page.alpha = 1 - 2f * abs(position)
            page.translationX = -position * page.width // Snap to position
        } else { // (1,+Infinity]
            page.alpha = 0f // This page is way off-screen to the right.
        }
    }
}
