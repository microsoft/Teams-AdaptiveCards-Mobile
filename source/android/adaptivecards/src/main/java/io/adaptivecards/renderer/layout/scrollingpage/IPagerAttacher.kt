// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.scrollingpage

/**
 * Interface for attaching to custom pagers.
 *
 * @param <T> custom pager class
 */
interface IPagerAttacher<T> {
    fun attachToPager(indicator: ScrollingPageControlView, pager: T)
    fun detachFromPager()
}