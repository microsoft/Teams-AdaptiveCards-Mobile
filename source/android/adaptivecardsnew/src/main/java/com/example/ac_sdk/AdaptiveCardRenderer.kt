package com.example.ac_sdk


import android.content.Context
import android.text.Layout
import androidx.annotation.Nullable
import androidx.fragment.app.FragmentManager
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout


class AdaptiveCardRenderer private constructor() {

    companion object {
        const val VERSION = "1.6"
        private var instance: AdaptiveCardRenderer? = null
        private val defaultHostConfig = HostConfig()

        fun getInstance(): AdaptiveCardRenderer {
            if (instance == null) {
                instance = AdaptiveCardRenderer()
            }
            return instance!!
        }
    }

    fun render(
        context: Context,
        fragmentManager: FragmentManager,
        adaptiveCard: AdaptiveCard,
        cardActionHandler: ICardActionHandler,
        hostConfig: HostConfig = defaultHostConfig,
        @Nullable overflowActionRenderer: IOverflowActionRenderer? = null
    ): RenderedAdaptiveCard {
        val result = RenderedAdaptiveCard(adaptiveCard)
        //CardRendererRegistration.getInstance().registerOverflowActionRenderer(overflowActionRenderer)
        val cardView = internalRender(result, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, false, View.NO_ID)
        result.setView(cardView)
        return result
    }

    private fun renderCardElements(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        adaptiveCard: AdaptiveCard,
        cardActionHandler: ICardActionHandler,
        hostConfig: HostConfig,
        cardLayout: ViewGroup,
        renderArgs: RenderArgs,
        layoutToApply: Layout
    ) {
        try {
            CardRendererRegistration.getInstance().renderElements(
                renderedCard, context, fragmentManager, cardLayout, adaptiveCard.body, cardActionHandler, hostConfig, renderArgs, layoutToApply
            )
        } catch (e: AdaptiveFallbackException) {
            // No fallback should be performed here so we just catch the exception
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun internalRender(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        adaptiveCard: AdaptiveCard,
        cardActionHandler: ICardActionHandler,
        hostConfig: HostConfig,
        isInlineShowCard: Boolean,
        containerCardId: Int
    ): View {
        requireNotNull(hostConfig) { "hostConfig is null" }
        requireNotNull(renderedCard) { "renderedCard is null" }

        val rootLayout = LinearLayout(context).apply {
            layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            orientation = LinearLayout.VERTICAL
            clipChildren = false
            clipToPadding = false
        }

        /*
        val layoutToApply = Util.getLayoutToApply(adaptiveCard.layouts, hostConfig)
        val cardMinHeight = adaptiveCard.minHeight
        val cardLayout = StretchableElementLayout(context, adaptiveCard.height == HeightType.Stretch || cardMinHeight != 0L).apply {
            tag = adaptiveCard
            clipChildren = false
            clipToPadding = false
            orientation = LinearLayout.VERTICAL
            val padding = Util.dpToPixels(context, hostConfig.spacing.paddingSpacing)
            setPadding(padding, padding, padding, padding)
        }

        BaseCardElementRenderer.setMinHeight(cardMinHeight, rootLayout, context)
        BaseCardElementRenderer.applyRtl(adaptiveCard.rtl, cardLayout)
        ContainerRenderer.applyVerticalContentAlignment(cardLayout, adaptiveCard.verticalContentAlignment, layoutToApply)

        rootLayout.addView(cardLayout)

        var style = ContainerStyle.Default
        if (isInlineShowCard && hostConfig.actions.showCard.style != ContainerStyle.None) {
            style = hostConfig.actions.showCard.style
        }
        if (hostConfig.adaptiveCard.allowCustomStyle && adaptiveCard.style != ContainerStyle.None) {
            style = adaptiveCard.style
        }

        val renderArgs = RenderArgs().apply {
            containerStyle = style
            ancestorHasSelectAction = adaptiveCard.selectAction != null
            containerCardId = Util.getViewId(rootLayout)
        }
        renderedCard.setParentToCard(renderArgs.containerCardId, containerCardId)

        val color = hostConfig.getBackgroundColor(style)
        cardLayout.setBackgroundColor(Color.parseColor(color))

        when (layoutToApply.layoutContainerType) {
            LayoutContainerType.Flow -> {
                val flexboxLayout = getFlexboxContainerForLayout(context)
                Util.setHorizontalAlignmentForFlowLayout(flexboxLayout, layoutToApply)
                renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, flexboxLayout, renderArgs, layoutToApply)
                ContainerRenderer.applyItemFillForFlowLayout(layoutToApply, flexboxLayout)
                cardLayout.addView(flexboxLayout)
            }
            LayoutContainerType.AreaGrid -> {
                val areaGridLayoutView = getAreaGridLayoutView(context)
                renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, areaGridLayoutView, renderArgs, layoutToApply)
                cardLayout.addView(areaGridLayoutView)
            }
            else -> {
                renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, cardLayout, renderArgs, layoutToApply)
            }
        }

        if (hostConfig.supportsInteractivity) {
            val baseActionElementList = adaptiveCard.actions
            if (baseActionElementList != null && baseActionElementList.isNotEmpty()) {
                val (primaryElementVector, secondaryElementVector) = Util.splitActionsByMode(baseActionElementList, hostConfig, renderedCard)
                val showCardsLayout = LinearLayout(context).apply {
                    setBackgroundColor(Color.parseColor(color))
                    layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
                }
                rootLayout.addView(showCardsLayout)

                val actionLayoutRenderer = CardRendererRegistration.getInstance().actionLayoutRenderer
                actionLayoutRenderer?.let {
                    try {
                        renderArgs.rootLevelActions = !isInlineShowCard
                        val actionButtonsLayout = it.renderActions(renderedCard, context, fragmentManager, cardLayout, primaryElementVector, cardActionHandler, hostConfig, renderArgs)

                        if (secondaryElementVector.isNotEmpty()) {
                            val secondaryActionLayoutRenderer = CardRendererRegistration.getInstance().overflowActionLayoutRenderer
                            val rootActionLayout = if (actionButtonsLayout is ViewGroup) actionButtonsLayout else cardLayout
                            secondaryActionLayoutRenderer.renderActions(renderedCard, context, fragmentManager, rootActionLayout, secondaryElementVector, cardActionHandler, hostConfig, renderArgs)
                        }
                    } catch (e: AdaptiveFallbackException) {
                        e.printStackTrace()
                    }
                }
            }
        } else {
            renderedCard.addWarning(AdaptiveWarning(AdaptiveWarning.INTERACTIVITY_DISALLOWED, "Interactivity is not allowed. Actions not rendered."))
        }

        ContainerRenderer.setBackgroundImage(renderedCard, context, adaptiveCard.backgroundImage, hostConfig, cardLayout)
        ContainerRenderer.setSelectAction(renderedCard, renderedCard.adaptiveCard.selectAction, rootLayout, cardActionHandler, renderArgs)

        */
        return rootLayout
    }

//    private fun getAreaGridLayoutView(context: Context): AreaGridLayoutView {
//        return AreaGridLayoutView(context).apply {
//            layoutParams = FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
//        }
//    }

    private fun getFlexboxContainerForLayout(context: Context): FlexboxLayout {
        return FlexboxLayout(context).apply {
            flexDirection = FlexDirection.ROW
            flexWrap = FlexWrap.WRAP
            layoutParams = FlexboxLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
    }
}