// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.scrollingpage

import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.AdapterDataObserver
import androidx.viewpager2.widget.ViewPager2

/**
 * Implementation of [IPagerAttacher] for [ViewPager2].
 */
class ViewPager2Attacher : IPagerAttacher<ViewPager2> {

    private var dataSetObserver2: AdapterDataObserver? = null
    private var onPageChangeListener2: ViewPager2.OnPageChangeCallback? = null
    private var pager: ViewPager2? = null
    private var attachedAdapter: RecyclerView.Adapter<*>? = null

    override fun attachToPager(indicator: ScrollingPageControlView, pager: ViewPager2) {
        this.attachedAdapter = pager.adapter
        this.pager = pager

        updateIndicatorDotsAndPosition(indicator)

        dataSetObserver2 = object : AdapterDataObserver() {
            override fun onChanged() {
                indicator.reattach()
            }
        }.also {
            attachedAdapter?.registerAdapterDataObserver(it)
        }

        onPageChangeListener2 = object : ViewPager2.OnPageChangeCallback() {
            var idleState = true

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
                updateIndicatorOnPagerScrolled(indicator, position, positionOffset)
            }

            override fun onPageSelected(position: Int) {
                // Update the selected position without conditions.
                indicator.onPositionSelected(pager.currentItem)

                if (idleState) {
                    updateIndicatorDotsAndPosition(indicator)
                }
            }

            override fun onPageScrollStateChanged(state: Int) {
                idleState = state == ViewPager2.SCROLL_STATE_IDLE
            }
        }.also {
            pager.registerOnPageChangeCallback(it)
        }
    }

    override fun detachFromPager() {
        dataSetObserver2?.let { attachedAdapter?.unregisterAdapterDataObserver(it) }
        onPageChangeListener2?.let { pager?.unregisterOnPageChangeCallback(it) }
    }

    private fun updateIndicatorOnPagerScrolled(indicator: ScrollingPageControlView, position: Int, positionOffset: Float) {
        // ViewPager may emit a negative value for positionOffset when scrolling quickly.
        val offset: Float = positionOffset.coerceIn(0f, 1f)
        indicator.onPageScrolled(position, offset)
    }

    private fun updateIndicatorDotsAndPosition(indicator: ScrollingPageControlView) {
        attachedAdapter?.let {
            indicator.dotCount = it.itemCount
        }
        pager?.currentItem?.let {
            indicator.updateIndicatorDotsAndPosition(it)
        }
    }
}
