// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import com.google.android.flexbox.FlexDirection;
import com.google.android.flexbox.FlexWrap;
import com.google.android.flexbox.FlexboxLayout;

import java.util.Locale;

import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.Column;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.HorizontalAlignment;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.Layout;
import io.adaptivecards.objectmodel.LayoutContainerType;
import io.adaptivecards.renderer.AdaptiveFallbackException;
import io.adaptivecards.renderer.AdaptiveWarning;
import io.adaptivecards.renderer.BaseCardElementRenderer;
import io.adaptivecards.renderer.RenderArgs;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.TagContent;
import io.adaptivecards.renderer.Util;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.registration.CardRendererRegistration;
import io.adaptivecards.renderer.registration.FeatureFlagResolverUtility;

public class ColumnRenderer extends BaseCardElementRenderer
{
    protected ColumnRenderer()
    {
    }

    public static ColumnRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new ColumnRenderer();
        }

        return s_instance;
    }

    /**
     * If column width is given as a relative weight, get the weight
     *
     * @param column The Column element
     * @return weight, or null if width is not relative
     */
    static @Nullable Float getRelativeWidth(Column column)
    {
        try
        {
            String columnSize = column.GetWidth().toLowerCase(Locale.getDefault());
            return Float.parseFloat(columnSize);
        } catch (NumberFormatException ex)
        {
            return null;
        }
    }

    private ViewGroup setColumnWidth(RenderedAdaptiveCard renderedCard, Context context, Column column, ViewGroup columnLayout)
    {
        String columnSize = column.GetWidth().toLowerCase(Locale.getDefault());
        long pixelWidth = column.GetPixelWidth();
        Float relativeWidth = ColumnRenderer.getRelativeWidth(column);

        FlexboxLayout.LayoutParams layoutParams = new FlexboxLayout.LayoutParams(0, FlexboxLayout.LayoutParams.MATCH_PARENT);

        if (pixelWidth != 0)
        {
            layoutParams.setFlexGrow(0);
            layoutParams.setFlexShrink(0);
            layoutParams.setWidth(Util.dpToPixels(context, pixelWidth));
        } else if (relativeWidth != null)
        {
            // Set ratio to column
            layoutParams.setFlexGrow(relativeWidth);
            layoutParams.setFlexShrink(1);
            layoutParams.setFlexBasisPercent(0);
        } else if (TextUtils.isEmpty(columnSize) || columnSize.equals(g_columnSizeStretch))
        {
            layoutParams.setFlexGrow(1);
            layoutParams.setFlexShrink(1);
            layoutParams.setFlexBasisPercent(0);
        } else
        {
            // If the width is Auto or is not valid (not weight, pixel, empty or stretch)
            layoutParams.setFlexGrow(0);
            layoutParams.setFlexShrink(1);
            layoutParams.setWidth(FlexboxLayout.LayoutParams.WRAP_CONTENT);

            if (!columnSize.equals(g_columnSizeAuto))
            {
                renderedCard.addWarning(new AdaptiveWarning(AdaptiveWarning.INVALID_COLUMN_WIDTH_VALUE, "Column Width (" + column.GetWidth() + ") is not a valid weight ('auto', 'stretch', <integer>)."));
            }
        }
        columnLayout.setLayoutParams(layoutParams);
        return columnLayout;
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
        Column column = Util.castTo(baseCardElement, Column.class);

        Layout layoutToApply = Util.getLayoutToApply(column.GetLayouts(), hostConfig);
        ViewGroup columnLayout = getAppropriateContainerForLayout(context, layoutToApply, column);

        // TODO: Check compatibility with model on top
        // Spacing between elements in a Layout.Flow is solely controlled by the columnSpacing and rowSpacing properties
        // provided by the flow layout. The spacing and separator properties on items are ignored.
        View separator = null;
        boolean isFlowLayout = layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow;
        if (!isFlowLayout) {
            separator = setSpacingAndSeparator(context, viewGroup, column.GetSpacing(), column.GetSeparator(), hostConfig, false);
        }

        setVisibility(baseCardElement.GetIsVisible(), columnLayout);

        setColumnWidth(renderedCard, context, column, columnLayout);
        setMinHeight(column.GetMinHeight(), columnLayout, context);

        ContainerStyle containerStyle = renderArgs.getContainerStyle();
        ContainerStyle styleForThis = ContainerRenderer.getLocalContainerStyle(column, containerStyle);

        RenderArgs columnRenderArgs = new RenderArgs(renderArgs);
        columnRenderArgs.setContainerStyle(styleForThis);
        columnRenderArgs.setHorizontalAlignment(HorizontalAlignment.Left);
        columnRenderArgs.setAncestorHasSelectAction(renderArgs.getAncestorHasSelectAction() || (column.GetSelectAction() != null));
        if (!column.GetItems().isEmpty())
        {
            try
            {
                CardRendererRegistration.getInstance().renderElements(renderedCard,
                    context,
                    fragmentManager,
                    columnLayout,
                    column.GetItems(),
                    cardActionHandler,
                    hostConfig,
                    columnRenderArgs,
                    layoutToApply);

                if (FeatureFlagResolverUtility.INSTANCE.isItemFitToFillEnabledForColumn()) {
                    ContainerRenderer.applyItemFillForFlowLayout(layoutToApply, columnLayout);
                }

            } catch (AdaptiveFallbackException e)
            {
                // If the column couldn't be rendered, the separator is removed
                if (separator != null) {
                    viewGroup.removeView(separator);
                }
                throw e;
            }
        }

        ContainerRenderer.setBackgroundImage(renderedCard, context, column.GetBackgroundImage(), hostConfig, columnLayout);

        ContainerRenderer.applyVerticalContentAlignment(columnLayout, column.GetVerticalContentAlignment(), layoutToApply);

        ContainerRenderer.applyPadding(styleForThis, renderArgs.getContainerStyle(), columnLayout, hostConfig, column.GetShowBorder());
        ContainerRenderer.applyContainerStyle(styleForThis, renderArgs.getContainerStyle(), columnLayout, hostConfig);
        ContainerRenderer.applyBleed(column, columnLayout, context, hostConfig);
        ContainerRenderer.applyBorder(styleForThis, columnLayout, hostConfig, column.GetElementType(), column.GetShowBorder());
        ContainerRenderer.applyRoundedCorners(columnLayout, hostConfig, column.GetElementType(), column.GetRoundedCorners());
        BaseCardElementRenderer.applyRtl(column.GetRtl(), columnLayout);

        ContainerRenderer.setSelectAction(renderedCard, column.GetSelectAction(), columnLayout, cardActionHandler, renderArgs);
        viewGroup.addView(columnLayout);
        return columnLayout;
    }

    private static ViewGroup getAppropriateContainerForLayout(Context context, Layout layoutToApply, Column column) {
        ViewGroup layoutContainer;
        if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow) {
            FlexboxLayout flexboxLayout = new FlexboxLayout(context);
            flexboxLayout.setFlexDirection(FlexDirection.ROW);
            flexboxLayout.setFlexWrap(FlexWrap.WRAP);
            Util.setHorizontalAlignmentForFlowLayout(flexboxLayout, layoutToApply);
            flexboxLayout.setTag(new TagContent(column));
            layoutContainer = flexboxLayout;
        } else {
            LinearLayout columnLayout = new LinearLayout(context);
            columnLayout.setOrientation(LinearLayout.VERTICAL);
            columnLayout.setTag(new TagContent(column));
            columnLayout.setFocusable(true);
            columnLayout.setFocusableInTouchMode(true);
            layoutContainer = columnLayout;
        }
        return layoutContainer;
    }

    private static ColumnRenderer s_instance = null;
    private final String g_columnSizeAuto = "auto";
    private final String g_columnSizeStretch = "stretch";
}
