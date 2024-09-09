// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.AsyncTask;
import android.os.Build;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.TooltipCompat;
import androidx.core.view.AccessibilityDelegateCompat;
import androidx.core.view.ViewCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat;
import androidx.fragment.app.FragmentManager;

import com.google.android.flexbox.AlignContent;
import com.google.android.flexbox.FlexDirection;
import com.google.android.flexbox.FlexWrap;
import com.google.android.flexbox.FlexboxLayout;

import io.adaptivecards.objectmodel.ActionType;
import io.adaptivecards.objectmodel.BackgroundImage;
import io.adaptivecards.objectmodel.BaseActionElement;
import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.CardElementType;
import io.adaptivecards.objectmodel.Container;
import io.adaptivecards.objectmodel.ContainerBleedDirection;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.ExecuteAction;
import io.adaptivecards.objectmodel.FlowLayout;
import io.adaptivecards.objectmodel.HeightType;
import io.adaptivecards.objectmodel.HorizontalAlignment;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.ItemFit;
import io.adaptivecards.objectmodel.Layout;
import io.adaptivecards.objectmodel.LayoutContainerType;
import io.adaptivecards.objectmodel.StyledCollectionElement;
import io.adaptivecards.objectmodel.SubmitAction;
import io.adaptivecards.objectmodel.VerticalContentAlignment;
import io.adaptivecards.renderer.AdaptiveFallbackException;
import io.adaptivecards.renderer.BackgroundImageLoaderAsync;
import io.adaptivecards.renderer.BaseActionElementRenderer;
import io.adaptivecards.renderer.BaseCardElementRenderer;
import io.adaptivecards.renderer.IOnlineImageLoader;
import io.adaptivecards.renderer.RenderArgs;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.TagContent;
import io.adaptivecards.renderer.Util;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.layout.StretchableElementLayout;
import io.adaptivecards.renderer.layout.AreaGridLayoutView;
import io.adaptivecards.renderer.registration.CardRendererRegistration;

public class ContainerRenderer extends BaseCardElementRenderer
{
    protected ContainerRenderer()
    {
    }

