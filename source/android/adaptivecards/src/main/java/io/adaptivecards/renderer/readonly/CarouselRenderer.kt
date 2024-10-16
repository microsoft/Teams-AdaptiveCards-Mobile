// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import androidx.viewpager2.widget.ViewPager2
import com.google.android.flexbox.AlignItems
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.R
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.Carousel
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.PageAnimation
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.carousel.CarouselPageAdapter
import io.adaptivecards.renderer.layout.carousel.CrossFadePageTransformer
import io.adaptivecards.renderer.layout.carousel.NoAnimationPageTransformer
import io.adaptivecards.renderer.layout.scrollingpage.ScrollingPageControlView
import io.adaptivecards.renderer.layout.scrollingpage.ScrollingPageControlViewConfiguration
import io.adaptivecards.renderer.registration.FeatureFlagResolverUtility

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
        val viewPager = createViewPager(context, carousel, renderedCard, fragmentManager, cardActionHandler, hostConfig, renderArgs)
        carouselView.addView(viewPager)

        if (pages.size > 1) {
            val scrollingIndicator = createScrollingPageControlView(context, hostConfig, viewPager)
            carouselView.addView(scrollingIndicator)
        }
        viewGroup.addView(carouselView)
        return carouselView
    }

    private fun createCarouselView(context: Context, carousel: Carousel): ViewGroup {
        val carouselView = createContainerLayout(context)
        carouselView.tag = TagContent(carousel)
        return carouselView
    }

    private fun createViewPager(
        context: Context,
        carousel: Carousel,
        renderedCard: RenderedAdaptiveCard,
        fragmentManager: FragmentManager,
        cardActionHandler: ICardActionHandler?,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): ViewPager2 {
        val viewPager = ViewPager2(context)
        val layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        viewPager.layoutParams = layoutParams
        viewPager.offscreenPageLimit = carousel.GetPages().size
        viewPager.adapter = CarouselPageAdapter(carousel.GetPages(), renderedCard, cardActionHandler, hostConfig, renderArgs, fragmentManager)
        getViewPagerPageTransformer(carousel.pageAnimation)?.apply { viewPager.setPageTransformer(this) }
        return viewPager
    }

    private fun createScrollingPageControlView(context: Context, hostConfig: HostConfig, viewPager2: ViewPager2) : ViewGroup {
        val dotColor = Color.parseColor(hostConfig.GetPageControlConfig().unselectedTintColor)
        val dotSelectedColor = Color.parseColor(hostConfig.GetPageControlConfig().selectedTintColor)
        val configuration = ScrollingPageControlViewConfiguration(dotColor = dotColor, dotSelectedColor = dotSelectedColor)

        val scrollingPageControlView = ScrollingPageControlView(context = context, configuration = configuration).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            this.attachToPager(viewPager2)
        }

        return createContainerLayout(context).apply {
            val padding = context.resources.getDimensionPixelSize(R.dimen.scrollingpagecontrolview_padding_top_bottom)
            this.setPadding(0, padding, 0, padding)
            addView(scrollingPageControlView)
        }
    }

    private fun createContainerLayout(context: Context) : FlexboxLayout {
        return FlexboxLayout(context).apply {
            layoutParams = FlexboxLayout.LayoutParams(FlexboxLayout.LayoutParams.MATCH_PARENT, FlexboxLayout.LayoutParams.WRAP_CONTENT)
            flexDirection = FlexDirection.COLUMN
            alignItems = AlignItems.CENTER
        }
    }

    private fun getViewPagerPageTransformer(pageAnimation: PageAnimation): ViewPager2.PageTransformer? {
        return when (pageAnimation) {
            PageAnimation.None -> NoAnimationPageTransformer()
            PageAnimation.CrossFade -> CrossFadePageTransformer()
            PageAnimation.Slide -> null // Default behaviour is sliding
        }
    }
}
