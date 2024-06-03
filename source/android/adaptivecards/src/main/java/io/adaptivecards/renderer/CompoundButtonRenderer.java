// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentManager;

import io.adaptivecards.R;
import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.CompoundButton;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.HostConfig;
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
        ViewGroup compoundButtonLayout = getCompoundButtonLayout(context, compoundButton, renderedCard, hostConfig);
        compoundButtonLayout.setTag(new TagContent(compoundButton));
        viewGroup.addView(compoundButtonLayout);
        ContainerRenderer.setSelectAction(renderedCard, compoundButton.GetSelectAction(), compoundButtonLayout, cardActionHandler, renderArgs);
        return compoundButtonLayout;
    }

    private ViewGroup getCompoundButtonLayout(Context context, CompoundButton compoundButton, RenderedAdaptiveCard renderedCard, HostConfig hostConfig) {
        String foregroundColor = hostConfig.GetForegroundColor(ContainerStyle.Default, compoundButton.getIcon().getForgroundColor(), false);
        String backgroundColor = hostConfig.GetBackgroundColor(ContainerStyle.Default);

        // Create a RelativeLayout
        RelativeLayout layout = new RelativeLayout(context);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        layout.setLayoutParams(layoutParams);
        layout.setBackgroundColor(Color.parseColor(backgroundColor));

        boolean isIconSet = !compoundButton.getIcon().GetName().isEmpty();

        // Optional Image View
        ImageView imageView = new ImageView(context);
        imageView.setId(View.generateViewId());
        RelativeLayout.LayoutParams imageParams = new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        imageParams.addRule(RelativeLayout.ALIGN_PARENT_START);
        imageParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        imageView.setPadding(dpToPx(2, context), dpToPx(2, context), dpToPx(2, context), dpToPx(2, context));
        imageView.setLayoutParams(imageParams);
        layout.addView(imageView);
        if (!isIconSet) {
            imageView.setVisibility(View.GONE);
        } else {
            String svgURL = compoundButton.getIcon().GetSVGResourceURL();
            FluentIconImageLoaderAsync fluentIconImageLoaderAsync = new FluentIconImageLoaderAsync(
                renderedCard,
                compoundButton.getIcon().getSize(),
                foregroundColor,
                imageView
            );
            fluentIconImageLoaderAsync.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, svgURL);
        }

        // Title TextView
        TextView titleTextView = new TextView(context);
        titleTextView.setId(View.generateViewId());
        titleTextView.setText(compoundButton.getTitle());
        titleTextView.setTextColor(Color.parseColor(foregroundColor));
        titleTextView.setEllipsize(TextUtils.TruncateAt.END);
        titleTextView.setMaxLines(1);
        titleTextView.setTypeface(null, Typeface.BOLD);
        RelativeLayout.LayoutParams titleParams = new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        titleParams.addRule(RelativeLayout.END_OF, imageView.getId());
        titleParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        titleParams.addRule(RelativeLayout.CENTER_VERTICAL, RelativeLayout.TRUE);
        int leftPadding = isIconSet ? dpToPx(8, context) : dpToPx(0, context);
        titleTextView.setPadding(leftPadding, dpToPx(8, context), dpToPx(8, context), dpToPx(8, context));
        titleTextView.setLayoutParams(titleParams);
        layout.addView(titleTextView);

        // Badge TextView
        TextView badgeTextView = new TextView(context);
        badgeTextView.setId(View.generateViewId());
        badgeTextView.setText(compoundButton.getBadge());
        badgeTextView.setTextColor(Color.parseColor(backgroundColor));
        badgeTextView.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.adaptive_compound_button_badge_background));
        badgeTextView.setPadding(dpToPx(8, context), dpToPx(8, context), dpToPx(8, context), dpToPx(8, context));
        RelativeLayout.LayoutParams badgeParams = new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        badgeParams.addRule(RelativeLayout.END_OF, titleTextView.getId());
        badgeParams.addRule(RelativeLayout.ALIGN_BASELINE, titleTextView.getId());
        badgeParams.addRule(RelativeLayout.CENTER_VERTICAL, RelativeLayout.TRUE);
        badgeTextView.setLayoutParams(badgeParams);
        layout.addView(badgeTextView);

        // Description TextView
        TextView descriptionTextView = new TextView(context);
        descriptionTextView.setId(View.generateViewId());
        descriptionTextView.setText(compoundButton.getDescription());
        descriptionTextView.setTextColor(Color.parseColor(foregroundColor));
        descriptionTextView.setMaxLines(5);
        RelativeLayout.LayoutParams descriptionParams = new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        descriptionParams.addRule(RelativeLayout.BELOW, titleTextView.getId());
        descriptionTextView.setPadding(dpToPx(2, context), dpToPx(2, context), dpToPx(2, context), dpToPx(2, context));
        descriptionTextView.setLayoutParams(descriptionParams);
        layout.addView(descriptionTextView);

       return layout;
    }

    // Helper method to convert dp to pixels
    private int dpToPx(int dp, Context context) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round((float) dp * density);
    }

    private static CompoundButtonRenderer s_instance = null;
}
