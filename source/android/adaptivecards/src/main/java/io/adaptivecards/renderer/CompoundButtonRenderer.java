// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import com.google.android.flexbox.AlignItems;
import com.google.android.flexbox.FlexDirection;
import com.google.android.flexbox.FlexWrap;
import com.google.android.flexbox.FlexboxLayout;
import com.google.android.flexbox.JustifyContent;

import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.CompoundButton;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.ForegroundColor;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.IconStyle;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.readonly.ContainerRenderer;

public class CompoundButtonRenderer extends BaseCardElementRenderer {
    protected CompoundButtonRenderer()
    {
    }

    public static CompoundButtonRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new CompoundButtonRenderer();
        }

        return s_instance;
    }

    @Nullable
    @Override
    public View render(@NonNull RenderedAdaptiveCard renderedCard,
                       @NonNull Context context,
                       @NonNull FragmentManager fragmentManager,
                       @NonNull ViewGroup viewGroup,
                       @NonNull BaseCardElement baseCardElement,
                       ICardActionHandler cardActionHandler,
                       @NonNull HostConfig hostConfig,
                       @NonNull RenderArgs renderArgs) throws Exception {
        CompoundButton compoundButton = Util.castTo(baseCardElement, io.adaptivecards.objectmodel.CompoundButton.class);
        ViewGroup compoundButtonLayout = getCompoundButtonLayout(context, compoundButton, renderedCard, hostConfig, renderArgs);
        compoundButtonLayout.setTag(new TagContent(compoundButton));
        viewGroup.addView(compoundButtonLayout);
        ContainerRenderer.setSelectAction(renderedCard, compoundButton.GetSelectAction(), compoundButtonLayout, cardActionHandler, renderArgs);
        return compoundButtonLayout;
    }

    private ViewGroup getCompoundButtonLayout(Context context, CompoundButton compoundButton, RenderedAdaptiveCard renderedCard, HostConfig hostConfig, RenderArgs renderArgs) {
        ContainerStyle style = renderArgs.getContainerStyle();
        String foregroundColor = hostConfig.GetForegroundColor(style, ForegroundColor.Default, false);
        String backgroundColor = hostConfig.GetBackgroundColor(style);

        // Create a FlexboxLayout
        FlexboxLayout flexboxLayout = new FlexboxLayout(context);
        FlexboxLayout.LayoutParams flexboxLayoutParams = new FlexboxLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );

        flexboxLayout.setLayoutParams(flexboxLayoutParams);
        flexboxLayout.setFlexDirection(FlexDirection.COLUMN);
        int paddingPx = dpToPx(context, 16);
        flexboxLayout.setPadding(paddingPx, paddingPx, paddingPx, paddingPx);

        // FlexboxLayout for header i.e. Icon, Title, Badge
        FlexboxLayout headerLayout = new FlexboxLayout(context);
        FlexboxLayout.LayoutParams headerLayoutParams = new FlexboxLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        headerLayout.setFlexDirection(FlexDirection.ROW); // Set direction to row
        headerLayout.setFlexWrap(FlexWrap.WRAP); // Enable wrapping
        headerLayout.setJustifyContent(JustifyContent.FLEX_START);
        headerLayout.setAlignItems(AlignItems.CENTER);
        headerLayout.setLayoutParams(headerLayoutParams);

        boolean isIconSet = compoundButton.getIcon() != null && !compoundButton.getIcon().GetName().isEmpty();

        // Optional Image View
        ImageView imageView = new ImageView(context);
        LinearLayout.LayoutParams imageLayoutParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        imageLayoutParams.setMarginEnd(dpToPx(context, 8));
        imageView.setLayoutParams(imageLayoutParams);

        if (!isIconSet) {
            imageView.setVisibility(View.GONE);
        } else {
            boolean isFilledStyle = compoundButton.getIcon().getIconStyle() == IconStyle.Filled;
            String svgInfoURL = Util.getSvgInfoUrl(compoundButton.getIcon().GetSVGPath());
            String foregroundColorIcon = hostConfig.GetForegroundColor(ContainerStyle.Default, compoundButton.getIcon().getForgroundColor(), false);
            FluentIconImageLoaderAsync fluentIconImageLoaderAsync = new FluentIconImageLoaderAsync(
                renderedCard,
                Util.getFluentIconSize(compoundButton.getIcon().getIconSize()),
                foregroundColorIcon,
                isFilledStyle,
                imageView
            );
            fluentIconImageLoaderAsync.execute(svgInfoURL);
        }

        LinearLayout.LayoutParams titleLayoutParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        titleLayoutParams.setMarginEnd(dpToPx(context, 8));

        // Title TextView
        TextView titleTextView = new TextView(context);
        titleTextView.setLayoutParams(titleLayoutParams);
        titleTextView.setText(compoundButton.getTitle());
        titleTextView.setSingleLine();
        titleTextView.setTextSize(17);
        titleTextView.setTextColor(Color.parseColor(foregroundColor));
        titleTextView.setEllipsize(TextUtils.TruncateAt.END);
        titleTextView.setTypeface(null, Typeface.BOLD);

        // Badge TextView
        TextView badgeTextView = new TextView(context);
        LinearLayout.LayoutParams badgeLayoutParams = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        badgeTextView.setLayoutParams(badgeLayoutParams);
        badgeTextView.setTextSize(12);
        badgeTextView.setText(compoundButton.getBadge());
        badgeTextView.setTextColor(Color.parseColor(backgroundColor));
        badgeTextView.setBackground(createCustomDrawable(context, hostConfig.GetCompoundButtonConfig().getBadgeConfig().getBackgroundColor(), 12));
        badgeTextView.setPadding(dpToPx(context, 8), dpToPx(context, 3), dpToPx(context, 8), dpToPx(context, 3));
        if (compoundButton.getBadge().isEmpty()) {
            badgeTextView.setVisibility(View.GONE);
        }

        headerLayout.addView(imageView);
        headerLayout.addView(titleTextView);
        headerLayout.addView(badgeTextView);

        flexboxLayout.addView(headerLayout);

        // Description TextView
        TextView descriptionTextView = new TextView(context);
        FlexboxLayout.LayoutParams descriptionLayoutParams = new FlexboxLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        descriptionTextView.setLayoutParams(descriptionLayoutParams);
        descriptionTextView.setTextSize(15);
        descriptionTextView.setText(compoundButton.getDescription());
        descriptionTextView.setTextColor(Color.parseColor(foregroundColor));
        descriptionTextView.setLayoutParams(descriptionLayoutParams);
        if (compoundButton.getDescription().isEmpty()){
            descriptionTextView.setVisibility(View.GONE);
        }

        flexboxLayout.addView(descriptionTextView);
        flexboxLayout.setBackground(createCustomOuterDrawable(context, hostConfig.GetCompoundButtonConfig().getBorderColor()));
        return flexboxLayout;
    }

    public Drawable createCustomOuterDrawable(Context context, String borderColour) {
        // Create a GradientDrawable
        GradientDrawable drawable = new GradientDrawable();

        // Set the shape to a rectangle (default is rectangle, so this line is optional)
        drawable.setShape(GradientDrawable.RECTANGLE);

        // Set the solid color
        drawable.setColor(0x00FFFFFF); // Hex color #00FFFFFF (Transparent)

        // Set the stroke width and color
        int strokeWidth = dpToPx(context, 1); // Convert 1dp to pixels
        drawable.setStroke(strokeWidth, Color.parseColor(borderColour));

        // Set the corner radius
        float cornerRadius = dpToPx(context, 12); // Convert 12dp to pixels
        drawable.setCornerRadius(cornerRadius);

        return drawable;
    }

    public Drawable createCustomDrawable(Context context, String backgroundColor, int cornerRadius) {
        // Create a GradientDrawable for the shape
        GradientDrawable drawable = new GradientDrawable();

        // Set the shape to a rectangle
        drawable.setShape(GradientDrawable.RECTANGLE);

        // Set the solid color
        drawable.setColor(Color.parseColor(backgroundColor));

        // Set the corner radius
        float cornerRadiusPx = dpToPx(context, cornerRadius);
        drawable.setCornerRadii(new float[] {
            cornerRadiusPx, cornerRadiusPx, // top left, top right
            cornerRadiusPx, cornerRadiusPx, // bottom right, bottom left
            cornerRadiusPx, cornerRadiusPx, // bottom left, bottom right
            cornerRadiusPx, cornerRadiusPx  // top right, top left
        });

        return drawable;
    }

    // Helper method to convert dp to pixels
    private int dpToPx(Context context, int dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round(dp * density);
    }

    private static CompoundButtonRenderer s_instance = null;
}
