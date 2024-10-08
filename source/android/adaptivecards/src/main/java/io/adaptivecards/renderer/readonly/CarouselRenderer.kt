// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import androidx.viewpager2.widget.ViewPager2
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.Carousel
import io.adaptivecards.objectmodel.HeightType
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.PageAnimation
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.StretchableElementLayout
import io.adaptivecards.renderer.layout.carousel.CarouselPageAdapter
import io.adaptivecards.renderer.layout.carousel.CrossFadePageTransformer

/**
 * Renderer for [Carousel] element.
 */
object CarouselRenderer : BaseCardElementRenderer() {

    override fun render(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        viewGroup: ViewGroup,
        baseCardElement: BaseCardElement,
        cardActionHandler: ICardActionHandler?,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): View? {
        val carousel = Util.castTo(baseCardElement, Carousel::class.java)
        val pages = carousel.GetPages()

        if (pages.isEmpty()) {
            return null
        }

        val carouselView = createCarouselView(context, carousel)
        val viewPager = createViewPager(context, carousel)
        viewPager.adapter = CarouselPageAdapter(pages, renderedCard, cardActionHandler, hostConfig, renderArgs, fragmentManager)
        carouselView.addView(viewPager)
        viewGroup.addView(carouselView)
        return carouselView
    }

    private fun createCarouselView(context: Context, carousel: Carousel): ViewGroup {
        val carouselView = StretchableElementLayout(context, carousel.GetHeight() === HeightType.Stretch)
        carouselView.tag = TagContent(carousel)
        carouselView.orientation = LinearLayout.VERTICAL
        return carouselView
    }

    private fun createViewPager(context: Context, carousel: Carousel): ViewPager2 {
        val viewPager = ViewPager2(context)
        val layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        viewPager.layoutParams = layoutParams
        getViewPagerPageTransformer(carousel.pageAnimation)?.apply { viewPager.setPageTransformer(this) }
        return viewPager
    }

    private fun getViewPagerPageTransformer(pageAnimation: PageAnimation): ViewPager2.PageTransformer? {
        return when(pageAnimation) {
            PageAnimation.None -> null // For None should we use default
            PageAnimation.CrossFade -> CrossFadePageTransformer()
            PageAnimation.Slide -> null // Default behaviour is sliding
        }
    }
}
