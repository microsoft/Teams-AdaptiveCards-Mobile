// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.CarouselPage
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.renderer.AdaptiveFallbackException
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.registration.CardRendererRegistration

/**
 * Renderer for [CarouselPage] element.
 */
object CarouselPageRenderer : BaseCardElementRenderer() {

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
        val carouselPage = Util.castTo(baseCardElement, CarouselPage::class.java)
        val layoutToApply = Util.getLayoutToApply(carouselPage.GetLayouts(), hostConfig)
        val carouselPageView = ContainerRenderer.getAppropriateContainerForLayout(context, layoutToApply, carouselPage)

        setMinHeight(carouselPage.GetMinHeight(), carouselPageView, context)

        // Add this two for allowing children to bleed
        carouselPageView.clipChildren = false
        carouselPageView.clipToPadding = false

        ContainerRenderer.applyVerticalContentAlignment(carouselPageView, carouselPage.GetVerticalContentAlignment(), layoutToApply)

        val containerStyle = renderArgs.containerStyle
        val styleForThis = ContainerRenderer.getLocalContainerStyle(carouselPage, containerStyle)

        ContainerRenderer.applyPadding(styleForThis, containerStyle, carouselPageView, hostConfig, carouselPage.GetShowBorder())
        ContainerRenderer.applyContainerStyle(styleForThis, containerStyle, carouselPageView, hostConfig)
        ContainerRenderer.applyBleed(carouselPage, carouselPageView, context, hostConfig)
        ContainerRenderer.applyBorder(styleForThis, carouselPageView, hostConfig, carouselPage.GetElementType(), carouselPage.GetShowBorder())
        ContainerRenderer.applyRoundedCorners(carouselPageView, hostConfig, carouselPage.GetElementType(), carouselPage.GetRoundedCorners())
        applyRtl(carouselPage.GetRtl(), carouselPageView)

        val carouselPageRenderArgs = RenderArgs(renderArgs)
        carouselPageRenderArgs.containerStyle = styleForThis
        carouselPageRenderArgs.horizontalAlignment = HorizontalAlignment.Left
        carouselPageRenderArgs.ancestorHasSelectAction = renderArgs.ancestorHasSelectAction || carouselPage.GetSelectAction() != null

        if (!carouselPage.GetItems().isEmpty()) {
            try {
                CardRendererRegistration.getInstance().renderElements(renderedCard,
                        context,
                        fragmentManager,
                        carouselPageView,
                        carouselPage.GetItems(),
                        cardActionHandler,
                        hostConfig,
                        carouselPageRenderArgs,
                        layoutToApply)
                ContainerRenderer.applyItemFillForFlowLayout(layoutToApply, carouselPageView)
            } catch (e: AdaptiveFallbackException) {
                throw e
            }
        }

        ContainerRenderer.setBackgroundImage(renderedCard, context, carouselPage.GetBackgroundImage(), hostConfig, renderArgs, carouselPageView)
        ContainerRenderer.setSelectAction(renderedCard, carouselPage.GetSelectAction(), carouselPageView, cardActionHandler, fragmentManager, hostConfig, renderArgs)
        viewGroup.addView(carouselPageView)
        return carouselPageView
    }
}
