// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.action;

import static io.adaptivecards.renderer.inputhandler.InputUtils.isAnyInputValid;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.PorterDuff;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.ContextThemeWrapper;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import androidx.appcompat.widget.TooltipCompat;
import androidx.fragment.app.FragmentManager;

import io.adaptivecards.R;
import io.adaptivecards.objectmodel.ActionAlignment;
import io.adaptivecards.objectmodel.ActionType;
import io.adaptivecards.objectmodel.ActionsOrientation;
import io.adaptivecards.objectmodel.BaseActionElement;
import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.ExecuteAction;
import io.adaptivecards.objectmodel.ForegroundColor;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.IconPlacement;
import io.adaptivecards.objectmodel.SubmitAction;
import io.adaptivecards.renderer.BaseActionElementRenderer;
import io.adaptivecards.renderer.RenderArgs;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.Util;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.inputhandler.IInputHandler;

import java.util.List;


public class ActionElementRenderer extends BaseActionElementRenderer
{
    protected ActionElementRenderer()
    {
    }

    public static ActionElementRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new ActionElementRenderer();
        }

        return s_instance;
    }

    private static Button createButtonWithTheme(Context context, int theme)
    {
        Context themedContext = new ContextThemeWrapper(context, theme);
        return new Button(themedContext);
    }

    protected static Button getButtonForStyle(Context context, String style, HostConfig hostConfig)
    {
        boolean isPositiveStyle = style.equalsIgnoreCase("Positive");
        boolean isDestructiveStyle = style.equalsIgnoreCase("Destructive");

        if(isPositiveStyle || isDestructiveStyle)
        {
            Resources.Theme theme = context.getTheme();
            TypedValue buttonStyle = new TypedValue();

            if(isPositiveStyle)
            {
                if(theme.resolveAttribute(R.attr.adaptiveActionPositive, buttonStyle, true))
                {
                    return createButtonWithTheme(context, buttonStyle.data);
                }
                else
                {
                    Button button = new Button(context);
                    button.getBackground().setColorFilter(getColor(hostConfig.GetForegroundColor(ContainerStyle.Default, ForegroundColor.Accent, false)), PorterDuff.Mode.MULTIPLY);
                    return button;
                }
            }
            else
            {
                if(theme.resolveAttribute(R.attr.adaptiveActionDestructive, buttonStyle, true))
                {
                    return createButtonWithTheme(context, buttonStyle.data);
                }
                else
                {
                    Button button = new Button(context);
                    button.getBackground().setColorFilter(getColor(hostConfig.GetForegroundColor(ContainerStyle.Default, ForegroundColor.Attention, false)), PorterDuff.Mode.MULTIPLY);
                    return button;
                }
            }
        }

        return new Button(context);
    }

    public Button renderButton(
        Context context,
        ViewGroup viewGroup,
        BaseActionElement baseActionElement,
        HostConfig hostConfig,
        RenderedAdaptiveCard renderedCard,
        RenderArgs renderArgs)
    {
        TypedValue buttonStyle = new TypedValue();
        if (baseActionElement.GetElementType() == ActionType.ShowCard && context.getTheme().resolveAttribute(R.attr.adaptiveShowCardAction, buttonStyle, true)) {
            context = new ContextThemeWrapper(context, buttonStyle.data);
        }

        Button button = getButtonForStyle(context, baseActionElement.GetStyle(), hostConfig);

        if (Util.isOfType(baseActionElement, ExecuteAction.class) || Util.isOfType(baseActionElement, SubmitAction.class))
        {
            long actionId = Util.getViewId(button);
            renderedCard.setCardForSubmitAction(actionId, renderArgs.getContainerCardId());
        }
        setButtonEnabledState(baseActionElement, button, renderedCard);

        button.setText(baseActionElement.GetTitle());
        if (!TextUtils.isEmpty(baseActionElement.GetTooltip()))
        {
            TooltipCompat.setTooltipText(button, baseActionElement.GetTooltip());
        }
        ActionAlignment alignment = hostConfig.GetActions().getActionAlignment();
        ActionsOrientation orientation = hostConfig.GetActions().getActionsOrientation();
        LinearLayout.LayoutParams layoutParams;
        if (orientation == ActionsOrientation.Horizontal)
        {
            layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
            long spacing = hostConfig.GetActions().getButtonSpacing();
            layoutParams.rightMargin = Util.dpToPixels(context, spacing);
        }
        else
        {
            layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        }

        if (alignment == ActionAlignment.Stretch)
        {
            layoutParams.weight = 1f;
        }

        button.setLayoutParams(layoutParams);
        int minHeight = context.getResources().getDimensionPixelSize(R.dimen.action_min_height);
        button.post(() -> Util.expandClickArea(button, minHeight));

        String iconUrl = baseActionElement.GetIconUrl(renderArgs.getTheme());
        String svgInfoURL = Util.getSvgInfoUrl(baseActionElement.GetSVGPath());

        if (!iconUrl.isEmpty())
        {
            IconPlacement iconPlacement = hostConfig.GetActions().getIconPlacement();
            if (!renderArgs.getAllowAboveTitleIconPlacement())
            {
                iconPlacement = IconPlacement.LeftOfTitle;
            }

            Util.loadIcon(context, button, iconUrl, svgInfoURL, hostConfig, renderedCard, iconPlacement);
        }

        if (baseActionElement.GetIsSplitAction()) {
            String splitButtonSvgURL = Util.getSvgInfoUrl(baseActionElement.GetSVGPath(SPLIT_BUTTON_ICON_URL));
            Util.loadIcon(context, button, SPLIT_BUTTON_ICON_URL, splitButtonSvgURL, hostConfig, renderedCard, IconPlacement.RightOfTitle);
        }

        if (baseActionElement.GetElementType() == ActionType.OpenUrl) {
            button.setContentDescription(Util.getOpenUrlAnnouncement(context, baseActionElement.GetTitle()));
        }

        viewGroup.addView(button);

        return button;
    }

    /**
     * Set Enable state of the button in ActionElement for ConditionallyEnabled property
     * if baseActionElement.GetIsEnabled() is false ignore ConditionallyEnabled and disable the button
     * Else if ConditionallyEnabled is true then disable the button if all of the required inputs
     * are invalid.
     * In any other case enable the button by default
     * @param baseActionElement
     * @param button
     * @param adaptiveCard
     * protected so that it cab be called from TeamsActionElementRenderer as it doesn't call super.
     */
    protected void setButtonEnabledState(BaseActionElement baseActionElement, Button button, RenderedAdaptiveCard adaptiveCard) {
        if (!baseActionElement.GetIsEnabled()) {
            button.setEnabled(false);
        } else if (Util.isOfType(baseActionElement, ExecuteAction.class)) {
            ExecuteAction executeAction = Util.castTo(baseActionElement, ExecuteAction.class);
            if (executeAction.GetConditionallyEnabled()) {
                addInputWatcherForConditionallyEnabledAction(adaptiveCard, button);
            }
        } else if (Util.isOfType(baseActionElement, SubmitAction.class)) {
            SubmitAction submitAction = Util.castTo(baseActionElement, SubmitAction.class);
            if (submitAction.GetConditionallyEnabled()) {
                addInputWatcherForConditionallyEnabledAction(adaptiveCard, button);
            }
        } else {
            button.setEnabled(true);
        }
    }

    private void addInputWatcherForConditionallyEnabledAction(RenderedAdaptiveCard adaptiveCard, Button button) {
        List<IInputHandler> inputHandlers = adaptiveCard.getInputsToValidate(Util.getViewId(button));
        button.setEnabled(isAnyInputValid(inputHandlers));
        for (IInputHandler inputHandler : inputHandlers) {
            inputHandler.addInputWatcher((id, val) -> button.setEnabled(isAnyInputValid(inputHandlers)));
        }
    }

    @Override
    public Button render(
            RenderedAdaptiveCard renderedCard,
            Context context,
            FragmentManager fragmentManager,
            ViewGroup viewGroup,
            BaseActionElement baseActionElement,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig,
            RenderArgs renderArgs) {
        if (cardActionHandler == null)
        {
            throw new IllegalArgumentException("Action Handler is null.");
        }

        Button button = renderButton(context, viewGroup, baseActionElement, hostConfig, renderedCard, renderArgs);
        button.setOnClickListener(BaseActionElementRenderer.ActionOnClickListener.newInstance(renderedCard, context, fragmentManager, viewGroup, baseActionElement, cardActionHandler, hostConfig, renderArgs));

        return button;
    }

    private static ActionElementRenderer s_instance = null;
    private static final String SPLIT_BUTTON_ICON_URL = "icon:ChevronDown,Filled";
}
