// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import android.content.Context;
import android.graphics.Color;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import android.util.Pair;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.google.android.flexbox.FlexDirection;
import com.google.android.flexbox.FlexWrap;
import com.google.android.flexbox.FlexboxLayout;

import io.adaptivecards.objectmodel.ACTheme;
import io.adaptivecards.objectmodel.AdaptiveCard;
import io.adaptivecards.objectmodel.BaseActionElementVector;
import io.adaptivecards.objectmodel.CardElementType;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.HeightType;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.Layout;
import io.adaptivecards.objectmodel.LayoutContainerType;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.layout.AreaGridLayoutView;
import io.adaptivecards.renderer.layout.StretchableElementLayout;
import io.adaptivecards.renderer.readonly.ContainerRenderer;
import io.adaptivecards.renderer.registration.CardRendererRegistration;

public class AdaptiveCardRenderer
{
    public static final String VERSION = "1.6";

    protected AdaptiveCardRenderer()
    {
    }

    public static AdaptiveCardRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new AdaptiveCardRenderer();
        }

        return s_instance;
    }

    public RenderedAdaptiveCard render(Context context, FragmentManager fragmentManager, AdaptiveCard adaptiveCard, ICardActionHandler cardActionHandler)
    {
        return render(context, fragmentManager, adaptiveCard, cardActionHandler, defaultHostConfig);
    }
    public RenderedAdaptiveCard render(Context context, FragmentManager fragmentManager, AdaptiveCard adaptiveCard, ICardActionHandler cardActionHandler, @Nullable IOverflowActionRenderer overflowActionRenderer)
    {
        return render(context, fragmentManager, adaptiveCard, cardActionHandler, overflowActionRenderer, defaultHostConfig);
    }

    // AdaptiveCard ObjectModel is binded to the UI and Action
    public RenderedAdaptiveCard render(
            Context context,
            FragmentManager fragmentManager,
            AdaptiveCard adaptiveCard,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig)
    {
        return render(context, fragmentManager, adaptiveCard, cardActionHandler, null, hostConfig);
    }

    public RenderedAdaptiveCard render(
        Context context,
        FragmentManager fragmentManager,
        AdaptiveCard adaptiveCard,
        ICardActionHandler cardActionHandler,
        @Nullable IOverflowActionRenderer overflowActionRenderer,
        HostConfig hostConfig) {
        ACTheme acTheme = CardRendererRegistration.getInstance().getTheme();;
        String languageTag = CardRendererRegistration.getInstance().getLanguageTag();
        RenderedAdaptiveCard result = new RenderedAdaptiveCard(adaptiveCard, acTheme, languageTag);
        CardRendererRegistration.getInstance().registerOverflowActionRenderer(overflowActionRenderer);
        View cardView = internalRender(result, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, false, View.NO_ID, null, null);
        result.setView(cardView);
        return result;
    }

    private void renderCardElements(RenderedAdaptiveCard renderedCard,
                                    Context context,
                                    FragmentManager fragmentManager,
                                    AdaptiveCard adaptiveCard,
                                    ICardActionHandler cardActionHandler,
                                    HostConfig hostConfig,
                                    ViewGroup cardLayout,
                                    RenderArgs renderArgs,
                                    Layout layoutToApply)
    {
        try
        {
            CardRendererRegistration.getInstance().renderElements(renderedCard, context, fragmentManager, cardLayout, adaptiveCard.GetBody(), cardActionHandler, hostConfig, renderArgs, layoutToApply);
        }
        // Catches the exception as the method throws it for performing fallback with elements inside the card,
        // no fallback should be performed here so we just catch the exception
        catch (AdaptiveFallbackException e){}
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public View internalRender(RenderedAdaptiveCard renderedCard,
                               Context context,
                               FragmentManager fragmentManager,
                               AdaptiveCard adaptiveCard,
                               ICardActionHandler cardActionHandler,
                               HostConfig hostConfig,
                               boolean isInlineShowCard,
                               long containerCardId,
                               @Nullable RenderArgs renderArgs,
                               @Nullable String backgroundColor)
    {
        if (hostConfig == null)
        {
            throw new IllegalArgumentException("hostConfig is null");
        }

        if (renderedCard == null)
        {
            throw new IllegalArgumentException("renderedCard is null");
        }

        // rootLayout is the layout that contains the rendered card (elements + actions) and the show cards
        LinearLayout rootLayout = new LinearLayout(context);
        rootLayout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        rootLayout.setOrientation(LinearLayout.VERTICAL);

        // Add this two for allowing children to bleed

        Layout layoutToApply = Util.getLayoutToApply(adaptiveCard.GetLayouts(), hostConfig);

        // cardLayout only contains the rendered card composed of elements and actions
        long cardMinHeight = adaptiveCard.GetMinHeight();
        LinearLayout cardLayout = new StretchableElementLayout(context, (adaptiveCard.GetHeight() == HeightType.Stretch) || (cardMinHeight != 0));
        cardLayout.setTag(adaptiveCard);

        // Add this two for allowing children to bleed
        cardLayout.setClipToPadding(false);
        cardLayout.setClipToOutline(true);

        BaseCardElementRenderer.setMinHeight(cardMinHeight, rootLayout, context);
        BaseCardElementRenderer.applyRtl(adaptiveCard.GetRtl(), cardLayout);
        ContainerRenderer.applyVerticalContentAlignment(cardLayout, adaptiveCard.GetVerticalContentAlignment(), layoutToApply);

        cardLayout.setOrientation(LinearLayout.VERTICAL);
        int padding = Util.dpToPixels(context, hostConfig.GetSpacing().getPaddingSpacing());
        cardLayout.setPadding(padding, padding, padding, padding);

        rootLayout.addView(cardLayout);

        ContainerStyle style = ContainerStyle.Default;

        if (isInlineShowCard && hostConfig.GetActions().getShowCard().getStyle() != ContainerStyle.None)
        {
            style = hostConfig.GetActions().getShowCard().getStyle();
        }

        if (hostConfig.GetAdaptiveCard().getAllowCustomStyle() && adaptiveCard.GetStyle() != ContainerStyle.None)
        {
            style = adaptiveCard.GetStyle();
        }

        if (renderArgs == null) {
            renderArgs = new RenderArgs();
        }
        renderArgs.setContainerStyle(style);
        renderArgs.setAncestorHasSelectAction(adaptiveCard.GetSelectAction() != null);

        long cardId = Util.getViewId(rootLayout);
        renderArgs.setContainerCardId(cardId);
        renderedCard.setParentToCard(cardId, containerCardId);

        // Render the body section of the Adaptive Card
        if (backgroundColor == null) {
            backgroundColor = hostConfig.GetBackgroundColor(style);
        }
        // Set corner radius for cardLayout
        float cornerRadiusPx = Util.dpToPixels(context, hostConfig.GetCornerRadius(CardElementType.Container));
        android.graphics.drawable.GradientDrawable cardBackground = new android.graphics.drawable.GradientDrawable();
        cardBackground.setColor(Color.parseColor(backgroundColor));
        cardBackground.setCornerRadius(cornerRadiusPx);
        cardLayout.setBackground(cardBackground);

        /**
         * Rendering the body section of adaptive card inside the flexbox layout if the layout is flow
         * and adding the flow layout to the card layout
         **/
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow) {
            FlexboxLayout flexboxLayout = getFlexboxContainerForLayout(context);
            Util.setHorizontalAlignmentForFlowLayout(flexboxLayout, layoutToApply);
            renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, flexboxLayout, renderArgs, layoutToApply);
            ContainerRenderer.applyItemFillForFlowLayout(layoutToApply, flexboxLayout);
            cardLayout.addView(flexboxLayout);
        } else if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.AreaGrid) {
            AreaGridLayoutView areaGridLayoutView = getAreaGridLayoutView(context);
            renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, areaGridLayoutView, renderArgs, layoutToApply);
            cardLayout.addView(areaGridLayoutView);
        } else {
            renderCardElements(renderedCard, context, fragmentManager, adaptiveCard, cardActionHandler, hostConfig, cardLayout, renderArgs, layoutToApply);
        }

        if (hostConfig.GetSupportsInteractivity())
        {
            // Actions are optional
            BaseActionElementVector baseActionElementList = adaptiveCard.GetActions();
            if (baseActionElementList != null && baseActionElementList.size() > 0)
            {
                //Split Action Elements and render.
                Pair<BaseActionElementVector, BaseActionElementVector> actionElementVectorPair = Util.splitActionsByMode(baseActionElementList, hostConfig, renderedCard);
                BaseActionElementVector primaryElementVector = actionElementVectorPair.first;
                BaseActionElementVector secondaryElementVector = actionElementVectorPair.second;

                LinearLayout showCardsLayout = new LinearLayout(context);
                showCardsLayout.setBackgroundColor(Color.parseColor(backgroundColor));
                showCardsLayout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                rootLayout.addView(showCardsLayout);

                IActionLayoutRenderer actionLayoutRenderer = CardRendererRegistration.getInstance().getActionLayoutRenderer();
                if(actionLayoutRenderer != null)
                {
                    try
                    {
                        renderArgs.setRootLevelActions(!isInlineShowCard);
                        View actionButtonsLayout = actionLayoutRenderer.renderActions(renderedCard, context, fragmentManager, cardLayout, primaryElementVector, cardActionHandler, hostConfig, renderArgs);

                        if (!secondaryElementVector.isEmpty())
                        {
                            IActionLayoutRenderer secondaryActionLayoutRenderer = CardRendererRegistration.getInstance().getOverflowActionLayoutRenderer();
                            //if the actionButtonsLayout is not a viewGroup, then use cardLayout as a root.
                            ViewGroup rootActionLayout = actionButtonsLayout instanceof ViewGroup ? (ViewGroup) actionButtonsLayout : cardLayout;
                            secondaryActionLayoutRenderer.renderActions(renderedCard, context, fragmentManager, rootActionLayout, secondaryElementVector, cardActionHandler, hostConfig, renderArgs);
                        }
                    }
                    // Catches the exception as the method throws it for performing fallback with elements inside the card,
                    // no fallback should be performed here so we just catch the exception
                    catch (AdaptiveFallbackException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        else
        {
            renderedCard.addWarning(new AdaptiveWarning(AdaptiveWarning.INTERACTIVITY_DISALLOWED, "Interactivity is not allowed. Actions not rendered."));
        }

        ContainerRenderer.setBackgroundImage(renderedCard, context, adaptiveCard.GetBackgroundImage(), hostConfig, renderArgs, cardLayout);
        ContainerRenderer.setSelectAction(renderedCard, renderedCard.getAdaptiveCard().GetSelectAction(), rootLayout, cardActionHandler, fragmentManager, hostConfig, renderArgs);

        return rootLayout;
    }

    private AreaGridLayoutView getAreaGridLayoutView(Context context) {
        AreaGridLayoutView areaGridLayoutView = new AreaGridLayoutView(context);
        areaGridLayoutView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return areaGridLayoutView;
    }

    private static FlexboxLayout getFlexboxContainerForLayout(Context context) {
        FlexboxLayout flexboxLayout = new FlexboxLayout(context);
        flexboxLayout.setFlexDirection(FlexDirection.ROW);
        flexboxLayout.setFlexWrap(FlexWrap.WRAP);
        flexboxLayout.setLayoutParams(new FlexboxLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return flexboxLayout;
    }

    private static AdaptiveCardRenderer s_instance = null;
    private HostConfig defaultHostConfig = new HostConfig();
}