    public static ContainerRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new ContainerRenderer();
        }

        return s_instance;
    }

    @Override
    public View render(
            RenderedAdaptiveCard renderedCard,
            Context context,
            FragmentManager fragmentManager,
            ViewGroup viewGroup,
            BaseCardElement baseCardElement,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig,
            RenderArgs renderArgs) throws Exception
    {
        Container container = Util.castTo(baseCardElement, Container.class);

        Layout layoutToApply = Util.getLayoutToApply(container.GetLayouts(), hostConfig);
        ViewGroup containerView = getAppropriateContainerForLayout(context, layoutToApply, container);

        setMinHeight(container.GetMinHeight(), containerView, context);

        // Add this two for allowing children to bleed
        containerView.setClipChildren(false);
        containerView.setClipToPadding(false);

        applyVerticalContentAlignment(containerView, container.GetVerticalContentAlignment(), layoutToApply);

        ContainerStyle containerStyle = renderArgs.getContainerStyle();
        ContainerStyle styleForThis = getLocalContainerStyle(container, containerStyle);
        applyPadding(styleForThis, containerStyle, containerView, hostConfig, container.GetShowBorder());
        applyContainerStyle(styleForThis, containerStyle, containerView, hostConfig);
        applyBleed(container, containerView, context, hostConfig);
        applyBorder(styleForThis, containerView, hostConfig, container.GetElementType(), container.GetShowBorder());
        applyRoundedCorners(containerView, hostConfig, container.GetElementType(), container.GetRoundedCorners());
        BaseCardElementRenderer.applyRtl(container.GetRtl(), containerView);

        RenderArgs containerRenderArgs = new RenderArgs(renderArgs);
        containerRenderArgs.setContainerStyle(styleForThis);
        containerRenderArgs.setHorizontalAlignment(HorizontalAlignment.Left);
        containerRenderArgs.setAncestorHasSelectAction(renderArgs.getAncestorHasSelectAction() || (container.GetSelectAction() != null));
        if (!container.GetItems().isEmpty())
        {
            try
            {
                CardRendererRegistration.getInstance().renderElements(renderedCard,
                                                              context,
                                                              fragmentManager,
                                                              containerView,
                                                              container.GetItems(),
                                                              cardActionHandler,
                                                              hostConfig,
                                                              containerRenderArgs,
                                                              layoutToApply);

                applyItemFillForFlowLayout(layoutToApply, containerView);
            }
            catch (AdaptiveFallbackException e)
            {
                throw e;
            }
        }
        ContainerRenderer.setBackgroundImage(renderedCard, context, container.GetBackgroundImage(), hostConfig, containerView);
        setSelectAction(renderedCard, container.GetSelectAction(), containerView, cardActionHandler, renderArgs);
        viewGroup.addView(containerView);
        return containerView;
    }

    /**
     * Vertically align content within the given container
     * @param container Layout whose children need to be vertically aligned
     * @param verticalContentAlignment Alignment attribute
     */
    public static void applyVerticalContentAlignment(ViewGroup container, VerticalContentAlignment verticalContentAlignment, Layout layoutToApply)
    {
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow && container instanceof FlexboxLayout) {
            int alignContent = AlignContent.FLEX_START;
            if (verticalContentAlignment == VerticalContentAlignment.Center)
            {
                alignContent = AlignContent.CENTER;
            }
            else if (verticalContentAlignment == VerticalContentAlignment.Bottom)
            {
                alignContent = AlignContent.FLEX_END;
            }
            ((FlexboxLayout) container).setAlignContent(alignContent);
        } else if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.AreaGrid && container instanceof AreaGridLayoutView) {
            int alignContent = AlignContent.FLEX_START;
            if (verticalContentAlignment == VerticalContentAlignment.Center)
            {
                alignContent = AlignContent.CENTER;
            }
            else if (verticalContentAlignment == VerticalContentAlignment.Bottom)
            {
                alignContent = AlignContent.FLEX_END;
            }
            ((AreaGridLayoutView) container).setAreaGridAlignContent(alignContent);
        } else {
            int gravity = Gravity.TOP;
            if(verticalContentAlignment == VerticalContentAlignment.Center)
            {
                gravity = Gravity.CENTER;
            }
            else if(verticalContentAlignment == VerticalContentAlignment.Bottom)
            {
                gravity = Gravity.BOTTOM;
            }
            ((LinearLayout) container).setGravity(gravity);
        }
    }

    /**
     * @deprecated renamed to {@link #applyBleed}
     */
    public static void ApplyBleed(StyledCollectionElement collectionElement, ViewGroup collectionElementView, Context context, HostConfig hostConfig)
    {
        applyBleed(collectionElement, collectionElementView, context, hostConfig);
    }

    public static void applyBleed(StyledCollectionElement collectionElement, ViewGroup collectionElementView, Context context, HostConfig hostConfig)
    {
        if (collectionElement.GetBleed() && collectionElement.GetCanBleed())
        {
            int padding = Util.dpToPixels(context, hostConfig.GetSpacing().getPaddingSpacing());
            ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) collectionElementView.getLayoutParams();
            // TODO: Check RTL support
            int marginLeft = layoutParams.leftMargin, marginRight = layoutParams.rightMargin, marginTop = layoutParams.topMargin, marginBottom = layoutParams.bottomMargin;

            ContainerBleedDirection bleedDirection = collectionElement.GetBleedDirection();

            if ((bleedDirection.swigValue() & ContainerBleedDirection.BleedLeft.swigValue()) != ContainerBleedDirection.BleedRestricted.swigValue())
            {
                marginLeft = -padding;
            }

            if ((bleedDirection.swigValue() & ContainerBleedDirection.BleedRight.swigValue()) != ContainerBleedDirection.BleedRestricted.swigValue())
            {
                marginRight = -padding;
            }

            if ((bleedDirection.swigValue() & ContainerBleedDirection.BleedUp.swigValue()) != ContainerBleedDirection.BleedRestricted.swigValue())
            {
                marginTop = -padding;
            }

            if ((bleedDirection.swigValue() & ContainerBleedDirection.BleedDown.swigValue()) != ContainerBleedDirection.BleedRestricted.swigValue())
            {
                marginBottom = -padding;
            }

            layoutParams.setMargins(marginLeft, marginTop, marginRight, marginBottom);
            collectionElementView.setLayoutParams(layoutParams);
        }
    }

    /**
     * @deprecated Separated into specific {@link #applyPadding} and {@link #applyContainerStyle}.
     */
    public static void ApplyPadding(ContainerStyle computedContainerStyle, ContainerStyle parentContainerStyle, ViewGroup collectionElementView, HostConfig hostConfig)
    {
        applyPadding(computedContainerStyle, parentContainerStyle, collectionElementView, hostConfig);
        applyContainerStyle(computedContainerStyle, parentContainerStyle, collectionElementView, hostConfig);
    }

    public static void applyPadding(ContainerStyle computedContainerStyle, ContainerStyle parentContainerStyle, ViewGroup collectionElementView, HostConfig hostConfig)
    {
        applyPadding(computedContainerStyle, parentContainerStyle, collectionElementView, hostConfig, false);
    }

    public static void applyPadding(ContainerStyle computedContainerStyle, ContainerStyle parentContainerStyle, ViewGroup collectionElementView, HostConfig hostConfig, boolean hasBorder)
    {
        if (hasBorder || computedContainerStyle != parentContainerStyle)
        {
            int padding = Util.dpToPixels(collectionElementView.getContext(), hostConfig.GetSpacing().getPaddingSpacing());
            collectionElementView.setPadding(padding, padding, padding, padding);
        }
    }

    public static void applyBorder(ContainerStyle containerStyle, ViewGroup collectionElementView, HostConfig hostConfig, CardElementType cardElementType, boolean showBorder) {
        if (showBorder) {
            float borderWidth = (float) hostConfig.GetBorderWidth(cardElementType);
            int borderWidthInPixels = Util.dpToPixels(collectionElementView.getContext(), borderWidth);
            int borderColor = Color.parseColor(hostConfig.GetBorderColor(containerStyle));
            if (collectionElementView.getBackground() instanceof GradientDrawable) {
                ((GradientDrawable) collectionElementView.getBackground()).setStroke(borderWidthInPixels, borderColor);
            } else {
                GradientDrawable gradientDrawable = new GradientDrawable();
                gradientDrawable.setStroke(borderWidthInPixels, borderColor);
                collectionElementView.setBackground(gradientDrawable);
            }
        }
    }

    public static void applyRoundedCorners(ViewGroup collectionElementView, HostConfig hostConfig, CardElementType cardElementType, boolean roundedCorners) {
        if (roundedCorners) {
            float cornerRadius = (float) hostConfig.GetCornerRadius(cardElementType);
            float cornerRadiusInPixels = Util.dpToPixels(collectionElementView.getContext(), cornerRadius);
            if (collectionElementView.getBackground() instanceof GradientDrawable) {
                ((GradientDrawable) collectionElementView.getBackground()).setCornerRadius(cornerRadiusInPixels);
            } else {
                GradientDrawable gradientDrawable = new GradientDrawable();
                gradientDrawable.setCornerRadius(cornerRadiusInPixels);
                collectionElementView.setBackground(gradientDrawable);
            }
        }
    }

    public static void applyItemFillForFlowLayout(Layout layoutToApply, ViewGroup flexboxLayout) {
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow) {
            for (int i = 0; i < flexboxLayout.getChildCount(); i++) {
                FlowLayout flowLayout = Util.castTo(layoutToApply, FlowLayout.class);
                View child = flexboxLayout.getChildAt(i);
                FlexboxLayout.LayoutParams layoutParams = (FlexboxLayout.LayoutParams) child.getLayoutParams();
                if (flowLayout.GetItemFit() == ItemFit.Fill) {
                    layoutParams.setFlexGrow(1f);
                }
                child.setLayoutParams(layoutParams);
            }
        }
    }

    public static void applyContainerStyle(ContainerStyle computedContainerStyle, ContainerStyle parentContainerStyle, ViewGroup collectionElementView, HostConfig hostConfig)
    {
        if (computedContainerStyle != parentContainerStyle)
        {
            String backgroundColor = hostConfig.GetBackgroundColor(computedContainerStyle);
            int color = Color.parseColor(backgroundColor);
            if (collectionElementView.getBackground() instanceof GradientDrawable)
            {
                ((GradientDrawable) collectionElementView.getBackground()).setColor(color);
            }
            else
            {
                GradientDrawable gradientDrawable = new GradientDrawable();
                gradientDrawable.setColor(color);
                collectionElementView.setBackground(gradientDrawable);
            }
        }
    }

    /**
     * @deprecated renamed to {@link #getLocalContainerStyle}
     */
    public static ContainerStyle GetLocalContainerStyle(StyledCollectionElement collectionElement, ContainerStyle parentContainerStyle)
    {
        return getLocalContainerStyle(collectionElement, parentContainerStyle);
    }

    public static ContainerStyle getLocalContainerStyle(StyledCollectionElement collectionElement, ContainerStyle parentContainerStyle)
    {
        return computeContainerStyle(collectionElement.GetStyle(), parentContainerStyle);
    }

    /**
     * Compute the style to apply to a container given its declared and inherited styles.
     * @param declared the ContainerStyle declared on a container element
     * @param inherited the ContainerStyle inherited through RenderArgs provided by parent
     * @return the ContainerStyle to apply
     */
    public static ContainerStyle computeContainerStyle(ContainerStyle declared, ContainerStyle inherited)
    {
        return declared == ContainerStyle.None ? inherited : declared;
    }

    public static void setBackgroundImage(RenderedAdaptiveCard renderedCard,
                                          Context context,
                                          BackgroundImage backgroundImage,
                                          HostConfig hostConfig,
                                          ViewGroup containerView)
    {
        if (backgroundImage != null)
        {
            String backgroundImageUrl = backgroundImage.GetUrl();

            if (!backgroundImageUrl.isEmpty())
            {
                BackgroundImageLoaderAsync loaderAsync = new BackgroundImageLoaderAsync(
                    renderedCard,
                    context,
                    containerView,
                    hostConfig.GetImageBaseUrl(),
                    context.getResources().getDisplayMetrics().widthPixels,
                    backgroundImage);

                IOnlineImageLoader onlineImageLoader = CardRendererRegistration.getInstance().getOnlineImageLoader();
                if (onlineImageLoader != null)
                {
                    loaderAsync.registerCustomOnlineImageLoader(onlineImageLoader);
                }

                loaderAsync.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, backgroundImageUrl);
            }
        }
    }

    public static void applyTitleAndTooltip(BaseActionElement selectAction, View view)
    {
        String contentDescription = !TextUtils.isEmpty(selectAction.GetTitle()) ? selectAction.GetTitle() : selectAction.GetTooltip();
        String tooltip = !TextUtils.isEmpty(selectAction.GetTooltip()) ? selectAction.GetTooltip() : selectAction.GetTitle();
        if (!TextUtils.isEmpty(contentDescription))
        {
            view.setContentDescription(contentDescription);
        }
        if (!TextUtils.isEmpty(tooltip))
        {
            TooltipCompat.setTooltipText(view, tooltip);
        }
        if (selectAction.GetElementType() == ActionType.ToggleVisibility)
        {
            setAccessibilityForView(view);
        }

    }

    private static void setAccessibilityForView(@NonNull View view) {

        if (view instanceof ViewGroup)
        {
            ViewGroup group = ((ViewGroup) view);
            String description = "";
            if (group.getChildCount() > 0 && group.getChildAt(0) instanceof TextView)
            {
                description = ((TextView) group.getChildAt(0)).getText().toString();
            }
            String finalDescription = description;
            ViewCompat.setAccessibilityDelegate(view, new AccessibilityDelegateCompat()
            {
                @Override
                public void onInitializeAccessibilityNodeInfo(View host, AccessibilityNodeInfoCompat info) {
                    super.onInitializeAccessibilityNodeInfo(host, info);
                    info.setClassName(Button.class.getName());
                    info.addAction(AccessibilityNodeInfoCompat.ACTION_CLICK);
                    info.setContentDescription(finalDescription);
                }
            });
        }
    }

    public static void setSelectAction(RenderedAdaptiveCard renderedCard, BaseActionElement selectAction, View view, ICardActionHandler cardActionHandler, RenderArgs renderArgs)
    {
        if (selectAction != null)
        {
            view.setFocusable(true);
            view.setClickable(true);
            view.setEnabled(selectAction.GetIsEnabled());
            if (Util.isOfType(selectAction, ExecuteAction.class) || Util.isOfType(selectAction, SubmitAction.class) || selectAction.GetElementType() == ActionType.Custom)
            {
                renderedCard.registerSubmitableAction(view, renderArgs);
            }

            view.setOnClickListener(new BaseActionElementRenderer.SelectActionOnClickListener(renderedCard, selectAction, cardActionHandler));

            applyTitleAndTooltip(selectAction, view);

            if (view instanceof ViewGroup)
            {
                ViewGroup group = (ViewGroup) view;
                if (group.getChildCount() == 1)
                {
                    View childView = group.getChildAt(0);
                    if (childView.isFocusable())
                    {
                        childView.setFocusable(false);

                        // setScreenReaderFocusable is only available in API level 28 (P) and above
                        // Need to check the SDK version of the current device
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                        {
                            childView.setScreenReaderFocusable(false);
                        }
                        childView.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO);
                    }
                }
            }
        }
    }

    public static ViewGroup getAppropriateContainerForLayout(Context context, Layout layoutToApply, Container container) {
        ViewGroup layoutContainer;
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow ) {
            FlexboxLayout flexboxLayout = new FlexboxLayout(context);
            flexboxLayout.setFlexDirection(FlexDirection.ROW);
            flexboxLayout.setFlexWrap(FlexWrap.WRAP);
            Util.setHorizontalAlignmentForFlowLayout(flexboxLayout, layoutToApply);
            flexboxLayout.setLayoutParams(new FlexboxLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            flexboxLayout.setTag(new TagContent(container));
            layoutContainer = flexboxLayout;
        } else if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.AreaGrid) {
            AreaGridLayoutView flexboxLayout = new AreaGridLayoutView(context);
            flexboxLayout.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            flexboxLayout.setTag(new TagContent(container));
            layoutContainer = flexboxLayout;
        } else {
            StretchableElementLayout stackLayout = new StretchableElementLayout(context, container.GetHeight() == HeightType.Stretch);
            stackLayout.setTag(new TagContent(container));
            stackLayout.setOrientation(LinearLayout.VERTICAL);
            layoutContainer = stackLayout;
        }
        return layoutContainer;
    }

    private static ContainerRenderer s_instance = null;
}
